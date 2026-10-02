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
