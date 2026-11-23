-- The "BiS" button on the inspect frame: it opens the window on the inspected player's class and spec and marks
-- what they wear with a blue border.

local savedTalents

local function inspectTalents(points)
    _G.GetTalentTabInfo = function(tab, isInspect)
        local spent = (isInspect and points or {})[tab]
        return tab, "Tree " .. tab, "", "icon" .. tab, spent or 0
    end
end

local function fireEvent(event, ...)
    for _, frame in ipairs(WowStub.frames) do
        if frame.events[event] then
            WowStub.fire(frame, "OnEvent", event, ...)
        end
    end
end

local function itemButton(itemId)
    return WowStub.find("Button", function(frame)
        return frame.bisItemId == itemId and frame.shown
    end)[1]
end

local function dataSlots(route, phase)
    return ForeverBiSData.sources.leveling.lists[route].phases[phase].slots
end

--- Loads the addon for a rogue player and puts a level 40 feral druid in the target, wearing `equipped`.
local function loadWithTarget(equipped, withInspectFrame)
    WowStub.load({ class = "rogue", build = "/combat", routeChosen = true }, function()
        if withInspectFrame then
            _G.InspectFrame = CreateFrame("Frame", nil, UIParent)
            _G.InspectFrame.unit = "target"
        end
    end)
    WowStub.units.target = { class = "Druid", token = "DRUID", level = 40, name = "Bear", equipped = equipped or {} }
    inspectTalents({ 0, 31, 0 })
end

local function loadInspectUI()
    _G.InspectFrame = CreateFrame("Frame", nil, UIParent)
    _G.InspectFrame.unit = "target"
    fireEvent("ADDON_LOADED", "Blizzard_InspectUI")
end

describe("Inspect button", function()
    before_each(function()
        savedTalents = _G.GetTalentTabInfo
    end)
    after_each(function()
        _G.GetTalentTabInfo = savedTalents
        _G.InspectFrame = nil
    end)

    it("is added to the inspect frame once the inspect UI loads, and only once", function()
        loadWithTarget()
        assert.is_nil(_G.ForeverBiSInspectButton)
        fireEvent("ADDON_LOADED", "SomeOtherAddon")
        assert.is_nil(_G.ForeverBiSInspectButton)
        loadInspectUI()
        local button = _G.ForeverBiSInspectButton
        assert.is_not_nil(button)
        assert.are.equal(_G.InspectFrame, button:GetParent())
        assert.are.equal("BiS", button:GetText())
        fireEvent("ADDON_LOADED", "Blizzard_InspectUI")
        assert.are.equal(button, _G.ForeverBiSInspectButton)
    end)

    it("is added right away when the inspect frame already exists", function()
        loadWithTarget(nil, true)
        assert.are.equal(_G.InspectFrame, _G.ForeverBiSInspectButton:GetParent())
    end)

    it("opens the window on the inspected player's class, spec and bracket", function()
        loadWithTarget()
        loadInspectUI()
        WowStub.fire(_G.ForeverBiSInspectButton, "OnClick")
        assert.is_true(ForeverBiSFrame:IsShown())
        assert.are.equal("Druid", ForeverBiSClassDropDown:GetText())
        assert.are.equal("Feral", ForeverBiSSpecDropDown:GetText())
        assert.are.equal("Auto (Level 40)", ForeverBiSBracketDropDown:GetText())
        assert.is_true(WowStub.hasText("Inspecting Bear"))
        -- The player's own selection is left alone.
        assert.are.equal("rogue", ForeverBiSCharDB.class)
        assert.are.equal("/combat", ForeverBiSCharDB.build)
    end)

    it("marks the inspected player's equipped items with a blue border", function()
        local head = dataSlots("druid/feral", "lvl40")[1]
        assert.are.equal("Head", head.slot)
        loadWithTarget({ [1] = head.items[3].id })
        loadInspectUI()
        -- What the player wears is not what the inspected player wears.
        WowStub.equipped[1] = head.items[1].id
        WowStub.fire(_G.ForeverBiSInspectButton, "OnClick")
        local worn = itemButton(head.items[3].id)
        assert.are.equal("inspected", worn.bisMark)
        local blue = { WowStub.ns.Theme.Color("accent") }
        assert.are.same({ blue[1], blue[2], blue[3] }, { unpack(worn.bisBorder.textures[1].colorTexture, 1, 3) })
        assert.is_nil(itemButton(head.items[1].id).bisMark)
    end)

    it("reads the inspected gear again when the inspect data arrives", function()
        local head = dataSlots("druid/feral", "lvl40")[1]
        loadWithTarget({})
        loadInspectUI()
        WowStub.fire(_G.ForeverBiSInspectButton, "OnClick")
        assert.is_nil(itemButton(head.items[2].id).bisMark)
        WowStub.units.target.equipped[1] = head.items[2].id
        fireEvent("INSPECT_READY", "guid")
        assert.are.equal("inspected", itemButton(head.items[2].id).bisMark)
    end)

    it("returns to the player's own list when the window closes", function()
        loadWithTarget()
        loadInspectUI()
        WowStub.fire(_G.ForeverBiSInspectButton, "OnClick")
        ForeverBiSFrame:Hide()
        WowStub.ns.openWindow()
        assert.are.equal("Rogue", ForeverBiSClassDropDown:GetText())
        assert.are.equal("Combat", ForeverBiSSpecDropDown:GetText())
        assert.is_false(WowStub.hasText("Inspecting Bear"))
    end)

    it("keeps the inspected view while its spec or bracket changes, without saving them", function()
        loadWithTarget()
        loadInspectUI()
        WowStub.fire(_G.ForeverBiSInspectButton, "OnClick")
        for _, entry in ipairs(ForeverBiSSpecDropDown.getItems()) do
            if entry.text == "Balance" then
                entry.func()
            end
        end
        assert.are.equal("Balance", ForeverBiSSpecDropDown:GetText())
        assert.is_true(WowStub.hasText("Inspecting Bear"))
        assert.are.equal("/combat", ForeverBiSCharDB.build)
        assert.is_nil(ForeverBiSCharDB.phase)
    end)
end)
