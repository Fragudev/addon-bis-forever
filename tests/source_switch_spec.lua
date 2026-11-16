local TwoSources = dofile("tests/support/sources.lua")

local function chooseOption(dropdown, label)
    for _, info in ipairs(dropdown.getItems()) do
        if info.text == label then
            return info.func()
        end
    end
    error("no menu entry " .. label)
end

local function load(account, player)
    WowStub.load(account, function(data)
        data.sources = TwoSources.twoSources().sources
    end, player)
    WowStub.fire(ForeverBiSMinimapButton, "OnClick")
end

local druid = { class = "Druid", token = "DRUID", level = 30 }

describe("Switching the data source", function()
    describe("saved build and phase", function()
        it("restores a build only the first source lists when switching A -> B -> A", function()
            load({ source = "alpha", class = "druid", build = "/balance" }, druid)
            assert.is_true(WowStub.hasText("Alpha Cowl"))
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            assert.is_true(WowStub.hasText("Beta has no list for this class yet."))
            chooseOption(ForeverBiSSourceDropDown, "Alpha")
            assert.are.equal("/balance", ForeverBiSCharDB.build)
            assert.is_true(WowStub.hasText("Alpha Cowl"))
            assert.are.equal("Balance", ForeverBiSBuildDropDown.menuText)
        end)

        it("restores a phase only the first source has when switching A -> B -> A", function()
            load({ source = "alpha", class = "rogue", build = "" })
            chooseOption(ForeverBiSPhaseDropDown, "Level 30")
            assert.are.equal("lvl30", ForeverBiSCharDB.phase)
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            assert.is_nil(ForeverBiSCharDB.phase)
            chooseOption(ForeverBiSSourceDropDown, "Alpha")
            assert.are.equal("lvl30", ForeverBiSCharDB.phase)
        end)

        it("does not rewrite the saved selection while rendering", function()
            load({ source = "alpha", class = "druid", build = "/balance" }, druid)
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            ForeverBiSCharDB.build = "unknown-build"
            WowStub.ns.requestRender()
            assert.are.equal("unknown-build", ForeverBiSCharDB.build)
        end)
    end)

    describe("legacy globals and the tooltip index", function()
        it("follow the active source", function()
            load({ source = "alpha", class = "rogue", build = "" })
            assert.are.equal("Alpha Mask", ForeverBiSLists.rogue.slots[1][2][1][1])
            assert.are.equal(13, ForeverBiSItemIDs["Alpha Mask"])
            assert.are.equal(1, #ForeverBiSModel.bisEntries(13))
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            assert.are.equal("Beta Mask", ForeverBiSLists.rogue.slots[1][2][1][1])
            assert.is_nil(ForeverBiSLists.druid)
            assert.is_nil(ForeverBiSItemIDs["Alpha Mask"])
            assert.are.equal(21, ForeverBiSItemIDs["Beta Mask"])
            assert.are.same({}, ForeverBiSModel.bisEntries(13))
            assert.are.equal(1, #ForeverBiSModel.bisEntries(21))
        end)
    end)

    describe("dropdown widths", function()
        local function countFits()
            local counter = { calls = 0 }
            local Dropdown = WowStub.ns.Dropdown
            local real = Dropdown.fit
            Dropdown.fit = function(...)
                counter.calls = counter.calls + 1
                return real(...)
            end
            return counter
        end

        it("are not recomputed by a plain re-render", function()
            load({ source = "alpha", class = "rogue", build = "" })
            local counter = countFits()
            WowStub.ns.requestRender()
            WowStub.ns.requestRender()
            assert.are.equal(0, counter.calls)
        end)

        it("are recomputed after a choice changes what the dropdowns offer", function()
            load({ source = "alpha", class = "rogue", build = "" })
            local counter = countFits()
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            assert.is_true(counter.calls > 0)
        end)
    end)
end)
