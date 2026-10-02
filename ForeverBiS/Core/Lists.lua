-- Resolves the list a route and phase show, and indexes its slots for the panels that draw it. No WoW API.
local _, ns = ...

local Lists = {}
ns.Lists = Lists

--- The selected phase's data; a missing model or phase falls back to the legacy list built from the same data.
function Lists.resolve(route, phaseId)
    if not route then
        return nil
    end
    local data = phaseId and ForeverBiSModel.list(route, phaseId)
    return data or (ForeverBiSLists or {})[route]
end

--- What a draw pass needs: the list data plus its slots indexed by slot key (ranked items, best item, heading).
function Lists.view(route, phaseId)
    local view = { route = route, phaseId = phaseId, ranked = {}, best = {}, headings = {} }
    view.data = Lists.resolve(route, phaseId)
    for _, slot in ipairs(view.data and view.data.slots or {}) do
        local slotKey = ns.Sources.normalizeSlotName(slot[1])
        view.best[slotKey] = slot[2][1]
        view.ranked[slotKey] = slot[2]
        view.headings[slotKey] = slot[1]
    end
    return view
end
