-- The player's identity from the client. The only place that calls the Unit* APIs.
local _, ns = ...

local Player = {}
ns.Player = Player

function Player.level()
    return UnitLevel and UnitLevel("player") or nil
end

--- "Horde", "Alliance", or nil when the client does not say.
function Player.faction()
    return UnitFactionGroup and UnitFactionGroup("player") or nil
end

--- The uppercase class token (such as "ROGUE"), or nil.
function Player.classToken()
    if not UnitClass then
        return nil
    end
    local _, token = UnitClass("player")
    return token
end

-- Talent tree (1-3, in the client's order) to the BiS route of the generated lists.
local TREE_ROUTES = {
    WARRIOR = { "warrior/arms", "warrior/fury", "warrior/tank" },
    PALADIN = { "paladin/holy", "paladin/tank", "paladin/retribution" },
    HUNTER = { "hunter/ranged", "hunter/ranged", "hunter/ranged" },
    ROGUE = { "rogue/assassination", "rogue/combat", "rogue/subtlety" },
    PRIEST = { "priest/discipline", "priest/holy", "priest/shadow" },
    SHAMAN = { "shaman/elemental", "shaman/enhancement", "shaman/restoration" },
    MAGE = { "mage/arcane", "mage/fire", "mage/frost" },
    WARLOCK = { "warlock/dps", "warlock/dps", "warlock/dps" },
    DRUID = { "druid/balance", "druid/feral", "druid/restoration" },
}

--- The route ("rogue/combat") of the talent tree with the most points for a class token, or nil when no point is
--- spent or the client has no talent API. With `inspect`, reads the inspected unit's talents (after NotifyInspect).
function Player.specRoute(classToken, inspect)
    local routes = TREE_ROUTES[classToken or ""]
    if not routes or not GetTalentTabInfo then
        return nil
    end
    local best, bestPoints = nil, 0
    for tab = 1, 3 do
        -- The fifth return is the points spent in the tree.
        local points = select(5, GetTalentTabInfo(tab, inspect and true or nil)) or 0
        if points > bestPoints then
            best, bestPoints = tab, points
        end
    end
    return best and routes[best] or nil
end

--- Name, realm, localized class, class token and level for the character panel.
function Player.identity()
    local name, realm
    if UnitFullName then
        name, realm = UnitFullName("player")
    end
    if not name and UnitName then
        name, realm = UnitName("player")
    end
    name = name or "Player"
    if (not realm or realm == "") and GetRealmName then
        realm = GetRealmName()
    end
    local localizedClass, classToken = "", nil
    if UnitClass then
        localizedClass, classToken = UnitClass("player")
    end
    return {
        name = name,
        realm = realm,
        className = localizedClass or "",
        classToken = classToken,
        level = Player.level() or "",
    }
end
