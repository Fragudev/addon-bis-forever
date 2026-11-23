-- The class, spec and bracket dropdowns, and what the window shows: the player's saved selection, or for a while
-- the class and spec of an inspected player.
local _, ns = ...

local Selectors = {}
ns.Selectors = Selectors

local Catalog, Settings, Player, Dropdown, Skin, Theme, L =
    ns.Catalog, ns.Settings, ns.Player, ns.Dropdown, ns.Skin, ns.Theme, ns.L

-- Top-left of the selector row, below the window header.
local ROW_LEFT, ROW_TOP = 20, -64

local classDrop, specDrop, bracketDrop, inspectLabel
-- What the last refresh measured the dropdown widths for.
local lastSignature
-- The inspected player while the window shows them: { unit, name, classKey, buildKey, level, phase, worn }.
local inspected

local function labelOf(phases, phaseId)
    for _, phase in ipairs(phases) do
        if phase.id == phaseId then
            return phase.label or phase.id
        end
    end
    return phaseId
end

--- What the window shows: { route, class, build, phase, autoPhase, savedPhase, worn, inspected }. `worn` is the
--- inspected player's gear snapshot (nil for the player), `savedPhase` the bracket picked by hand (nil = automatic).
function Selectors.current()
    if inspected then
        local class, build, route = Catalog.resolve(inspected.classKey, inspected.buildKey)
        local autoPhase = ForeverBiSModel and ForeverBiSModel.bracketForLevel(route, inspected.level)
        local savedPhase = ForeverBiSModel and ForeverBiSModel.availablePhase(route, inspected.phase)
        return {
            route = route,
            class = class,
            build = build,
            phase = savedPhase or autoPhase,
            autoPhase = autoPhase,
            savedPhase = savedPhase,
            worn = inspected.worn,
            inspected = inspected,
        }
    end
    local route, class, build = Settings.route()
    local autoPhase = ForeverBiSModel and ForeverBiSModel.bracketForLevel(route, Player.level())
    local savedPhase = Settings.activePhase(route)
    return {
        route = route,
        class = class,
        build = build,
        phase = savedPhase or autoPhase,
        autoPhase = autoPhase,
        savedPhase = savedPhase,
    }
end

