-- The class, build and phase dropdowns with their section labels.
local _, ns = ...

local Selectors = {}
ns.Selectors = Selectors

local Catalog, Settings, Player, Dropdown, Skin, L = ns.Catalog, ns.Settings, ns.Player, ns.Dropdown, ns.Skin, ns.L

-- Top-left of the selector row, below the window header.
local ROW_LEFT, ROW_TOP = 20, -64

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

local function entry(text, checked, onSelect)
    return { text = text, checked = checked, func = onSelect }
end

local function classItems()
    local items = {}
    for _, class in ipairs(Catalog.classes) do
        items[#items + 1] = entry(class.label, class.key == Settings.classKey(), function()
            Settings.chooseClass(class)
            selected()
        end)
    end
    return items
end

local function buildItems()
    local items = {}
    for _, build in ipairs(Catalog.findClass(Settings.classKey()).builds) do
        items[#items + 1] = entry(build[2], build[1] == Settings.buildKey(), function()
            Settings.chooseBuild(build[1])
            selected()
        end)
    end
    return items
end

local function phaseItems()
    local phases, route = routePhases()
    local autoPhase = ForeverBiSModel and ForeverBiSModel.phaseForLevel(route, Player.level())
    local items = {
        entry(L["Auto (%s)"]:format(tostring(labelOf(phases, autoPhase))), Settings.phase() == nil, function()
            Settings.choosePhase(nil)
            selected()
        end),
    }
    for _, phase in ipairs(phases) do
        items[#items + 1] = entry(phase.label or phase.id, phase.id == Settings.phase(), function()
            Settings.choosePhase(phase.id)
            selected()
        end)
    end
    return items
end

local function createLabel(parent, text)
    return Skin.sectionLabel(Skin.label(parent, 11, "semibold", "muted"), L[text])
end

function Selectors.create(parent)
    local classLabel = createLabel(parent, "Class")
    classLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", ROW_LEFT, ROW_TOP - 8)
    classDrop = Dropdown.create(parent, "ForeverBiSClassDropDown", { width = 150, items = classItems })
    classDrop:SetPoint("TOPLEFT", parent, "TOPLEFT", ROW_LEFT + 42, ROW_TOP)
    local buildLabel = createLabel(parent, "Build")
    buildLabel:SetPoint("LEFT", classDrop, "RIGHT", 14, 0)
    buildDrop = Dropdown.create(parent, "ForeverBiSBuildDropDown", { width = 130, items = buildItems })
    buildDrop:SetPoint("LEFT", buildLabel, "RIGHT", 8, 0)
    -- No label: "Auto (Level 30)" explains itself and keeps the selector row short at the minimum width.
    phaseDrop = Dropdown.create(parent, "ForeverBiSPhaseDropDown", { width = 120, items = phaseItems })
    phaseDrop:SetPoint("LEFT", buildDrop, "RIGHT", 8, 0)
end

--- Syncs the dropdown texts with the saved selection; the phase dropdown only shows when there is a choice.
function Selectors.refresh()
    local route, class, build = Settings.route()
    Dropdown.setText(classDrop, class.label)
    Dropdown.setText(buildDrop, build[2])

    local phases = routePhases()
    Settings.dropUnavailablePhase(route)
    local effective = Settings.effectivePhase(route, Player.level())
    local effectiveLabel = labelOf(phases, effective)
    if effectiveLabel then
        Dropdown.setText(phaseDrop, Settings.phase() and effectiveLabel or L["Auto (%s)"]:format(effectiveLabel))
    end
    if #phases > 1 then
        phaseDrop:Show()
    else
        phaseDrop:Hide()
    end
end
