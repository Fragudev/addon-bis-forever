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
            assert.is_table(ForeverBiSCharDB.collapsed)
        end)

        it("keeps the account-wide and per-character tables apart", function()
            local Settings = loadSettings(nil, nil)
            Settings.bind()
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            assert.is_table(ForeverBiSDB.minimap)
            assert.is_nil(ForeverBiSDB.class)
        end)

        it("keeps what the client already loaded", function()
            local collapsed = { ["druid:Head"] = true }
            local Settings = loadSettings({ class = "druid", build = "tank", collapsed = collapsed })
            Settings.bind()
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal(collapsed, ForeverBiSCharDB.collapsed)
        end)

        it("replaces a collapsed value that is not a table", function()
            local Settings = loadSettings({ collapsed = "broken" })
            Settings.bind()
            assert.are.same({}, ForeverBiSCharDB.collapsed)
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
            assert.are.equal("lvl60", Settings.phase())
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

        it("detects the player's class and resets the build only when the class changes", function()
            local Settings = loadSettings({ class = "rogue", build = "/pvp" })
            Settings.applyDetectedClass("DRUID")
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/balance", ForeverBiSCharDB.build)
            ForeverBiSCharDB.build = "/tank"
            Settings.applyDetectedClass("DRUID")
            assert.are.equal("/tank", ForeverBiSCharDB.build)
        end)

        it("does not detect over a class chosen by hand", function()
            local Settings = loadSettings({ class = "rogue", build = "pve", classChosen = true })
            Settings.applyDetectedClass("DRUID")
            assert.are.equal("rogue", ForeverBiSCharDB.class)
        end)

        it("ignores a missing or unknown class token", function()
            local Settings = loadSettings({ class = "rogue", build = "pve" })
            Settings.applyDetectedClass(nil)
            Settings.applyDetectedClass("DEATHKNIGHT")
            assert.are.equal("rogue", ForeverBiSCharDB.class)
        end)
    end)

    describe("phase", function()
        it("stores and clears the chosen phase", function()
            local Settings = loadSettings({})
            Settings.choosePhase("lvl30")
            assert.are.equal("lvl30", Settings.phase())
            Settings.choosePhase(nil)
            assert.is_nil(Settings.phase())
        end)

        it("reads a saved phase the route lacks as automatic without clearing it", function()
            local Settings = loadSettings({ phase = "no-such-phase" })
            assert.is_nil(Settings.activePhase("rogue"))
            assert.are.equal("no-such-phase", Settings.phase())
        end)

        it("shows the phase for the player's level when none is saved", function()
            local Settings = loadSettings({})
            assert.are.equal(ForeverBiSModel.effectivePhase("rogue", nil, 30), Settings.effectivePhase("rogue", 30))
        end)
    end)

    describe("collapsed sections", function()
        it("toggles and expands sections", function()
            local Settings = loadSettings({})
            Settings.bind()
            assert.is_false(Settings.isCollapsed("rogue:Head"))
            Settings.toggleCollapsed("rogue:Head")
            assert.is_true(Settings.isCollapsed("rogue:Head"))
            Settings.toggleCollapsed("rogue:Head")
            assert.is_false(Settings.isCollapsed("rogue:Head"))
            Settings.toggleCollapsed("rogue:Head")
            Settings.expand("rogue:Head")
            assert.is_false(Settings.isCollapsed("rogue:Head"))
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

        it("shows other classes only after toggling them on", function()
            local Settings = loadSettings({}, {})
            assert.is_false(Settings.tooltipAllClasses())
            assert.is_true(Settings.toggleTooltipAllClasses())
            assert.is_true(Settings.tooltipAllClasses())
            assert.is_false(Settings.toggleTooltipAllClasses())
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