--- Shows an inspected player until the window closes: their class, the spec of their talents (`route`, or their
--- class's first spec), the bracket for their level and their gear (`worn`, an Inventory.wornBy snapshot). `unit`
--- lets the gear be read again when the inspect data arrives.
function Selectors.inspect(target)
    local class, build = Catalog.fromRoute(target.route)
    if not class then
        class = Catalog.findClass(string.lower(target.classToken or ""))
        build = Catalog.defaultBuild(class)
    end
    inspected = {
        unit = target.unit,
        name = target.name,
        classKey = class.key,
        buildKey = build[1],
        level = target.level,
        worn = target.worn,
    }
end

--- The inspected player, or nil while the window shows the player's own selection.
function Selectors.inspected()
    return inspected
end

--- Back to the player's own selection.
function Selectors.clearInspect()
    inspected = nil
end

--- Every selection change redraws the window.
local function selected()
    ns.requestRender()
end

local function entry(text, checked, onSelect)
    return { text = text, checked = checked, func = onSelect }
end

local function listed(class)
    return Settings.buildHasList(class)
end

local function classItems()
    local current = Selectors.current().class
    local items = {}
    for _, class in ipairs(Catalog.classes) do
        items[#items + 1] = entry(class.label, class.key == current.key, function()
            if inspected then
                inspected.classKey = class.key
                inspected.buildKey = (Catalog.firstListedBuild(class, listed(class)) or Catalog.defaultBuild(class))[1]
            else
                Settings.chooseClass(class)
            end
            selected()
        end)
    end
    return items
end

--- The spec name of a build: its label without the PvE/PvP mode.
local function specText(build)
    local _, spec = Catalog.splitBuild(build[2])
    return spec or build[2]
end

local function specItems()
    local current = Selectors.current()
    local items = {}
    for _, build in ipairs(current.class.builds) do
        if listed(current.class)(build) then
            items[#items + 1] = entry(specText(build), build[1] == current.build[1], function()
                if inspected then
                    inspected.buildKey = build[1]
                else
                    Settings.chooseBuild(build[1])
                end
                selected()
            end)
        end
    end
    return items
end

local function choosePhase(phaseId)
    if inspected then
        inspected.phase = phaseId
    else
        Settings.choosePhase(phaseId)
    end
    selected()
end

local function bracketItems()
    local current = Selectors.current()
    local phases = ForeverBiSModel and ForeverBiSModel.phases(current.route) or {}
    local items = {
        entry(
            L["Auto (%s)"]:format(tostring(labelOf(phases, current.autoPhase))),
            current.savedPhase == nil,
            function()
                choosePhase(nil)
            end
        ),
    }
    for _, phase in ipairs(phases) do
        items[#items + 1] = entry(phase.label or phase.id, phase.id == current.savedPhase, function()
            choosePhase(phase.id)
        end)
    end
    return items
end

local function createLabel(parent, text)
    return Skin.sectionLabel(Skin.label(parent, 11, "semibold", "muted"), L[text])
end

function Selectors.create(parent)
    lastSignature, inspected = nil, nil
    local classLabel = createLabel(parent, "Class")
    -- Centered on the row of dropdowns, which hangs from ROW_TOP.
    classLabel:SetPoint("LEFT", parent, "TOPLEFT", ROW_LEFT, ROW_TOP - Theme.metrics.input / 2)
    classDrop = Dropdown.create(parent, "ForeverBiSClassDropDown", { width = 100, maxWidth = 130, items = classItems })
    classDrop:SetPoint("LEFT", classLabel, "RIGHT", 8, 0)
    local specLabel = createLabel(parent, "Spec")
    specLabel:SetPoint("LEFT", classDrop, "RIGHT", 14, 0)
    specDrop = Dropdown.create(parent, "ForeverBiSSpecDropDown", { width = 110, maxWidth = 150, items = specItems })
    specDrop:SetPoint("LEFT", specLabel, "RIGHT", 8, 0)
    -- No label: "Auto (Level 30)" explains itself.
    bracketDrop =
        Dropdown.create(parent, "ForeverBiSBracketDropDown", { width = 120, maxWidth = 180, items = bracketItems })
    bracketDrop:SetPoint("LEFT", specDrop, "RIGHT", 8, 0)
    inspectLabel = Skin.label(parent, 12, "medium", "accent")
    inspectLabel:SetPoint("TOPLEFT", classLabel, "BOTTOMLEFT", 0, -16)
    inspectLabel:SetJustifyH("LEFT")
end

--- Syncs the dropdown texts with what the window shows.
function Selectors.refresh()
    local current = Selectors.current()
    local phases = ForeverBiSModel and ForeverBiSModel.phases(current.route) or {}
    -- Everything the dropdown entries and texts depend on; the widths are measured again only when it changes.
    local signature = table.concat({
        current.route,
        tostring(current.savedPhase),
        tostring(current.autoPhase),
        inspected and inspected.name or "",
    }, "|")
    local changed = signature ~= lastSignature
    lastSignature = signature
    Dropdown.setText(classDrop, current.class.label)
    Dropdown.setText(specDrop, specText(current.build))
    local phaseLabel = labelOf(phases, current.phase)
    if phaseLabel then
        Dropdown.setText(bracketDrop, current.savedPhase and phaseLabel or L["Auto (%s)"]:format(phaseLabel))
    end
    if changed then
        Dropdown.fit(classDrop)
        Dropdown.fit(specDrop)
        Dropdown.fit(bracketDrop)
    end
    inspectLabel:SetText(inspected and L["Inspecting %s"]:format(inspected.name or "?") or "")
end
