local function loadCatalog(labels)
    WowStub.reset()
    _G.ForeverBiSBuildLabels = labels
    return WowStub.loadFiles({ "Core/Catalog.lua" }).Catalog
end

describe("Catalog", function()
    after_each(function()
        _G.ForeverBiSBuildLabels = nil
    end)

    it("finds a class by key and falls back to the rogue for an unknown one", function()
        local Catalog = loadCatalog()
        assert.are.equal("druid", Catalog.findClass("druid").key)
        assert.are.equal("rogue", Catalog.findClass("not-a-class").key)
        assert.are.equal("rogue", Catalog.findClass(nil).key)
    end)

    it("finds a build by key, treating pve as the default build", function()
        local Catalog = loadCatalog()
        local rogue = Catalog.findClass("rogue")
        assert.are.equal("pvp", Catalog.findBuild(rogue, "pvp")[1])
        assert.are.equal("pve", Catalog.findBuild(rogue, "pve")[1])
        assert.are.equal("pve", Catalog.findBuild(rogue, "")[1])
    end)

    it("falls back to the default build for an unknown build key", function()
        local Catalog = loadCatalog()
        local druid = Catalog.findClass("druid")
        assert.are.equal("feral-pve", Catalog.findBuild(druid, "not-a-build")[1])
    end)

    it("falls back to the first build when no build has an empty route suffix", function()
        local Catalog = loadCatalog()
        local class = { key = "x", builds = { { "a", "A", "/a" }, { "b", "B", "/b" } } }
        assert.are.equal("a", Catalog.findBuild(class, "missing")[1])
        assert.are.equal("a", Catalog.defaultBuild(class)[1])
    end)

    it("names the default build by its empty route suffix", function()
        local Catalog = loadCatalog()
        assert.are.equal("feral-pve", Catalog.defaultBuild(Catalog.findClass("druid"))[1])
    end)

    it("builds the route key from the class key and the build suffix", function()
        local Catalog = loadCatalog()
        local druid = Catalog.findClass("druid")
        assert.are.equal("druid", Catalog.routeKey(druid, Catalog.defaultBuild(druid)))
        assert.are.equal("druid/tank", Catalog.routeKey(druid, Catalog.findBuild(druid, "tank")))
    end)

    it("resolves stale class and build keys to known ones", function()
        local Catalog = loadCatalog()
        local class, build, route = Catalog.resolve("not-a-class", "not-a-build")
        assert.are.equal("rogue", class.key)
        assert.are.equal("pve", build[1])
        assert.are.equal("rogue", route)
    end)

    it("replaces a class's builds with the labelled routes the data provides, sorted by label", function()
        local Catalog = loadCatalog({ ["mage"] = "Zeta", ["mage/arcane"] = "Arcane" })
        local builds = Catalog.findClass("mage").builds
        assert.are.same({ { "/arcane", "Arcane", "/arcane" }, { "", "Zeta", "" } }, builds)
    end)

    it("keeps the built-in builds of a class the data does not mention", function()
        local Catalog = loadCatalog({ ["mage"] = "Mage" })
        assert.are.equal("PvP", Catalog.findClass("rogue").builds[2][2])
    end)

    it("matches data routes by class key, not by prefix", function()
        local Catalog = loadCatalog({ ["priest/holy"] = "Holy" })
        assert.are.equal("Holy", Catalog.findClass("priest").builds[1][2])
        assert.are.equal("Retribution PvE", Catalog.findClass("paladin").builds[1][2])
    end)

    it("lists every distinct progress slot once, paper doll first and weapons last", function()
        local Catalog = loadCatalog()
        local keys = Catalog.progressKeys()
        assert.are.equal("Head", keys[1])
        assert.are.equal("Ranged", keys[#keys])
        local seen = {}
        for _, key in ipairs(keys) do
            assert.is_nil(seen[key], key .. " is listed twice")
            seen[key] = true
        end
        assert.is_true(seen["Finger"] and seen["Trinket"] and seen["Main Hand"])
    end)

    describe("modes", function()
        it("splits a label into its mode and spec", function()
            local Catalog = loadCatalog()
            local cases = {
                { "Holy PvP", "pvp", "Holy" },
                { "Retribution PvE", "pve", "Retribution" },
                { "Subtlety PvP, Dagger", "pvp", "Subtlety, Dagger" },
                { "Tank", "pve", "Tank" },
                { "Restoration", "pve", "Restoration" },
                { "PvE", "pve", nil },
                { "PvP", "pvp", nil },
            }
            for _, case in ipairs(cases) do
                local mode, spec = Catalog.splitBuild(case[1])
                assert.are.equal(case[2], mode, case[1])
                assert.are.equal(case[3], spec, case[1])
            end
        end)

        it("lists the modes a class has, PvE first", function()
            local Catalog = loadCatalog()
            assert.are.same({ "pve", "pvp" }, Catalog.modes(Catalog.findClass("paladin")))
            assert.are.same({ "pve" }, Catalog.modes({ builds = { { "", "Tank", "" } } }))
        end)

        it("lists the builds of one mode with their spec names", function()
            local Catalog = loadCatalog()
            local specs = {}
            for _, entry in ipairs(Catalog.buildsForMode(Catalog.findClass("paladin"), "pvp")) do
                specs[#specs + 1] = entry.spec
            end
            assert.are.same({ "Retribution", "Holy" }, specs)
        end)

        it("keeps the spec when the mode changes, or falls back to the first build of that mode", function()
            local Catalog = loadCatalog()
            local paladin = Catalog.findClass("paladin")
            local holyPvE = Catalog.findBuild(paladin, "holy-pve")
            assert.are.equal("holy-pvp", Catalog.buildForMode(paladin, holyPvE, "pvp")[1])
            local tank = Catalog.findBuild(paladin, "tank")
            assert.are.equal("retribution-pvp", Catalog.buildForMode(paladin, tank, "pvp")[1])
            assert.is_nil(Catalog.buildForMode({ builds = { { "", "Tank", "" } } }, tank, "pvp"))
        end)
    end)

    describe("refreshBuilds", function()
        local function routes(Catalog, key)
            local result = {}
            for _, build in ipairs(Catalog.findClass(key).builds) do
                result[#result + 1] = build[3]
            end
            return result
        end

        it("replaces the builds of the classes the labels mention and keeps the others", function()
            local Catalog = loadCatalog({ druid = "Feral", ["druid/balance"] = "Balance" })
            assert.are.same({ "/balance", "" }, routes(Catalog, "druid"))
            assert.are.same({ "", "/pvp" }, routes(Catalog, "rogue"))
        end)

        it("restores the built-in builds before applying new labels", function()
            local Catalog = loadCatalog({ druid = "Feral", ["druid/balance"] = "Balance" })
            Catalog.refreshBuilds({ rogue = "Rogue" })
            assert.are.equal(6, #Catalog.findClass("druid").builds)
            assert.are.equal("feral-pve", Catalog.findClass("druid").builds[1][1])
            assert.are.same({ "" }, routes(Catalog, "rogue"))
        end)

        it("is idempotent when called repeatedly with the same labels", function()
            local labels = { druid = "Feral", ["druid/balance"] = "Balance" }
            local Catalog = loadCatalog(labels)
            local first = routes(Catalog, "druid")
            Catalog.refreshBuilds(labels)
            Catalog.refreshBuilds(labels)
            assert.are.same(first, routes(Catalog, "druid"))
        end)

        it("goes back to the built-in builds when called without labels", function()
            local Catalog = loadCatalog({ druid = "Feral" })
            Catalog.refreshBuilds(nil)
            assert.are.equal(6, #Catalog.findClass("druid").builds)
        end)
    end)
end)
