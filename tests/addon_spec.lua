-- The addon as the client loads it: saved selection, login detection, slash command, render requests and the
-- minimap button. The BiS window itself is covered by bisgrid_spec.

local function login()
    for _, candidate in ipairs(WowStub.frames) do
        if candidate.events.PLAYER_LOGIN then
            return WowStub.fire(candidate, "OnEvent", "PLAYER_LOGIN")
        end
    end
    error("no PLAYER_LOGIN watcher")
end

describe("ForeverBiS", function()
    describe("loading", function()
        it("registers the /bis and /foreverbis slash commands", function()
            WowStub.load(nil)
            assert.are.equal("/bis", _G.SLASH_FOREVERBIS1)
            assert.are.equal("/foreverbis", _G.SLASH_FOREVERBIS2)
            assert.is_function(_G.SlashCmdList["FOREVERBIS"])
        end)

        it("starts hidden and defaults to the rogue's first leveling list", function()
            WowStub.load(nil)
            assert.is_false(ForeverBiSFrame:IsShown())
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            assert.are.equal("/assassination", ForeverBiSCharDB.build) -- the first rogue build by label
        end)

        it("falls back to a valid class and build when the saved ones are unknown", function()
            WowStub.load({ class = "not-a-class", build = "not-a-build" })
            assert.are.equal("rogue", ForeverBiSCharDB.class)
            assert.are.equal("/assassination", ForeverBiSCharDB.build)
        end)

        it("keeps a valid saved class and build", function()
            WowStub.load({ class = "druid", build = "/tank" })
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/tank", ForeverBiSCharDB.build)
        end)

        it("no longer builds the paper doll, progress bar, filter bar or item list", function()
            WowStub.load(nil)
            for _, removed in ipairs({ "PaperDoll", "Progress", "FilterBar", "ItemList", "ItemRows", "Filters" }) do
                assert.is_nil(WowStub.ns[removed], removed)
            end
            assert.is_nil(_G.ForeverBiSModeDropDown)
            assert.is_nil(_G.ForeverBiSScroll)
        end)
    end)

    describe("spec auto-detection on login", function()
        local druid = { class = "Druid", token = "DRUID", level = 20 }

        it("selects the player's class and its first spec without talent points", function()
            WowStub.load({ class = "rogue", build = "/combat" }, nil, druid)
            WowStub.ns.MainFrame.open()
            login()
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/balance", ForeverBiSCharDB.build)
            assert.is_nil(ForeverBiSCharDB.routeChosen)
            assert.are.equal("Druid", ForeverBiSClassDropDown.menuText)
        end)

        it("keeps the spec when the detected class is already selected and no talent says otherwise", function()
            WowStub.load({ class = "druid", build = "/tank" }, nil, druid)
            login()
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/tank", ForeverBiSCharDB.build)
        end)

        it("never overrides a class or spec the user chose", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true }, nil, druid)
            login()
            assert.are.equal("rogue", ForeverBiSCharDB.class)
        end)

        it("ignores a class token the addon does not know", function()
            WowStub.load(
                { class = "mage", build = "" },
                nil,
                { class = "Death Knight", token = "DEATHKNIGHT", level = 20 }
            )
            login()
            assert.are.equal("mage", ForeverBiSCharDB.class)
        end)

        it("uses the saved variables the client loaded after the files ran", function()
            WowStub.load(nil, nil, druid)
            _G.ForeverBiSDB = { class = "hunter", build = "", phase = "lvl40" }
            _G.ForeverBiSCharDB = { routeChosen = true }
            login()
            assert.are.equal("hunter", ForeverBiSCharDB.class)
            assert.are.equal("lvl40", ForeverBiSCharDB.phase)
            assert.is_table(ForeverBiSDB.minimap)
        end)

        it("creates the saved variables when the client provides none", function()
            WowStub.load(nil, nil, druid)
            _G.ForeverBiSDB = nil
            login()
            assert.are.equal("druid", ForeverBiSCharDB.class)
        end)

        it("re-applies a hidden minimap button", function()
            WowStub.load(nil, nil, druid)
            _G.ForeverBiSDB = { class = "rogue", build = "", minimap = { hide = true } }
            login()
            assert.is_false(ForeverBiSMinimapButton:IsShown())
        end)
    end)

    describe("slash command", function()
        it("toggles the main window", function()
            WowStub.load(nil)
            _G.SlashCmdList["FOREVERBIS"]()
            assert.is_true(ForeverBiSFrame:IsShown())
            _G.SlashCmdList["FOREVERBIS"]()
            assert.is_false(ForeverBiSFrame:IsShown())
        end)
    end)

    describe("render requests", function()
        local function wrapGrid(replacement)
            local grid = WowStub.ns.BisGrid
            local refresh = grid.refresh
            grid.refresh = function(...)
                return replacement(refresh, ...)
            end
            return function()
                grid.refresh = refresh
            end
        end

        it("does no work while the window is hidden and draws on the next show", function()
            WowStub.load(nil)
            local draws = 0
            wrapGrid(function(refresh, ...)
                draws = draws + 1
                return refresh(...)
            end)
            WowStub.ns.requestRender()
            assert.are.equal(0, draws)
            WowStub.ns.MainFrame.open()
            assert.are.equal(1, draws)
        end)

        it("runs a request made while drawing once, after the current draw", function()
            WowStub.load(nil)
            WowStub.ns.MainFrame.open()
            local draws, requested = 0, false
            wrapGrid(function(refresh, ...)
                draws = draws + 1
                if not requested then
                    requested = true
                    WowStub.ns.requestRender()
                end
                return refresh(...)
            end)
            WowStub.ns.requestRender()
            assert.are.equal(2, draws)
        end)

        it("keeps accepting requests after a draw fails", function()
            WowStub.load(nil)
            WowStub.ns.MainFrame.open()
            local restore = wrapGrid(function()
                error("boom", 0)
            end)
            assert.has_error(function()
                WowStub.ns.requestRender()
            end, "boom")
            restore()
            assert.has_no.errors(function()
                WowStub.ns.requestRender()
            end)
        end)
    end)

    describe("minimap button", function()
        it("toggles the window on click", function()
            WowStub.load(nil)
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_true(ForeverBiSFrame:IsShown())
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_false(ForeverBiSFrame:IsShown())
        end)

        it("ignores the click that ends a drag", function()
            WowStub.load(nil)
            WowStub.fire(ForeverBiSMinimapButton, "OnDragStart")
            ForeverBiSMinimapButton.dragMoved = true
            WowStub.fire(ForeverBiSMinimapButton, "OnDragStop")
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_false(ForeverBiSFrame:IsShown())
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_true(ForeverBiSFrame:IsShown())
        end)

        it("is hidden when the saved settings say so", function()
            WowStub.load({ minimap = { hide = true } })
            assert.is_false(ForeverBiSMinimapButton:IsShown())
        end)
    end)
end)
