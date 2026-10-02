-- The class, build and phase dropdowns.
local _, ns = ...

local Selectors = {}
ns.Selectors = Selectors

local Catalog, Settings, Player = ns.Catalog, ns.Settings, ns.Player

local classDrop, buildDrop, phaseDrop

local function labelOf(phases, phaseId)
    for _, phase in ipairs(phases) do
        if phase.id == phaseId then
            return phase.label or phase.id
        end
    end
    return phaseId
end

local function routePhases()
    local route = Settings.route()
    return ForeverBiSModel and ForeverBiSModel.phases(route) or {}, route
end

--- Every selection change redraws from the top of the list.
local function selected()
    ns.requestRender({ scrollTop = true })
end

local function addItem(text, checked, onSelect, level)
    local info = UIDropDownMenu_CreateInfo()
    info.text, info.checked = text, checked
    info.func = onSelect
    UIDropDownMenu_AddButton(info, level)
end

local function initClassMenu(_, level)
    for _, class in ipairs(Catalog.classes) do
        addItem(class.label, class.key == Settings.classKey(), function()
            Settings.chooseClass(class)
            selected()
        end, level)
    end
end

local function initBuildMenu(_, level)
    for _, build in ipairs(Catalog.findClass(Settings.classKey()).builds) do
        addItem(build[2], build[1] == Settings.buildKey(), function()
            Settings.chooseBuild(build[1])
            selected()
        end, level)
    end
end

local function initPhaseMenu(_, level)
    local phases, route = routePhases()
    local autoPhase = ForeverBiSModel and ForeverBiSModel.phaseForLevel(route, Player.level())
    addItem("Auto (" .. tostring(labelOf(phases, autoPhase)) .. ")", Settings.phase() == nil, function()
        Settings.choosePhase(nil)
        selected()
    end, level)
    for _, phase in ipairs(phases) do
        addItem(phase.label or phase.id, phase.id == Settings.phase(), function()
            Settings.choosePhase(phase.id)
            selected()
        end, level)
    end
end

function Selectors.create(parent)
    local classLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 24, -55)
    classLabel:SetText("Class")
    classDrop = CreateFrame("Frame", "ForeverBiSClassDropDown", parent, "UIDropDownMenuTemplate")
    classDrop:SetPoint("TOPLEFT", parent, "TOPLEFT", 65, -46)
    UIDropDownMenu_SetWidth(classDrop, 145)
    local buildLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buildLabel:SetPoint("LEFT", classDrop, "RIGHT", 5, 3)
    buildLabel:SetText("Build")
    buildDrop = CreateFrame("Frame", "ForeverBiSBuildDropDown", parent, "UIDropDownMenuTemplate")
    buildDrop:SetPoint("LEFT", buildLabel, "RIGHT", -5, -3)
    UIDropDownMenu_SetWidth(buildDrop, 120)
    -- No label: "Auto (Level 30)" explains itself and keeps the selector row short at the minimum width.
    phaseDrop = CreateFrame("Frame", "ForeverBiSPhaseDropDown", parent, "UIDropDownMenuTemplate")
    phaseDrop:SetPoint("LEFT", buildDrop, "RIGHT", -12, 0)
    UIDropDownMenu_SetWidth(phaseDrop, 105)

    UIDropDownMenu_Initialize(classDrop, initClassMenu)
    UIDropDownMenu_Initialize(buildDrop, initBuildMenu)
    UIDropDownMenu_Initialize(phaseDrop, initPhaseMenu)
end

--- Syncs the dropdown texts with the saved selection; the phase dropdown only shows when there is a choice.
function Selectors.refresh()
    local route, class, build = Settings.route()
    UIDropDownMenu_SetText(classDrop, class.label)
    UIDropDownMenu_SetText(buildDrop, build[2])

    local phases = routePhases()
    Settings.dropUnavailablePhase(route)
    local effective = Settings.effectivePhase(route, Player.level())
    local effectiveLabel = labelOf(phases, effective)
    if effectiveLabel then
        UIDropDownMenu_SetText(phaseDrop, Settings.phase() and effectiveLabel or "Auto (" .. effectiveLabel .. ")")
    end
    if #phases > 1 then
        phaseDrop:Show()
    else
        phaseDrop:Hide()
    end
end
