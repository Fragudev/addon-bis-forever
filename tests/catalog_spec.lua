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
end)
