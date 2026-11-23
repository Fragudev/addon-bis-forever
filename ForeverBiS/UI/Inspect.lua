-- The "BiS" button on the client's inspect window: it opens the BiS window on the inspected player's class and the
-- spec of their talents, with their equipped items in a blue border. The inspect window belongs to the
-- Blizzard_InspectUI addon, which loads on first use, so the button is added once that addon has loaded.
local _, ns = ...

local Inspect = {}
ns.Inspect = Inspect

local Selectors, Inventory, Player, Skin, L = ns.Selectors, ns.Inventory, ns.Player, ns.Skin, ns.L

local INSPECT_ADDON = "Blizzard_InspectUI"

local button

--- The unit the inspect window shows; the client's own InspectFrame already ran NotifyInspect on it.
local function inspectedUnit()
    return InspectFrame and InspectFrame.unit or "target"
end

--- Everything the window needs about the unit, read now: the unit can change while the window stays open.
local function readUnit(unit)
    local _, classToken = UnitClass(unit)
    if not classToken then
        return nil
    end
    return {
        unit = unit,
        name = UnitName(unit),
        classToken = classToken,
        -- The inspect talents: GetTalentTabInfo with its inspect flag reads the unit NotifyInspect asked for.
        route = Player.specRoute(classToken, true),
        level = UnitLevel(unit),
        worn = Inventory.wornBy(unit),
    }
end

--- Opens the window on the inspected unit (the inspect window's unit by default). Returns whether it could.
function Inspect.open(unit)
    local target = readUnit(unit or inspectedUnit())
    if not target then
        return false
    end
    Selectors.inspect(target)
    if ns.MainFrame.isShown() then
        ns.requestRender()
    else
        ns.openWindow()
    end
    return true
end

--- The inspect data arrives after the inspect window opens: read the inspected gear again while it is shown.
function Inspect.onInspectReady()
    local inspected = Selectors.inspected()
    if not (inspected and inspected.unit and ns.MainFrame.isShown()) then
        return
    end
    if UnitName(inspected.unit) ~= inspected.name then
        return -- the unit now points at someone else
    end
    inspected.worn = Inventory.wornBy(inspected.unit)
    ns.requestRender()
end

--- Adds the button to the inspect window once it exists. Safe to call again.
function Inspect.attach()
    if button or not InspectFrame then
        return button
    end
    button = CreateFrame("Button", "ForeverBiSInspectButton", InspectFrame)
    button:SetSize(52, 22)
    button:SetPoint("TOPRIGHT", InspectFrame, "TOPRIGHT", -44, -44)
    button:SetFrameLevel(InspectFrame:GetFrameLevel() + 10)
    Skin.button(button, "primary")
    button:SetText(L["BiS"])
    button:SetScript("OnClick", function()
        Inspect.open()
    end)
    return button
end

function Inspect.install()
    button = nil
    Inspect.attach()
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("ADDON_LOADED")
    watcher:RegisterEvent("INSPECT_READY")
    watcher:SetScript("OnEvent", function(_, event, name)
        if event == "ADDON_LOADED" and name == INSPECT_ADDON then
            Inspect.attach()
        elseif event == "INSPECT_READY" then
            Inspect.onInspectReady()
        end
    end)
end
