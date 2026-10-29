local TwoSources = dofile("tests/support/sources.lua")

local function chooseOption(dropdown, label)
    for _, info in ipairs(dropdown.getItems()) do
        if info.text == label then
            return info.func()
        end
    end
    error("no menu entry " .. label)
end

local function labels(dropdown)
    local result = {}
    for _, info in ipairs(dropdown.getItems()) do
        table.insert(result, info.text)
    end
    return result
end

-- Loads the addon over the two-source fixture. `account` seeds the saved source (`source = false` means none).
local function load(account, player)
    WowStub.load(account, function(data)
        data.sources = TwoSources.twoSources().sources
    end, player)
end

local function openWindow()
    WowStub.fire(ForeverBiSMinimapButton, "OnClick")
end

describe("Source picker", function()
    describe("first open", function()
        before_each(function()
            load({ source = false })
            openWindow()
        end)

        it("shows the picker with a prompt and one entry per source", function()
            assert.is_true(ForeverBiSSourcePicker:IsShown())
            assert.is_true(WowStub.hasText("Choose a data source"))
            assert.are.same({ "Alpha", "Beta" }, labels(ForeverBiSSourcePickerDropDown))
        end)

        it("draws none of the panels behind it", function()
            assert.is_false(WowStub.hasText("Alpha Mask"))
            assert.is_false(WowStub.hasText("HEAD"))
            assert.is_false(WowStub.hasText("BiS 0/"))
        end)

        it("saves nothing until a source is picked", function()
            assert.is_falsy(ForeverBiSDB.source)
        end)

        it("persists the choice, hides the picker and renders the lists", function()
            chooseOption(ForeverBiSSourcePickerDropDown, "Beta")
            assert.are.equal("beta", ForeverBiSDB.source)
            assert.is_false(ForeverBiSSourcePicker:IsShown())
            assert.is_true(WowStub.hasText("Beta Mask"))
            assert.is_true(WowStub.hasText("Beta"))
            assert.are.equal("Beta", ForeverBiSSourceDropDown.menuText)
        end)

        it("ignores a picker entry the settings refuse", function()
            local entries = ForeverBiSSourcePickerDropDown.getItems()
            ForeverBiSData.sources.alpha = nil
            entries[1].func()
            assert.is_falsy(ForeverBiSDB.source)
            assert.is_true(ForeverBiSSourcePicker:IsShown())
        end)
    end)

    describe("returning player", function()
        it("opens with the saved source and no picker", function()
            load({ source = "beta" })
            openWindow()
            assert.is_false(ForeverBiSSourcePicker:IsShown())
            assert.is_true(WowStub.hasText("Beta Mask"))
            assert.are.equal("Beta", ForeverBiSSourceDropDown.menuText)
        end)

        it("shows the picker again when the saved source is no longer shipped", function()
            load({ source = "gone" })
            openWindow()
            assert.is_true(ForeverBiSSourcePicker:IsShown())
        end)

        it("skips the picker when the data carries no sources at all", function()
            WowStub.load({ source = false }, function()
                _G.ForeverBiSData = nil
            end)
            openWindow()
            assert.is_false(ForeverBiSSourcePicker:IsShown())
        end)
    end)

    describe("header dropdown", function()
        before_each(function()
            load({ source = "alpha" })
            openWindow()
        end)

        it("leads the selector row and lists every source with the active one checked", function()
            assert.are.equal("Alpha", ForeverBiSSourceDropDown.menuText)
            local items = ForeverBiSSourceDropDown.getItems()
            assert.are.same({ "Alpha", "Beta" }, labels(ForeverBiSSourceDropDown))
            assert.is_true(items[1].checked)
            assert.is_false(items[2].checked)
        end)

        it("switches source, saves it and re-renders the lists", function()
            assert.is_true(WowStub.hasText("Alpha Mask"))
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            assert.are.equal("beta", ForeverBiSDB.source)
            assert.is_true(WowStub.hasText("Beta Mask"))
            assert.is_false(WowStub.hasText("Alpha Mask"))
            assert.are.equal("Beta", ForeverBiSSourceDropDown.menuText)
        end)
    end)

    describe("missing list", function()
        it("explains that the source has no list for the class", function()
            load(
                { source = "alpha", class = "druid", build = "feral-pve" },
                { class = "Druid", token = "DRUID", level = 30 }
            )
            openWindow()
            assert.is_true(WowStub.hasText("Alpha Hood"))
            chooseOption(ForeverBiSSourceDropDown, "Beta")
            -- Switching resets an unavailable build; the druid has no list at all in Beta.
            assert.is_true(WowStub.hasText("Beta has no list for this class yet."))
            assert.is_false(WowStub.hasText("Alpha Hood"))
        end)
    end)
end)
