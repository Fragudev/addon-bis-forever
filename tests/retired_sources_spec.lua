-- The generated leveling lists are the only shipped source: a saved source the addon no longer ships
-- (ForeverChanges, the wowsims presets) reads the leveling lists, and there is no source picker or dropdown.

local function openWindow()
    WowStub.fire(ForeverBiSMinimapButton, "OnClick")
end

local function shippedIds()
    local ids = {}
    for _, source in ipairs(ForeverBiSModel.sources()) do
        ids[#ids + 1] = source.id
    end
    return ids
end

describe("Retired data sources", function()
    it("ships the generated leveling lists as the only source", function()
        WowStub.load({ source = false })
        assert.are.same({ "leveling" }, shippedIds())
        assert.are.equal("leveling", ForeverBiSModel.DEFAULT_SOURCE)
        assert.are.equal("leveling", ForeverBiSModel.activeSource())
    end)

    for _, retired in ipairs({ "foreverchanges", "wowsims" }) do
        it("reads the leveling lists when the saved source is " .. retired, function()
            assert.has_no.errors(function()
                WowStub.load({ source = retired, class = "rogue", build = "" })
                openWindow()
            end)
            assert.are.equal("leveling", ForeverBiSModel.activeSource())
            assert.is_not_nil(ForeverBiSModel.list((WowStub.ns.Settings.route())))
            assert.is_true(WowStub.hasText("HEAD"))
        end)

        it("keeps the saved " .. retired .. " id untouched", function()
            WowStub.load({ source = retired })
            openWindow()
            assert.are.equal(retired, ForeverBiSDB.source)
        end)
    end

    it("opens straight on the lists, with no source picker or source dropdown", function()
        WowStub.load({ source = false })
        openWindow()
        assert.is_nil(_G.ForeverBiSSourcePicker)
        assert.is_nil(_G.ForeverBiSSourcePickerDropDown)
        assert.is_nil(_G.ForeverBiSSourceDropDown)
        assert.is_nil(WowStub.ns.SourcePicker)
        assert.is_false(WowStub.hasText("Choose a data source"))
        assert.is_true(WowStub.hasText("HEAD"))
    end)

    it("starts the selector row with the class label, centered on the dropdowns", function()
        WowStub.load(nil)
        local label
        for _, fontString in ipairs(WowStub.fontStrings) do
            if fontString.text == "CLASS" then
                label = fontString
            end
        end
        local input = WowStub.ns.Theme.metrics.input
        assert.are.same({ "LEFT", ForeverBiSFrame, "TOPLEFT", 20, -64 - input / 2 }, label.points[1])
    end)
end)
