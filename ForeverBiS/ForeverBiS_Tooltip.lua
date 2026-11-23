-- Adds Forever BiS lines to item tooltips anywhere in the game. Every failure is silent: a tooltip must never error.
-- The block has three parts, each one can be turned off: (a) the player's spec (rank in the current bracket, or the
-- brackets that list it) with the item's source, (b) the other specs of the player's class, (c) the other classes as
-- one row per class. Compact mode caps the class rows; holding Shift shows them all.
local _, ns = ...

local COMPACT_ROWS = 2
local GOLD = { 1, 0.89, 0.35 }
local RANK_ONE = { 0.35, 1, 0.35 }
local OTHER_RANK = { 0.85, 0.85, 0.85 }
local GREY = { 0.6, 0.6, 0.6 }
local CLASS_ICONS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"

local Tooltip = {}
ns.Tooltip = Tooltip
ForeverBiSTooltip = Tooltip

-- The saved variables are re-bound at PLAYER_LOGIN, so settings are read at tooltip time and never cached.
local function setting(name)
    return ns.Settings.get(name)
end

local function option(name)
    return ns.Settings.tooltipOption(name) == true
end

local function playerClassToken()
    local token = ns.Player and ns.Player.classToken()
    return type(token) == "string" and token or nil
end

local function playerLevel()
    return ns.Player and ns.Player.level() or nil
end

