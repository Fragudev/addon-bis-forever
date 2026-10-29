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
        ns.Catalog.refreshBuilds(ForeverBiSBuildLabels)
    end
    return true
end

--- Creates the saved variables when missing and fills in the tables the addon expects. A saved data source that
--- is available becomes active; one that is not (for example a file the addon no longer ships) falls back to the
--- default source, but the saved id is kept untouched so the choice returns if the source comes back.
function Settings.bind()
    ForeverBiSDB = ForeverBiSDB or {}
    ForeverBiSCharDB = ForeverBiSCharDB or {}
    char().class = char().class or "rogue"
    char().build = char().build or "pve"
    minimap()
    collapsed()
    local saved = account().source
    if type(saved) == "string" and activate(saved) then
        return
    end
    if ForeverBiSModel and not activate(ForeverBiSModel.DEFAULT_SOURCE) then
        local first = ForeverBiSModel.sources()[1]
        if first then
            activate(first.id)
        end
    end
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

--- Resolves the saved class and build to known ones, writes them back, and returns the route key with both.
function Settings.route()
    local class, build, route = ns.Catalog.resolve(char().class, char().build)
    char().class, char().build = class.key, build[1]
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

--- The data source the player picked (account-wide), or nil until they pick one.
function Settings.source()
    local data = account()
    return type(data) == "table" and data.source or nil
end

--- True once the player picked a source that is still available.
function Settings.sourceChosen()
    local saved = Settings.source()
    if type(saved) ~= "string" or not ForeverBiSModel then
        return false
    end
    for _, source in ipairs(ForeverBiSModel.sources()) do
        if source.id == saved then
            return true
        end
    end
    return false
end

--- The id of the source the model reads right now (the default one before any choice).
function Settings.activeSource()
    return ForeverBiSModel and ForeverBiSModel.activeSource() or nil
end

--- Saves and activates a data source. Unknown ids are ignored (false). When the character's route has no list in
--- the new source the build goes back to the class's first build, and a phase the route lacks is dropped.
function Settings.chooseSource(id)
    if not ForeverBiSModel or type(id) ~= "string" or not activate(id) then
        return false
    end
    account().source = id
    local route, class = Settings.route()
    if not ForeverBiSModel.list(route) then
        char().build = ns.Catalog.defaultBuild(class)[1]
        route = Settings.route()
    end
    Settings.dropUnavailablePhase(route)
    return true
end

function Settings.phase()
    return char().phase
end

--- Pass nil for automatic (the phase matching the player's level).
function Settings.choosePhase(phaseId)
    char().phase = phaseId
end

--- A saved phase the route does not have falls back to automatic.
function Settings.dropUnavailablePhase(route)
    if ForeverBiSModel and not ForeverBiSModel.availablePhase(route, char().phase) then
        char().phase = nil
    end
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
