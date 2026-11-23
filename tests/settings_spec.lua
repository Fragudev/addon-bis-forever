--- character seeds ForeverBiSCharDB and account seeds ForeverBiSDB.
local function loadSettings(character, account)
    WowStub.reset()
    _G.ForeverBiSCharDB = character
    _G.ForeverBiSDB = account
    WowStub.loadFiles({
        "ForeverBiS_Data_Leveling.lua",
        "ForeverBiS_Model.lua",
        "Core/Settings.lua",
        "Core/Catalog.lua",
    })
    return WowStub.ns.Settings
end

describe("Settings", function()
    after_each(function()
        _G.ForeverBiSDB, _G.ForeverBiSCharDB = nil, nil
    end)

    describe("bind", function()
        it("creates the saved variables with the rogue as the default class", function()
            local Settings = loadSettings(nil)
            Settings.bind()
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            -- The leveling lists have no bare "rogue" route, so the first build by label is the default.
            assert.are.equal("/assassination", ForeverBiSCharDB.build)
            assert.is_table(ForeverBiSDB.minimap)
            assert.is_nil(ForeverBiSCharDB.collapsed)
        end)

        it("keeps the account-wide and per-character tables apart", function()
            local Settings = loadSettings(nil, nil)
            Settings.bind()
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            assert.is_table(ForeverBiSDB.minimap)
            assert.is_nil(ForeverBiSDB.class)
        end)

        it("keeps what the client already loaded", function()
            local Settings = loadSettings({ class = "druid", build = "tank", phase = "lvl40", routeChosen = true })
            Settings.bind()
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("lvl40", ForeverBiSCharDB.phase)
            assert.is_true(ForeverBiSCharDB.routeChosen)
        end)

        it("follows a saved variables table the client swaps in later", function()
            local Settings = loadSettings({ class = "mage" })
            Settings.bind()
            _G.ForeverBiSCharDB = { class = "hunter" }
            Settings.bind()
            assert.are.equal("hunter", Settings.classKey())
        end)
    end)

    describe("migrate", function()
        local function account()
            return { class = "druid", build = "/tank", phase = "lvl30", classChosen = true, minimap = { angle = 90 } }
        end

        it("moves the account-wide selection into the character", function()
            local Settings = loadSettings(nil, account())
            Settings.migrate()
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/tank", ForeverBiSCharDB.build)
            assert.are.equal("lvl30", ForeverBiSCharDB.phase)
            assert.is_true(ForeverBiSCharDB.classChosen)
        end)

        it("keeps minimap and tooltip settings account-wide", function()
            local Settings = loadSettings(nil, account())
            Settings.migrate()
            assert.are.equal(90, ForeverBiSDB.minimap.angle)
            assert.is_nil(ForeverBiSDB.class)
            assert.is_nil(ForeverBiSDB.build)
        end)

        it("only migrates once: a second character starts fresh", function()
            local Settings = loadSettings(nil, account())
            Settings.migrate()
            local sharedAccount = ForeverBiSDB
            _G.ForeverBiSCharDB = nil
            _G.ForeverBiSDB = sharedAccount
            Settings.migrate()
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            assert.is_nil(ForeverBiSCharDB.classChosen)
        end)

        it("does not overwrite a character that was already migrated", function()
            local Settings = loadSettings({ class = "mage", build = "pve", migrated = true }, account())
            Settings.migrate()
            assert.are.equal("mage", ForeverBiSCharDB.class)
            assert.are.equal("druid", ForeverBiSDB.class)
        end)

        it("gives two characters their own selection", function()
            local Settings = loadSettings({ class = "mage", build = "pve", migrated = true }, {})
            local alt = { class = "hunter", build = "pve", migrated = true }
            local main = ForeverBiSCharDB
            _G.ForeverBiSCharDB = alt
            Settings.chooseClass(WowStub.ns.Catalog.findClass("druid"))
            assert.are.equal("druid", alt.class)
            assert.are.equal("mage", main.class)
        end)
    end)

    describe("get", function()
        it("reads a saved value", function()
            local Settings = loadSettings({}, { tooltip = false })
            assert.is_false(Settings.get("tooltip"))
        end)

        it("returns nil while the saved variables are unavailable", function()
            local Settings = loadSettings(nil)
            assert.is_nil(Settings.get("tooltip"))
        end)
    end)

    describe("route", function()
        it("resolves unknown keys to a route without writing them back", function()
            local Settings = loadSettings({ class = "not-a-class", build = "not-a-build" })
            local route, class, build = Settings.route()
            assert.are.equal("rogue/assassination", route)
            assert.are.equal("rogue", class.key)
            assert.are.equal("/assassination", build[1]) -- the class's first build by label
            assert.are.equal("not-a-class", ForeverBiSCharDB.class)
            assert.are.equal("not-a-build", ForeverBiSCharDB.build)
        end)

        it("honours a build and phase saved by an older version, which has no per-source memory", function()
            local Settings = loadSettings({ class = "druid", build = "/tank", phase = "lvl60" })
            Settings.bind()
            assert.are.equal("druid/tank", (Settings.route()))
            assert.are.equal("lvl60", ForeverBiSCharDB.phase)
            assert.is_nil(ForeverBiSCharDB.bySource)
        end)

        it("includes the build suffix", function()
            local Settings = loadSettings({ class = "druid", build = "/tank" })
            assert.are.equal("druid/tank", (Settings.route()))
        end)
    end)

    describe("class and build choices", function()
        it("chooses a class with its default build and stops auto-detection", function()
            local Settings = loadSettings({ class = "rogue", build = "/pvp" })
            Settings.chooseClass(WowStub.ns.Catalog.findClass("druid"))
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/balance", ForeverBiSCharDB.build)
            assert.is_true(ForeverBiSCharDB.classChosen)
        end)

        it("chooses a build without touching the class", function()
            local Settings = loadSettings({ class = "druid", build = "feral-pve" })
            Settings.chooseBuild("/tank")
            assert.are.equal("druid", Settings.classKey())
            assert.are.equal("/tank", Settings.buildKey())
        end)

        it("marks a class or spec picked by hand as chosen", function()
            local Settings = loadSettings({ class = "rogue", build = "/combat" })
            assert.is_false(Settings.routeChosen())
            Settings.chooseBuild("/subtlety")
            assert.is_true(Settings.routeChosen())
            local other = loadSettings({ class = "rogue", build = "/combat" })
            other.chooseClass(WowStub.ns.Catalog.findClass("mage"))
            assert.is_true(ForeverBiSCharDB.routeChosen)
        end)

        it("applies the detected spec while none was chosen by hand", function()
            local Settings = loadSettings({ class = "rogue", build = "/combat" })
            assert.is_true(Settings.applyDetectedRoute("DRUID", "druid/restoration"))
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/restoration", ForeverBiSCharDB.build)
            assert.is_nil(ForeverBiSCharDB.routeChosen)
        end)

        it("falls back to the class's first spec without a detected route", function()
            local Settings = loadSettings({ class = "rogue", build = "/combat" })
            Settings.applyDetectedRoute("DRUID", nil)
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/balance", ForeverBiSCharDB.build)
            -- A route of another class or one the lists lack counts as no route.
            Settings.applyDetectedRoute("MAGE", "druid/feral")
            assert.are.equal("mage", ForeverBiSCharDB.class)
            assert.are.equal("/arcane", ForeverBiSCharDB.build)
            -- Without a route, the spec of an already selected class stays.
            ForeverBiSCharDB.build = "/frost"
            assert.is_false(Settings.applyDetectedRoute("MAGE", nil))
            assert.are.equal("/frost", ForeverBiSCharDB.build)
        end)

        it("keeps a class chosen by hand in an older version", function()
            local Settings = loadSettings({ class = "druid", build = "pve", classChosen = true })
            assert.is_true(Settings.routeChosen())
            assert.is_false(Settings.applyDetectedRoute("ROGUE", "rogue/combat"))
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("pve", ForeverBiSCharDB.build)
        end)

        it("never detects over a spec chosen by hand", function()
            local Settings = loadSettings({ class = "rogue", build = "/combat" })
            Settings.applyDetectedRoute("DRUID", "druid/feral")
            assert.are.equal("druid", ForeverBiSCharDB.class)
            Settings.chooseBuild("/tank")
            assert.is_false(Settings.applyDetectedRoute("MAGE", "mage/fire"))
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/tank", ForeverBiSCharDB.build)
        end)

        it("ignores a missing or unknown class token", function()
            local Settings = loadSettings({ class = "rogue", build = "/combat" })
            assert.is_false(Settings.applyDetectedRoute(nil, nil))
            assert.is_false(Settings.applyDetectedRoute("DEATHKNIGHT", nil))
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            assert.are.equal("/combat", ForeverBiSCharDB.build)
        end)
    end)

    describe("phase", function()
        it("stores and clears the chosen phase", function()
            local Settings = loadSettings({})
            Settings.choosePhase("lvl30")
            assert.are.equal("lvl30", ForeverBiSCharDB.phase)
            Settings.choosePhase(nil)
            assert.is_nil(ForeverBiSCharDB.phase)
        end)

        it("reads a saved phase the route lacks as automatic without clearing it", function()
            local Settings = loadSettings({ phase = "no-such-phase" })
            assert.is_nil(Settings.activePhase("rogue"))
            assert.are.equal("no-such-phase", ForeverBiSCharDB.phase)
        end)

        it("picks the bracket at or below the player's level unless one is saved", function()
            local Settings = loadSettings({})
            assert.are.equal("lvl30", Settings.bracket("rogue/combat", 39))
            assert.are.equal("lvl20", Settings.bracket("rogue/combat", 5))
            Settings.choosePhase("lvl50")
            assert.are.equal("lvl50", Settings.bracket("rogue/combat", 39))
            Settings.choosePhase("no-such-phase")
            assert.are.equal("lvl40", Settings.bracket("rogue/combat", 45))
        end)
    end)

    describe("minimap", function()
        it("defaults to 220 degrees and visible", function()
            local Settings = loadSettings({}, {})
            assert.are.equal(220, Settings.minimapAngle())
            assert.is_false(Settings.minimapHidden())
        end)

        it("stores the angle and honors the hide flag", function()
            local Settings = loadSettings({}, { minimap = { hide = true } })
            Settings.setMinimapAngle(90)
            assert.are.equal(90, Settings.minimapAngle())
            assert.is_true(Settings.minimapHidden())
        end)
    end)

    describe("tooltip", function()
        it("is on by default and toggles", function()
            local Settings = loadSettings({}, {})
            assert.is_true(Settings.tooltipEnabled())
            assert.is_false(Settings.toggleTooltip())
            assert.is_false(Settings.tooltipEnabled())
            assert.is_true(Settings.toggleTooltip())
        end)

        it("turns every tooltip block and compact mode on by default and toggles each one alone", function()
            local Settings = loadSettings({}, {})
            for _, name in ipairs({ "spec", "specs", "classes", "compact" }) do
                assert.is_true(Settings.tooltipOption(name))
            end
            assert.is_false(Settings.toggleTooltipOption("specs"))
            assert.is_false(Settings.tooltipOption("specs"))
            assert.is_false(ForeverBiSDB.tooltipSpecs)
            assert.is_true(Settings.tooltipOption("spec"))
            assert.is_true(Settings.tooltipOption("classes"))
            assert.is_true(Settings.toggleTooltipOption("specs"))
            assert.is_true(Settings.tooltipOption("specs"))
        end)

        it("stores each option under its own account-wide key", function()
            local Settings = loadSettings({}, {})
            Settings.toggleTooltipOption("spec")
            Settings.toggleTooltipOption("classes")
            Settings.toggleTooltipOption("compact")
            assert.are.same({ false, false, false }, {
                ForeverBiSDB.tooltipSpec,
                ForeverBiSDB.tooltipClasses,
                ForeverBiSDB.tooltipCompact,
            })
            assert.is_nil(ForeverBiSCharDB.tooltipSpec)
        end)

        it("rejects unknown options and reads options before the saved variables exist", function()
            local Settings = loadSettings(nil, nil)
            assert.is_true(Settings.tooltipOption("classes"))
            assert.is_nil(Settings.tooltipOption("bogus"))
            Settings.bind()
            assert.is_nil(Settings.toggleTooltipOption("bogus"))
            assert.is_nil(ForeverBiSDB.bogus)
        end)
    end)

    describe("data sources", function()
        local TwoSources = dofile("tests/support/sources.lua")

        -- Loads the model and Settings over the two-source fixture (alpha is active at load: no default source).
        local function loadTwoSources(character, account)
            WowStub.reset()
            _G.ForeverBiSData = TwoSources.twoSources()
            _G.ForeverBiSCharDB = character
            _G.ForeverBiSDB = account
            WowStub.loadFiles({ "ForeverBiS_Model.lua", "Core/Settings.lua", "Core/Catalog.lua" })
            return WowStub.ns.Settings
        end

        after_each(function()
            _G.ForeverBiSData = nil
        end)

        it("reads the active source from the model and saves no source", function()
            local Settings = loadTwoSources({ class = "rogue", build = "" })
            Settings.bind()
            assert.are.equal("alpha", Settings.activeSource())
            assert.is_nil(ForeverBiSDB.source)
        end)

        it("answers without saved variables", function()
            local Settings = loadTwoSources()
            assert.are.equal("alpha", Settings.activeSource())
        end)

        describe("bind", function()
            it("activates a saved source that is available", function()
                local Settings = loadTwoSources({ class = "rogue", build = "" }, { source = "beta" })
                Settings.bind()
                assert.are.equal("beta", Settings.activeSource())
                assert.are.equal("Beta Rogue", ForeverBiSBuildLabels.rogue)
                assert.are.equal(
                    "Beta Rogue",
                    WowStub.ns.Catalog.findBuild(WowStub.ns.Catalog.findClass("rogue"), "")[2]
                )
            end)

            it("falls back to the default source for an unavailable one and keeps the saved id", function()
                local Settings = loadTwoSources({ class = "rogue", build = "" }, { source = "gone" })
                ForeverBiSModel.select("beta")
                Settings.bind()
                assert.are.equal("alpha", Settings.activeSource())
                assert.are.equal("gone", ForeverBiSDB.source)
            end)

            it("uses the default source when nothing is saved", function()
                local Settings = loadTwoSources({ class = "rogue", build = "" })
                ForeverBiSModel.select("beta")
                Settings.bind()
                assert.are.equal("alpha", Settings.activeSource())
            end)
        end)
    end)
end)