--- The rows of the item: every entry grouped by route, each route keeping the entries of its bracket for the level.
--- Returns { [route] = { inBracket = { entries }, all = { entries } } } and the routes in data order.
local function routesFor(model, itemId, itemName, level)
    local byRoute, order = {}, {}
    for _, entry in ipairs(model.bisEntries(itemId, itemName)) do
        local route = byRoute[entry.route]
        if not route then
            route = { inBracket = {}, all = {}, bracket = model.bracketForLevel(entry.route, level) }
            byRoute[entry.route] = route
            order[#order + 1] = entry.route
        end
        route.all[#route.all + 1] = entry
        if entry.phase == route.bracket then
            route.inBracket[#route.inBracket + 1] = entry
        end
    end
    return byRoute, order
end

local function bestRank(entries)
    local best
    for _, entry in ipairs(entries) do
        if not best or entry.rank < best.rank then
            best = entry
        end
    end
    return best
end

--- "Assassination #1, Subtlety #3" for { { label, rank } }, best rank first, then by label.
local function specList(specs)
    table.sort(specs, function(a, b)
        if a.rank ~= b.rank then
            return a.rank < b.rank
        end
        return a.label < b.label
    end)
    local parts = {}
    for _, spec in ipairs(specs) do
        parts[#parts + 1] = spec.label .. " #" .. spec.rank
    end
    return table.concat(parts, ", ")
end

--- "4.2" for 4.2, "30" for 30.0: at most two decimals, no trailing zeros.
local function percent(rate)
    local text = string.format("%.2f", rate):gsub("0+$", ""):gsub("%.$", "")
    return text
end

local function sourceLine(entries)
    for _, entry in ipairs(entries) do
        local source = entry.source
        if type(source) == "table" and type(source.text) == "string" and source.kind ~= "unknown" then
            local text = source.text
            local rate = source.dropRate
            if type(rate) == "number" and rate == rate and rate > 0 then
                text = text .. " (" .. percent(rate) .. "%)"
            end
            return ns.L["Source: %s"]:format(text)
        end
    end
    return nil
end

--- Block (a): the player's spec in its bracket, otherwise the brackets that list it, otherwise "not BiS".
local function specLines(route, label)
    if not route then
        return { { ns.L["Not BiS for %s"]:format(label), GREY } }
    end
    local best = bestRank(route.inBracket)
    if best then
        local text = ns.L["BiS #%d for %s (%s)"]:format(best.rank, label, best.phaseLabel)
        return { { text, best.rank == 1 and RANK_ONE or OTHER_RANK } }
    end
    local perPhase, phases = {}, {}
    for _, entry in ipairs(route.all) do
        if not perPhase[entry.phase] then
            phases[#phases + 1] = entry.phase
            perPhase[entry.phase] = entry
        elseif entry.rank < perPhase[entry.phase].rank then
            perPhase[entry.phase] = entry
        end
    end
    local parts = {}
    for _, phase in ipairs(phases) do
        parts[#parts + 1] = perPhase[phase].phaseLabel .. " #" .. perPhase[phase].rank
    end
    return { { ns.L["BiS for %s at %s"]:format(label, table.concat(parts, ", ")), OTHER_RANK } }
end

local function classIcon(token)
    local coords = type(CLASS_ICON_TCOORDS) == "table" and CLASS_ICON_TCOORDS[token]
    if type(coords) ~= "table" or #coords < 4 then
        return ""
    end
    return string.format(
        "|T%s:14:14:0:0:256:256:%d:%d:%d:%d|t ",
        CLASS_ICONS,
        coords[1] * 256,
        coords[2] * 256,
        coords[3] * 256,
        coords[4] * 256
    )
end

local function className(token, key)
    local names = LOCALIZED_CLASS_NAMES_MALE
    if type(names) == "table" and type(names[token]) == "string" then
        return names[token]
    end
    return key:sub(1, 1):upper() .. key:sub(2)
end

local function classColor(token)
    local color = type(RAID_CLASS_COLORS) == "table" and RAID_CLASS_COLORS[token]
    if type(color) == "table" and type(color.r) == "number" then
        return { color.r, color.g, color.b }
    end
    return OTHER_RANK
end

--- Block (c): one row per other class, "<icon> Druid: Guardian #1, Feral #2", best class first.
local function classRows(byRoute, order, myClass)
    local perClass, classes = {}, {}
    for _, routeKey in ipairs(order) do
        local best = bestRank(byRoute[routeKey].inBracket)
        if best and best.class ~= myClass then
            local class = perClass[best.class]
            if not class then
                class = { key = best.class, specs = {}, best = best.rank }
                perClass[best.class] = class
                classes[#classes + 1] = class
            end
            class.specs[#class.specs + 1] = { label = best.label, rank = best.rank }
            class.best = math.min(class.best, best.rank)
        end
    end
    table.sort(classes, function(a, b)
        if a.best ~= b.best then
            return a.best < b.best
        end
        return a.key < b.key
    end)
    local rows = {}
    for _, class in ipairs(classes) do
        local token = string.upper(class.key)
        local text = classIcon(token) .. className(token, class.key) .. ": " .. specList(class.specs)
        rows[#rows + 1] = { text, classColor(token) }
    end
    return rows
end

local function expanded()
    return not option("compact") or (IsShiftKeyDown and IsShiftKeyDown()) == true
end

--- The lines to add as { text, color } (header excluded), or an empty list when nothing is to be shown.
local function blockLines(itemId, itemName)
    local model = ForeverBiSModel
    local token = playerClassToken()
    if not model or not model.bisEntries or not token then
        return {}
    end
    local myClass = string.lower(token)
    local myRoute = ns.Player.specRoute(token)
    local byRoute, order = routesFor(model, itemId, itemName, playerLevel())

    local otherSpecs = {}
    for _, routeKey in ipairs(order) do
        local best = bestRank(byRoute[routeKey].inBracket)
        if best and best.class == myClass and routeKey ~= myRoute then
            otherSpecs[#otherSpecs + 1] = { label = best.label, rank = best.rank }
        end
    end
    local rows = option("classes") and classRows(byRoute, order, myClass) or {}
    local specs = option("specs") and otherSpecs or {}

    local others = {}
    if #specs > 0 then
        local format = myRoute and ns.L["Also for: %s"] or ns.L["Your class: %s"]
        others[#others + 1] = { format:format(specList(specs)), OTHER_RANK }
    end
    local shown = expanded() and #rows or math.min(#rows, COMPACT_ROWS)
    for index = 1, shown do
        others[#others + 1] = rows[index]
    end
    if #rows > shown then
        others[#others + 1] = { ns.L["+%d more - hold Shift"]:format(#rows - shown), GREY }
    end

    -- Block (a) and the item's source: shown when the spec lists the item or when another block has something.
    local lines = {}
    if option("spec") and (byRoute[myRoute or ""] or #others > 0) then
        if myRoute then
            lines = specLines(byRoute[myRoute], model.label(myRoute) or myRoute)
        end
        local allEntries = {}
        for _, routeKey in ipairs(order) do
            for _, entry in ipairs(byRoute[routeKey].all) do
                allEntries[#allEntries + 1] = entry
            end
        end
        local source = sourceLine(allEntries)
        if source then
            lines[#lines + 1] = { source, GREY }
        end
    end
    for _, line in ipairs(others) do
        lines[#lines + 1] = line
    end
    return lines
end

--- Append the BiS block to a tooltip for an item. Returns true when lines were added.
function Tooltip.decorate(tooltip, itemId, itemName)
    if setting("tooltip") == false or type(itemId) ~= "number" or not tooltip or not tooltip.AddLine then
        return false
    end
    local lines = blockLines(itemId, itemName)
    if #lines == 0 then
        return false
    end
    tooltip:AddLine(" ")
    tooltip:AddLine(ns.L["Forever BiS"], GOLD[1], GOLD[2], GOLD[3])
    for _, line in ipairs(lines) do
        tooltip:AddLine(line[1], line[2][1], line[2][2], line[2][3])
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

--- Pressing or releasing Shift over an item rebuilds the shown tooltip through its owner's OnEnter, so compact mode
--- switches to the full rows and back. Only in compact mode: otherwise Shift changes nothing.
local function onModifierChanged(key)
    pcall(function()
        if type(key) ~= "string" or not key:find("SHIFT", 1, true) or not option("compact") then
            return
        end
        local tooltip = GameTooltip
        if not (tooltip and tooltip:IsShown() and select(2, tooltip:GetItem())) then
            return
        end
        local owner = tooltip:GetOwner()
        local onEnter = owner and owner.GetScript and owner:GetScript("OnEnter")
        if onEnter then
            onEnter(owner)
        end
    end)
end

local function watchModifiers()
    if not CreateFrame then
        return
    end
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("MODIFIER_STATE_CHANGED")
    frame:SetScript("OnEvent", function(_, _, key)
        onModifierChanged(key)
    end)
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
pcall(watchModifiers)
