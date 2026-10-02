-- The only module that touches ForeverBiSDB. The client may replace that global wholesale once it loads the
-- saved variables, so it is read at call time and never cached.
local _, ns = ...

local Settings = {}
ns.Settings = Settings

local function db()
    return ForeverBiSDB
end

local function minimap()
    local data = db()
    data.minimap = data.minimap or {}
    return data.minimap
end

local function collapsed()
    local data = db()
    if type(data.collapsed) ~= "table" then
        data.collapsed = {}
    end
    return data.collapsed
end

--- Creates the saved variables when missing and fills in the tables the addon expects.
function Settings.bind()
    ForeverBiSDB = ForeverBiSDB or { class = "rogue", build = "pve" }
    minimap()
    collapsed()
end

--- A saved value by name, or nil while the saved variables are unavailable (tooltips can run before login).
function Settings.get(name)
    local data = db()
    if type(data) == "table" then
        return data[name]
    end
    return nil
end

--- Resolves the saved class and build to known ones, writes them back, and returns the route key with both.
function Settings.route()
    local class, build, route = ns.Catalog.resolve(db().class, db().build)
    db().class, db().build = class.key, build[1]
    return route, class, build
end

function Settings.classKey()
    return db().class
end

function Settings.buildKey()
    return db().build
end

--- A manual class pick also turns off login auto-detection for good.
function Settings.chooseClass(class)
    db().class, db().build = class.key, ns.Catalog.defaultBuild(class)[1]
    db().classChosen = true
end

function Settings.chooseBuild(buildKey)
    db().build = buildKey
end

--- Selects the class the player is playing, unless one was chosen by hand. The build is reset only when the
--- class actually changes, so a build picked by hand survives.
function Settings.applyDetectedClass(classToken)
    if db().classChosen == true or type(classToken) ~= "string" then
        return
    end
    local key = string.lower(classToken)
    for _, class in ipairs(ns.Catalog.classes) do
        if class.key == key and db().class ~= key then
            db().class, db().build = key, ns.Catalog.defaultBuild(class)[1]
        end
    end
end

function Settings.phase()
    return db().phase
end

--- Pass nil for automatic (the phase matching the player's level).
function Settings.choosePhase(phaseId)
    db().phase = phaseId
end

--- A saved phase the route does not have falls back to automatic.
function Settings.dropUnavailablePhase(route)
    if ForeverBiSModel and not ForeverBiSModel.availablePhase(route, db().phase) then
        db().phase = nil
    end
end

--- The phase shown for a route: the saved choice when available, otherwise the one matching the level.
function Settings.effectivePhase(route, playerLevel)
    if not ForeverBiSModel then
        return nil
    end
    return ForeverBiSModel.effectivePhase(route, db().phase, playerLevel)
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
    return db().tooltip ~= false
end

--- Returns the new state.
function Settings.toggleTooltip()
    db().tooltip = db().tooltip == false
    return db().tooltip
end

function Settings.tooltipAllClasses()
    return db().tooltipAllClasses == true
end

--- Returns the new state.
function Settings.toggleTooltipAllClasses()
    db().tooltipAllClasses = db().tooltipAllClasses ~= true
    return db().tooltipAllClasses
end
