-- Where the player is. The only place that asks the client about the current instance.
local _, ns = ...

local Zone = {}
ns.Zone = Zone

--- The name of the dungeon or raid the player is inside, or nil outside instances.
function Zone.instanceName()
    if not GetInstanceInfo then
        return nil
    end
    local name, instanceType = GetInstanceInfo()
    if instanceType == "party" or instanceType == "raid" then
        return name
    end
    return nil
end
