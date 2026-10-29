-- The data source, class, mode (PvE/PvP), build and phase dropdowns with their section labels.
local _, ns = ...

local Selectors = {}
ns.Selectors = Selectors

local Catalog, Settings, Player, Dropdown, Skin, L = ns.Catalog, ns.Settings, ns.Player, ns.Dropdown, ns.Skin, ns.L

-- Top-left of the selector row, below the window header.
local ROW_LEFT, ROW_TOP = 20, -64

local sourceDrop, classDrop, modeDrop, buildLabel, buildDrop, phaseDrop

local MODE_LABELS = { pve = "PvE", pvp = "PvP" }

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

--- The label of the source the model reads right now; the saved id is shown when the data carries no label.
local function activeSourceLabel()
    local active = Settings.activeSource()
    for _, source in ipairs(ForeverBiSModel and ForeverBiSModel.sources() or {}) do
        if source.id == active then
            return source.label
        end
    end
    return active
end

local function sourceItems()
    local items = {}
    local active = Settings.activeSource()
    for _, source in ipairs(ForeverBiSModel and ForeverBiSModel.sources() or {}) do
        items[#items + 1] = entry(source.label, source.id == active, function()
            Settings.chooseSource(source.id)
            selected()
        end)
    end
    return items
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

local function currentBuild()
    local _, class, build = Settings.route()
    return class, build
end

--- The spec name a build shows once its mode has its own dropdown; a bare "PvE" build is the damage one.
local function specText(spec)
    return spec or L["DPS"]
end

local function modeItems()
    local class, build = currentBuild()
    local currentMode = Catalog.splitBuild(build[2])
    local items = {}
    for _, mode in ipairs(Catalog.modes(class)) do
        items[#items + 1] = entry(L[MODE_LABELS[mode]], mode == currentMode, function()
            local target = Catalog.buildForMode(class, build, mode)
            if target then
                Settings.chooseBuild(target[1])
            end
            selected()
        end)
    end
    return items
end

local function buildItems()
    local class, build = currentBuild()
    local items = {}
    for _, choice in ipairs(Catalog.buildsForMode(class, (Catalog.splitBuild(build[2])))) do
        items[#items + 1] = entry(specText(choice.spec), choice.build[1] == build[1], function()
            Settings.chooseBuild(choice.build[1])
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
    -- No label: the source name explains itself. It leads the row because it decides which lists exist.
    sourceDrop =
        Dropdown.create(parent, "ForeverBiSSourceDropDown", { width = 104, maxWidth = 132, items = sourceItems })
    sourceDrop:SetPoint("TOPLEFT", parent, "TOPLEFT", ROW_LEFT, ROW_TOP)
    local classLabel = createLabel(parent, "Class")
    classLabel:SetPoint("LEFT", sourceDrop, "RIGHT", 12, 0)
    classDrop = Dropdown.create(parent, "ForeverBiSClassDropDown", { width = 110, maxWidth = 150, items = classItems })
    classDrop:SetPoint("LEFT", classLabel, "RIGHT", 8, 0)
    -- No label: "PvE" and "PvP" explain themselves.
    modeDrop = Dropdown.create(parent, "ForeverBiSModeDropDown", { width = 80, maxWidth = 110, items = modeItems })
    modeDrop:SetPoint("LEFT", classDrop, "RIGHT", 8, 0)
    buildLabel = createLabel(parent, "Build")
    buildLabel:SetPoint("LEFT", modeDrop, "RIGHT", 14, 0)
    buildDrop = Dropdown.create(parent, "ForeverBiSBuildDropDown", { width = 120, maxWidth = 180, items = buildItems })
    buildDrop:SetPoint("LEFT", buildLabel, "RIGHT", 8, 0)
    -- No label: "Auto (Level 30)" explains itself and keeps the selector row short at the minimum width.
    phaseDrop = Dropdown.create(parent, "ForeverBiSPhaseDropDown", { width = 120, maxWidth = 170, items = phaseItems })
end

local function showIf(frame, shown)
    if shown then
        frame:Show()
    else
        frame:Hide()
    end
end

--- Syncs the dropdown texts with the saved selection. The mode, build and phase dropdowns only show when they
--- offer a choice, and the phase one moves left to sit after the last shown dropdown.
function Selectors.refresh()
    local route, class, build = Settings.route()
    local mode, spec = Catalog.splitBuild(build[2])
    Dropdown.setText(sourceDrop, activeSourceLabel() or "")
    Dropdown.fit(sourceDrop)
    Dropdown.setText(classDrop, class.label)
    Dropdown.setText(modeDrop, L[MODE_LABELS[mode]])
    Dropdown.setText(buildDrop, specText(spec))
    Dropdown.fit(classDrop)
    Dropdown.fit(modeDrop)
    Dropdown.fit(buildDrop)
    local hasModes = #Catalog.modes(class) > 1
    local hasBuilds = #Catalog.buildsForMode(class, mode) > 1
    showIf(modeDrop, hasModes)
    showIf(buildLabel, hasBuilds)
    showIf(buildDrop, hasBuilds)
    buildLabel:ClearAllPoints()
    buildLabel:SetPoint("LEFT", hasModes and modeDrop or classDrop, "RIGHT", 14, 0)
    phaseDrop:ClearAllPoints()
    phaseDrop:SetPoint("LEFT", hasBuilds and buildDrop or hasModes and modeDrop or classDrop, "RIGHT", 8, 0)

    local phases = routePhases()
    Settings.dropUnavailablePhase(route)
    local effective = Settings.effectivePhase(route, Player.level())
    local effectiveLabel = labelOf(phases, effective)
    if effectiveLabel then
        Dropdown.setText(phaseDrop, Settings.phase() and effectiveLabel or L["Auto (%s)"]:format(effectiveLabel))
        Dropdown.fit(phaseDrop)
    end
    showIf(phaseDrop, #phases > 1)
end
