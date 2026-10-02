-- Adds Forever BiS lines to item tooltips anywhere in the game. Every failure is silent: a tooltip must never error.
local MAX_LINES = 4
local GOLD = { 1, 0.89, 0.35 }
local RANK_ONE = { 0.35, 1, 0.35 }
local OTHER_RANK = { 0.85, 0.85, 0.85 }

local Tooltip = {}
ForeverBiSTooltip = Tooltip

-- ForeverBiSDB is re-bound at PLAYER_LOGIN, so it is read at tooltip time and never cached.
local function setting(name)
    local db = ForeverBiSDB
    if type(db) == "table" then
        return db[name]
    end
    return nil
end

local function playerClassKey()
    local _, token = UnitClass("player")
    return type(token) == "string" and string.lower(token) or nil
end

--- Entries to show: own class only unless tooltipAllClasses, and per route the effective phase for the player's level.
--- A route whose effective phase does not list the item falls back to its other phases so upgrades stay visible.
local function visibleEntries(itemId, itemName)
    local model = ForeverBiSModel
    if not model or not model.bisEntries then
        return {}
    end
    local classKey = setting("tooltipAllClasses") ~= true and playerClassKey() or nil
    local level = UnitLevel and UnitLevel("player") or nil
    local perRoute, routes = {}, {}
    for _, entry in ipairs(model.bisEntries(itemId, itemName)) do
        if setting("tooltipAllClasses") == true or entry.class == classKey then
            if not perRoute[entry.route] then
                perRoute[entry.route] = {}
                routes[#routes + 1] = entry.route
            end
            table.insert(perRoute[entry.route], entry)
        end
    end
    local result = {}
    for _, route in ipairs(routes) do
        local effective = model.effectivePhase(route, nil, level)
        local current = {}
        for _, entry in ipairs(perRoute[route]) do
            if entry.phase == effective then
                current[#current + 1] = entry
            end
        end
        for _, entry in ipairs(#current > 0 and current or perRoute[route]) do
            result[#result + 1] = entry
        end
    end
    -- Stable sort: best rank first, ties keep route order.
    for index, entry in ipairs(result) do
        entry.order = index
    end
    table.sort(result, function(a, b)
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
        return a.order < b.order
    end)
    return result
end

local function entryLine(entry)
    return string.format("BiS #%d %s - %s (%s)", entry.rank, entry.slot, entry.label, entry.phaseLabel)
end

--- Append the BiS block to a tooltip for an item. Returns true when lines were added.
function Tooltip.decorate(tooltip, itemId, itemName)
    if setting("tooltip") == false or type(itemId) ~= "number" or not tooltip or not tooltip.AddLine then
        return false
    end
    local entries = visibleEntries(itemId, itemName)
    if #entries == 0 then
        return false
    end
    tooltip:AddLine(" ")
    tooltip:AddLine("Forever BiS", GOLD[1], GOLD[2], GOLD[3])
    for index = 1, math.min(#entries, MAX_LINES) do
        local color = entries[index].rank == 1 and RANK_ONE or OTHER_RANK
        tooltip:AddLine(entryLine(entries[index]), color[1], color[2], color[3])
    end
    if #entries > MAX_LINES then
        tooltip:AddLine("+" .. (#entries - MAX_LINES) .. " more", OTHER_RANK[1], OTHER_RANK[2], OTHER_RANK[3])
    end
    return true
end

--- The addon's own window builds item tooltips too (with source and ownership lines); they are skipped by owner.
local function isOwnTooltip(tooltip)
    local window = ForeverBiSFrame
    local owner = tooltip.GetOwner and tooltip:GetOwner()
    while owner do
        if owner == window then
            return true
        end
        owner = owner.GetParent and owner:GetParent()
    end
    return false
end

local function itemNameFor(itemId)
    if C_Item and C_Item.GetItemNameByID then
        return C_Item.GetItemNameByID(itemId)
    end
    if GetItemInfo then
        return (GetItemInfo(itemId))
    end
    return nil
end

local function onItemData(tooltip, data)
    pcall(function()
        local itemId = type(data) == "table" and data.id or nil
        if tooltip and type(itemId) == "number" and not isOwnTooltip(tooltip) then
            Tooltip.decorate(tooltip, itemId, itemNameFor(itemId))
        end
    end)
end

-- OnTooltipSetItem can fire more than once per item; remember decorated tooltips until they are cleared.
local decorated = setmetatable({}, { __mode = "k" })

local function onTooltipSetItem(tooltip)
    pcall(function()
        if decorated[tooltip] or isOwnTooltip(tooltip) then
            return
        end
        local name, link = tooltip:GetItem()
        local itemId = type(link) == "string" and tonumber(link:match("item:(%d+)")) or nil
        if itemId and Tooltip.decorate(tooltip, itemId, name) then
            decorated[tooltip] = true
            if tooltip.Show then
                tooltip:Show() -- recompute the size for the added lines
            end
        end
    end)
end

local function hookScripts(tooltip)
    if type(tooltip) == "table" and tooltip.HookScript then
        tooltip:HookScript("OnTooltipSetItem", onTooltipSetItem)
        tooltip:HookScript("OnTooltipCleared", function(self)
            decorated[self] = nil
        end)
    end
end

--- Register with whichever mechanism the client offers. Returns "processor", "script" or nil.
function Tooltip.install()
    if
        TooltipDataProcessor
        and TooltipDataProcessor.AddTooltipPostCall
        and Enum
        and Enum.TooltipDataType
        and Enum.TooltipDataType.Item
    then
        -- Covers GameTooltip, ItemRefTooltip, shopping/comparison tooltips and embedded ones.
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, onItemData)
        return "processor"
    end
    if GameTooltip and GameTooltip.HookScript then
        hookScripts(GameTooltip)
        hookScripts(ItemRefTooltip)
        return "script"
    end
    return nil
end

Tooltip.install()
