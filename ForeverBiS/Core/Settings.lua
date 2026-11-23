-- The only module that touches ForeverBiSDB. The client may replace that global wholesale once it loads the
-- saved variables, so it is read at call time and never cached.
local _, ns = ...

local Settings = {}
ns.Settings = Settings

-- Account-wide (ForeverBiSDB): minimap and tooltip options. Per character (ForeverBiSCharDB): class, build, phase
-- and routeChosen (a class or spec picked by hand, which stops talent detection).
local function account()
    return ForeverBiSDB
end

local function char()
    return ForeverBiSCharDB
end

-- Selection keys that used to live in the account-wide table.
local MOVED_KEYS = { "class", "build", "phase", "classChosen" }

local function minimap()
    local data = account()
    data.minimap = data.minimap or {}
    return data.minimap
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

--- A manual class pick also turns off talent detection for good.
function Settings.chooseClass(class)
    char().class, char().build = class.key, ns.Catalog.defaultBuild(class)[1]
    char().classChosen = true
    char().routeChosen = true
end

--- A manual spec pick also turns off talent detection for good.
function Settings.chooseBuild(buildKey)
    char().build = buildKey
    char().routeChosen = true
end

--- Whether the class or spec was picked by hand (the older classChosen flag does not count: it predates specs).
function Settings.routeChosen()
    return char().routeChosen == true
end

--- Selects the class the player is playing and the spec its talents point to (`route`, such as "rogue/combat"),
--- unless a class or spec was picked by hand. Without a usable route the class's first spec is used, unless that
--- class is already selected (its saved spec stays). Returns whether it changed the selection.
function Settings.applyDetectedRoute(classToken, route)
    if Settings.routeChosen() or type(classToken) ~= "string" then
        return false
    end
    local key = string.lower(classToken)
    local class, build = ns.Catalog.fromRoute(route)
    if not class or class.key ~= key then
        class = nil
        for _, known in ipairs(ns.Catalog.classes) do
            if known.key == key then
                class = known
            end
        end
        if not class or char().class == class.key then
            return false
        end
        build = ns.Catalog.defaultBuild(class)
    end
    char().class, char().build = class.key, build[1]
    return true
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

--- Pass nil for automatic (the phase matching the player's level).
function Settings.choosePhase(phaseId)
    char().phase = phaseId
end

--- The saved phase when the route has it, otherwise nil (automatic). Read-only: an unavailable saved phase is kept.
function Settings.activePhase(route)
    return ForeverBiSModel and ForeverBiSModel.availablePhase(route, char().phase) or nil
end

--- The bracket the BiS window shows for a route: the saved choice when the route has it, otherwise the highest
--- bracket at or below the player's level.
function Settings.bracket(route, playerLevel)
    if not ForeverBiSModel then
        return nil
    end
    return Settings.activePhase(route) or ForeverBiSModel.bracketForLevel(route, playerLevel)
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

-- Tooltip blocks and compact mode, all on by default, by option name -> account-wide key. The old
-- tooltipAllClasses key is no longer read: "/bis tooltip all" now toggles the "classes" block.
local TOOLTIP_OPTIONS = {
    spec = "tooltipSpec",
    specs = "tooltipSpecs",
    classes = "tooltipClasses",
    compact = "tooltipCompact",
}

--- True unless the option was turned off; nil for an unknown option. Safe before the saved variables exist.
function Settings.tooltipOption(name)
    local key = TOOLTIP_OPTIONS[name]
    if not key then
        return nil
    end
    return Settings.get(key) ~= false
end

--- Flips an option and returns its new state, or nil for an unknown option.
function Settings.toggleTooltipOption(name)
    local key = TOOLTIP_OPTIONS[name]
    if not key then
        return nil
    end
    account()[key] = account()[key] == false
    return account()[key]
end

-- BiS stars on item buttons (account-wide, on by default). Readable before the saved variables exist.
function Settings.bisStarsEnabled()
    local data = account()
    return type(data) ~= "table" or data.bisStars ~= false
end

--- Returns the new state.
function Settings.toggleBisStars()
    account().bisStars = account().bisStars == false
    return account().bisStars
end
