-- The only module that touches ForeverBiSDB. The client may replace that global wholesale once it loads the
-- saved variables, so it is read at call time and never cached.
local _, ns = ...

local Settings = {}
ns.Settings = Settings

-- Account-wide (ForeverBiSDB): minimap and tooltip options. Per character (ForeverBiSCharDB): class, build, phase,
-- classChosen and collapsed sections.
local function account()
    return ForeverBiSDB
end

local function char()
    return ForeverBiSCharDB
end

-- Selection keys that used to live in the account-wide table.
local MOVED_KEYS = { "class", "build", "phase", "classChosen", "collapsed" }

local function minimap()
    local data = account()
    data.minimap = data.minimap or {}
    return data.minimap
end

local function collapsed()
    local data = char()
    if type(data.collapsed) ~= "table" then
        data.collapsed = {}
    end
    return data.collapsed
end

--- Makes the model read the given source and rebuilds the builds the catalog offers for it.
local function activate(id)
    if not ForeverBiSModel or not ForeverBiSModel.select(id) then
        return false
    end
    if ns.Catalog then
        ns.Catalog.refreshBuilds(ForeverBiSBuildLabels, ForeverBiSModel.routes())
    end
    return true
end

--- Bind-time tidy-up: unknown saved class and build keys become known ones. Rendering never does this (see
--- Settings.route), so a build the active source lacks survives until the player chooses another.
local function normalizeSelection()
    if not ns.Catalog then
        return
    end
    local class, build = ns.Catalog.resolve(char().class, char().build)
    char().class, char().build = class.key, build[1]
end

--- Creates the saved variables when missing and fills in the tables the addon expects. A saved data source that
--- is available becomes active; one that is not (ForeverChanges and the wowsims presets, which the addon no longer
--- ships) falls back to the default source. The saved id is kept untouched, so no saved value is rewritten.
function Settings.bind()
    ForeverBiSDB = ForeverBiSDB or {}
    ForeverBiSCharDB = ForeverBiSCharDB or {}
    char().class = char().class or "rogue"
    char().build = char().build or "pve"
    minimap()
    collapsed()
    local saved = account().source
    if not (type(saved) == "string" and activate(saved)) then
        if ForeverBiSModel and not activate(ForeverBiSModel.DEFAULT_SOURCE) then
            local first = ForeverBiSModel.sources()[1]
            if first then
                activate(first.id)
            end
        end
    end
    normalizeSelection()
end

--- Moves the selection an older version saved account-wide into this character's table. The first character
--- to log in after the update keeps it; the others start fresh (and auto-detect their class). Run once the
--- client has loaded the saved variables (login), because the marker lives in them.
function Settings.migrate()
    Settings.bind()
    if char().migrated then
        return
    end
    for _, key in ipairs(MOVED_KEYS) do
        if account()[key] ~= nil then
            char()[key] = account()[key]
            account()[key] = nil
        end
    end
    char().migrated = true
end

--- A saved value by name, or nil while the saved variables are unavailable (tooltips can run before login).
function Settings.get(name)
    local data = account()
    if type(data) == "table" then
        return data[name]
    end
    return nil
end

--- Resolves the saved class and build to known ones and returns the route key with both. Read-only: the saved
--- values change only through the choose* functions, so a build the active source lacks is not lost.
function Settings.route()
    local class, build, route = ns.Catalog.resolve(char().class, char().build)
    return route, class, build
end

function Settings.classKey()
    return char().class
end

function Settings.buildKey()
    return char().build
end

--- A manual class pick also turns off login auto-detection for good.
function Settings.chooseClass(class)
    char().class, char().build = class.key, ns.Catalog.defaultBuild(class)[1]
    char().classChosen = true
end

function Settings.chooseBuild(buildKey)
    char().build = buildKey
end

--- Selects the class the player is playing, unless one was chosen by hand. The build is reset only when the
--- class actually changes, so a build picked by hand survives.
function Settings.applyDetectedClass(classToken)
    if char().classChosen == true or type(classToken) ~= "string" then
        return
    end
    local key = string.lower(classToken)
    for _, class in ipairs(ns.Catalog.classes) do
        if class.key == key and char().class ~= key then
            char().class, char().build = key, ns.Catalog.defaultBuild(class)[1]
        end
    end
end

--- The id of the source the model reads right now: the saved one when it ships, otherwise the default.
function Settings.activeSource()
    return ForeverBiSModel and ForeverBiSModel.activeSource() or nil
end

--- A predicate over a class's builds: true when the active source has a list for that build's route.
function Settings.buildHasList(class)
    return function(build)
        return ForeverBiSModel ~= nil and ForeverBiSModel.list(ns.Catalog.routeKey(class, build)) ~= nil
    end
end

function Settings.phase()
    return char().phase
end

--- Pass nil for automatic (the phase matching the player's level).
function Settings.choosePhase(phaseId)
    char().phase = phaseId
end

--- The saved phase when the route has it, otherwise nil (automatic). Read-only: an unavailable saved phase is kept.
function Settings.activePhase(route)
    return ForeverBiSModel and ForeverBiSModel.availablePhase(route, char().phase) or nil
end

--- The phase shown for a route: the saved choice when available, otherwise the one matching the level.
function Settings.effectivePhase(route, playerLevel)
    if not ForeverBiSModel then
        return nil
    end
    return ForeverBiSModel.effectivePhase(route, char().phase, playerLevel)
end

function Settings.isCollapsed(sectionKey)
    return collapsed()[sectionKey] == true
end

function Settings.toggleCollapsed(sectionKey)
    local sections = collapsed()
    if sections[sectionKey] then
        sections[sectionKey] = nil
    else
        sections[sectionKey] = true
    end
end

function Settings.expand(sectionKey)
    collapsed()[sectionKey] = nil
end

function Settings.minimapAngle()
    return minimap().angle or 220
end

function Settings.setMinimapAngle(angle)
    minimap().angle = angle
end

function Settings.minimapHidden()
    return minimap().hide == true
end

--- Flips the minimap button setting and returns true when the button is now shown.
function Settings.toggleMinimapHidden()
    minimap().hide = minimap().hide ~= true
    return not minimap().hide
end

function Settings.tooltipEnabled()
    return account().tooltip ~= false
end

--- Returns the new state.
function Settings.toggleTooltip()
    account().tooltip = account().tooltip == false
    return account().tooltip
end

function Settings.alertsEnabled()
    return account().alerts ~= false
end

--- Returns the new state.
function Settings.toggleAlerts()
    account().alerts = account().alerts == false
    return account().alerts
end

function Settings.dungeonNoticeEnabled()
    return account().dungeonNotice ~= false
end

--- Returns the new state.
function Settings.toggleDungeonNotice()
    account().dungeonNotice = account().dungeonNotice == false
    return account().dungeonNotice
end

function Settings.tooltipAllClasses()
    return account().tooltipAllClasses == true
end

--- Returns the new state.
function Settings.toggleTooltipAllClasses()
    account().tooltipAllClasses = account().tooltipAllClasses ~= true
    return account().tooltipAllClasses
end
