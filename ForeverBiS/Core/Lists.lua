-- Resolves the list a route and phase show, and indexes its slots for the panels that draw it. No WoW API.
local _, ns = ...

local Lists = {}
ns.Lists = Lists

--- The selected phase's data; a missing phase falls back to the route's default phase, and nil comes back when
--- the active source has no list for the route (or there is no model).
function Lists.resolve(route, phaseId)
    if not route or not ForeverBiSModel then
        return nil
    end
    return (phaseId and ForeverBiSModel.list(route, phaseId)) or ForeverBiSModel.list(route)
end

--- What a draw pass needs: the list data plus its slots indexed by slot key (ranked items, best item, heading).
function Lists.view(route, phaseId)
    local view = { route = route, phaseId = phaseId, ranked = {}, best = {}, headings = {} }
    view.data = Lists.resolve(route, phaseId)
    -- The active source has no list for this route (e.g. a class it does not cover): empty, but detectable.
    view.missing = route ~= nil and view.data == nil
    for _, slot in ipairs(view.data and view.data.slots or {}) do
        local slotKey = ns.Sources.normalizeSlotName(slot[1])
        view.best[slotKey] = slot[2][1]
        view.ranked[slotKey] = slot[2]
        view.headings[slotKey] = slot[1]
    end
    return view
end

--- The rank (1 = best) of an item id in a slot's { name, source } items, or nil when the slot does not list it.
--- idOf maps an item name to its id.
function Lists.rankOf(items, itemId, idOf)
    for rank, item in ipairs(items) do
        if idOf(item[1]) == itemId then
            return rank
        end
    end
    return nil
end
