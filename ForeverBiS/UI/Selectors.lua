-- The class, mode (PvE/PvP), build and phase dropdowns with their section labels.
local _, ns = ...

local Selectors = {}
ns.Selectors = Selectors

local Catalog, Settings, Player, Dropdown, Skin, Theme, L =
    ns.Catalog, ns.Settings, ns.Player, ns.Dropdown, ns.Skin, ns.Theme, ns.L

-- Top-left of the selector row, below the window header.
local ROW_LEFT, ROW_TOP = 20, -64

local classDrop, modeDrop, buildLabel, buildDrop, phaseDrop
-- What the last refresh measured the dropdown widths for.
local lastSignature

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
    for _, mode in ipairs(Catalog.modes(class, Settings.buildHasList(class))) do
        items[#items + 1] = entry(L[MODE_LABELS[mode]], mode == currentMode, function()
            local target = Catalog.buildForMode(class, build, mode, Settings.buildHasList(class))
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
    for _, choice in ipairs(Catalog.buildsForMode(class, (Catalog.splitBuild(build[2])), Settings.buildHasList(class))) do
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
    local current = Settings.activePhase(route)
    local items = {
        entry(L["Auto (%s)"]:format(tostring(labelOf(phases, autoPhase))), current == nil, function()
            Settings.choosePhase(nil)
            selected()
        end),
    }
    for _, phase in ipairs(phases) do
        items[#items + 1] = entry(phase.label or phase.id, phase.id == current, function()
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
    lastSignature = nil
    local classLabel = createLabel(parent, "Class")
    -- Centered on the row of dropdowns, which hangs from ROW_TOP.
    classLabel:SetPoint("LEFT", parent, "TOPLEFT", ROW_LEFT, ROW_TOP - Theme.metrics.input / 2)
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
    -- Everything the dropdown entries and texts depend on; the widths are measured again only when it changes.
    local signature = table.concat({
        route,
        build[1],
        tostring(Settings.activePhase(route)),
        tostring(Player.level()),
    }, "|")
    local changed = signature ~= lastSignature
    lastSignature = signature
    Dropdown.setText(classDrop, class.label)
    Dropdown.setText(modeDrop, L[MODE_LABELS[mode]])
    Dropdown.setText(buildDrop, specText(spec))
    if changed then
        Dropdown.fit(classDrop)
        Dropdown.fit(modeDrop)
        Dropdown.fit(buildDrop)
    end
    local hasModes = #Catalog.modes(class, Settings.buildHasList(class)) > 1
    local hasBuilds = #Catalog.buildsForMode(class, mode, Settings.buildHasList(class)) > 1
    showIf(modeDrop, hasModes)
    showIf(buildLabel, hasBuilds)
    showIf(buildDrop, hasBuilds)
    buildLabel:ClearAllPoints()
    buildLabel:SetPoint("LEFT", hasModes and modeDrop or classDrop, "RIGHT", 14, 0)
    phaseDrop:ClearAllPoints()
    phaseDrop:SetPoint("LEFT", hasBuilds and buildDrop or hasModes and modeDrop or classDrop, "RIGHT", 8, 0)

    local phases = ForeverBiSModel and ForeverBiSModel.phases(route) or {}
    local effective = Settings.effectivePhase(route, Player.level())
    local effectiveLabel = labelOf(phases, effective)
    if effectiveLabel then
        Dropdown.setText(
            phaseDrop,
            Settings.activePhase(route) and effectiveLabel or L["Auto (%s)"]:format(effectiveLabel)
        )
        if changed then
            Dropdown.fit(phaseDrop)
        end
    end
    showIf(phaseDrop, #phases > 1)
end
