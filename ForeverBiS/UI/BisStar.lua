-- BiS stars on item buttons (bags, the loot window and quest rewards): a gold star for rank 1 of the player's
-- current bracket and a silver one for ranks 2-6. Like the tooltip decorator, this file hooks the client's frames
-- directly, so it reads the container, loot and quest APIs itself. Every API is optional: a client without one
-- simply gets no stars on that surface, and no hook ever lets an error escape into the client's code.
local _, ns = ...

local BisStar = {}
ns.BisStar = BisStar

local Settings, Player = ns.Settings, ns.Player

-- The raid target star ships with every client; silver is the same star desaturated and tinted.
local STAR_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"
local STAR_SIZE = 14
local SILVER = { 0.85, 0.87, 0.92 }
local MAX_RANK = 6
local DEFAULT_LOOT_BUTTONS = 4
local DEFAULT_CONTAINER_FRAMES = 13
local DEFAULT_BAG_SIZE = 36
local MAX_QUEST_ITEMS = 10

-- One star per button, created on first use; weak keys so released buttons can be collected.
local stars = setmetatable({}, { __mode = "k" })

-- The lookup for the current level and talents: { routes, phases = route -> phase id, ranks = item id -> rank|false }.
-- Rebuilt lazily after an event that can change it (level up, talent points, login).
local lookup
local levelOverride

local function model()
    return ForeverBiSModel
end

--- The player's routes: the talent spec's route when points are spent and the data has it, otherwise every route
--- of the player's class (an item then counts with its best rank among them).
function BisStar.routes()
    local Model = model()
    local token = Player.classToken()
    if not Model or type(token) ~= "string" then
        return {}
    end
    local spec = Player.specRoute(token)
    local prefix = string.lower(token) .. "/"
    local routes = {}
    for _, route in ipairs(Model.routes()) do
        if route == spec then
            return { route }
        end
        if route:sub(1, #prefix) == prefix then
            routes[#routes + 1] = route
        end
    end
    return routes
end

--- The phase of a route for a level: the highest phase whose level is at or below it, or the first phase when the
--- level is below every phase (or unknown). Phases without a numeric level are ignored unless nothing else exists.
local function phaseFor(route, level)
    local Model = model()
    local phases = Model and Model.phases(route) or {}
    local best, lowest
    for _, phase in ipairs(phases) do
        local phaseLevel = phase.level
        if type(phaseLevel) == "number" then
            if not lowest or phaseLevel < lowest.level then
                lowest = phase
            end
            if type(level) == "number" and phaseLevel <= level and (not best or phaseLevel >= best.level) then
                best = phase
            end
        end
    end
    local chosen = best or lowest or phases[1]
    return chosen and chosen.id or nil
end

--- UnitLevel can still report the old level while PLAYER_LEVEL_UP fires, so the event's level wins until it catches up.
local function playerLevel()
    local level = Player.level()
    if levelOverride and (type(level) ~= "number" or level < levelOverride) then
        return levelOverride
    end
    return level
end

--- The bracket (phase id) for a level, read from the player's first route; nil without data.
function BisStar.bracket(level)
    local routes = BisStar.routes()
    local Model = model()
    local route = routes[1] or (Model and Model.routes()[1])
    return route and phaseFor(route, level) or nil
end

--- The bracket the stars use right now.
function BisStar.currentBracket()
    return BisStar.bracket(playerLevel())
end

local function currentLookup()
    if not lookup then
        local level = playerLevel()
        local phases = {}
        for _, route in ipairs(BisStar.routes()) do
            phases[route] = phaseFor(route, level)
        end
        lookup = { phases = phases, ranks = {} }
    end
    return lookup
end

--- Forgets the lookup; the next star rebuilds it. `level` overrides UnitLevel, which lags behind PLAYER_LEVEL_UP.
function BisStar.invalidate(level)
    if type(level) == "number" then
        levelOverride = level
    end
    lookup = nil
end

--- The best rank (1-6) of an item in the player's routes for the current bracket, or nil.
function BisStar.rankOf(itemId)
    local Model = model()
    if type(itemId) ~= "number" or not Model then
        return nil
    end
    local current = currentLookup()
    local cached = current.ranks[itemId]
    if cached == nil then
        cached = false
        for _, entry in ipairs(Model.bisEntries(itemId)) do
            if current.phases[entry.route] == entry.phase and entry.rank <= MAX_RANK then
                if not cached or entry.rank < cached then
                    cached = entry.rank
                end
            end
        end
        current.ranks[itemId] = cached
    end
    return cached or nil
end

local function enabled()
    return Settings.bisStarsEnabled()
end

--- The star texture of a button, or nil when it never showed one.
function BisStar.starOf(button)
    return stars[button]
end

local function createStar(button)
    local star = button:CreateTexture(nil, "OVERLAY")
    star:SetTexture(STAR_TEXTURE)
    star:SetSize(STAR_SIZE, STAR_SIZE)
    star:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    stars[button] = star
    return star
end

--- Shows the star the item earns on the button, or hides it. Returns the shown star or nil.
function BisStar.apply(button, itemId)
    if type(button) ~= "table" then
        return nil
    end
    local rank = enabled() and BisStar.rankOf(itemId) or nil
    local star = stars[button]
    if not rank then
        if star then
            star:Hide()
        end
        return nil
    end
    star = star or createStar(button)
    if rank == 1 then
        star:SetDesaturated(false)
        star:SetVertexColor(1, 1, 1)
    else
        star:SetDesaturated(true)
        star:SetVertexColor(SILVER[1], SILVER[2], SILVER[3])
    end
    star:Show()
    return star
end

--- The item id inside an item link, or nil.
local function idFromLink(link)
    local id = type(link) == "string" and link:match("item:(%d+)")
    return id and tonumber(id) or nil
end

-- Runs a client-facing function and swallows any error: stars are decoration and must never break the client.
local function safely(fn, ...)
    pcall(fn, ...)
end

local function global(name)
    return _G[name]
end

-- Bags ------------------------------------------------------------------------------------------------------------

local function containerItemId(bag, slot)
    if type(bag) ~= "number" or type(slot) ~= "number" then
        return nil
    end
    local Container = global("C_Container")
    if type(Container) == "table" and type(Container.GetContainerItemID) == "function" then
        return Container.GetContainerItemID(bag, slot)
    end
    local getId = global("GetContainerItemID")
    if type(getId) == "function" then
        return getId(bag, slot)
    end
    local getLink = (type(Container) == "table" and Container.GetContainerItemLink) or global("GetContainerItemLink")
    if type(getLink) == "function" then
        return idFromLink(getLink(bag, slot))
    end
    return nil
end

local function call(object, method)
    local fn = type(object) == "table" and object[method]
    if type(fn) == "function" then
        return fn(object)
    end
    return nil
end

local function applyBagButton(button, bag)
    local buttonBag = call(button, "GetBagID")
    if buttonBag == nil then
        buttonBag = bag
    end
    BisStar.apply(button, containerItemId(buttonBag, call(button, "GetID")))
end

--- Every item button of one container frame: the modern item enumerator, else the "<frame>ItemN" buttons.
local function updateContainer(frame)
    if type(frame) ~= "table" then
        return
    end
    local bag = call(frame, "GetID")
    local iterator, state, start = call(frame, "EnumerateValidItems")
    if type(iterator) == "function" then
        for _, button in iterator, state, start do
            applyBagButton(button, bag)
        end
        return
    end
    local name = call(frame, "GetName")
    if type(name) ~= "string" then
        return
    end
    for index = 1, tonumber(frame.size) or DEFAULT_BAG_SIZE do
        local button = global(name .. "Item" .. index)
        if not button then
            break
        end
        applyBagButton(button, bag)
    end
end

local function containerFrames()
    local frames = {}
    for index = 1, tonumber(global("NUM_CONTAINER_FRAMES")) or DEFAULT_CONTAINER_FRAMES do
        local frame = global("ContainerFrame" .. index)
        if type(frame) == "table" then
            frames[#frames + 1] = frame
        end
    end
    local combined = global("ContainerFrameCombinedBags")
    if type(combined) == "table" then
        frames[#frames + 1] = combined
    end
    return frames
end

local function refreshBags()
    for _, frame in ipairs(containerFrames()) do
        if call(frame, "IsShown") ~= false then
            safely(updateContainer, frame)
        end
    end
end

-- Loot window -----------------------------------------------------------------------------------------------------

local function updateLootButton(index)
    local button = global("LootButton" .. tostring(index))
    if type(button) ~= "table" then
        return
    end
    local getLink = global("GetLootSlotLink")
    local slot = button.slot or index
    local link = type(getLink) == "function" and getLink(slot) or nil
    BisStar.apply(button, idFromLink(link))
end

local function refreshLoot()
    for index = 1, tonumber(global("LOOTFRAME_NUMBUTTONS")) or DEFAULT_LOOT_BUTTONS do
        safely(updateLootButton, index)
    end
end

-- Quest rewards ---------------------------------------------------------------------------------------------------

--- The link of a quest item; `fromLog` reads the quest log instead of the quest giver.
local function questLink(kind, index, fromLog)
    local getLink = global(fromLog and "GetQuestLogItemLink" or "GetQuestItemLink")
    if type(getLink) ~= "function" or type(kind) ~= "string" or type(index) ~= "number" then
        return nil
    end
    return getLink(kind, index)
end

local function applyQuestButton(button, fromLog)
    if type(button) ~= "table" then
        return
    end
    if button.objectType ~= nil and button.objectType ~= "item" then
        BisStar.apply(button, nil)
        return
    end
    BisStar.apply(button, idFromLink(questLink(button.type, call(button, "GetID"), fromLog)))
end

--- The shared quest info panel (quest giver and quest log): its reward buttons by table or by name.
local function updateQuestInfo()
    local info = global("QuestInfoFrame")
    local fromLog = type(info) == "table" and info.questLog and true or false
    local rewards = global("QuestInfoRewardsFrame")
    local buttons = type(rewards) == "table" and type(rewards.RewardButtons) == "table" and rewards.RewardButtons
    if buttons then
        for _, button in ipairs(buttons) do
            applyQuestButton(button, fromLog)
        end
        return
    end
    for index = 1, MAX_QUEST_ITEMS do
        local button = global("QuestInfoRewardsFrameQuestInfoItem" .. index)
        if not button then
            break
        end
        applyQuestButton(button, fromLog)
    end
end

--- The older quest frames: "QuestDetailItemN", "QuestRewardItemN" and "QuestLogItemN".
local function updateQuestFrame(questState)
    if type(questState) ~= "string" then
        return
    end
    for index = 1, MAX_QUEST_ITEMS do
        local button = global(questState .. "Item" .. index)
        if not button then
            break
        end
        applyQuestButton(button, questState == "QuestLog")
    end
end

local function refreshQuests()
    safely(updateQuestInfo)
    for _, state in ipairs({ "QuestDetail", "QuestReward", "QuestLog" }) do
        safely(updateQuestFrame, state)
    end
end

--- Re-applies the stars on every surface the client shows; turning the setting off hides them here.
function BisStar.refresh()
    refreshBags()
    refreshLoot()
    refreshQuests()
end

-- Hooks and events ------------------------------------------------------------------------------------------------

--- Hooks a client function (global name, or a method of a table) to run `after` it, when both exist.
local function hookAfter(target, method, after)
    local hook = global("hooksecurefunc")
    if type(hook) ~= "function" then
        return
    end
    local function guarded(...)
        safely(after, ...)
    end
    if target == nil then
        if type(global(method)) == "function" then
            safely(hook, method, guarded)
        end
    elseif type(target) == "table" and type(target[method]) == "function" then
        safely(hook, target, method, guarded)
    end
end

local function installHooks()
    hookAfter(nil, "ContainerFrame_Update", updateContainer)
    for _, frame in ipairs(containerFrames()) do
        hookAfter(frame, "UpdateItems", updateContainer)
    end
    hookAfter(nil, "LootFrame_UpdateButton", updateLootButton)
    hookAfter(nil, "QuestInfo_Display", updateQuestInfo)
    hookAfter(nil, "QuestFrameItems_Update", updateQuestFrame)
end

local EVENTS = {
    PLAYER_LOGIN = "rebuild",
    PLAYER_LEVEL_UP = "rebuild",
    CHARACTER_POINTS_CHANGED = "rebuild",
    PLAYER_TALENT_UPDATE = "rebuild",
    LOOT_OPENED = "loot",
    LOOT_SLOT_CHANGED = "loot",
    LOOT_SLOT_CLEARED = "loot",
}

local function onEvent(_, event, ...)
    local kind = EVENTS[event]
    if kind == "rebuild" then
        BisStar.invalidate(event == "PLAYER_LEVEL_UP" and ... or nil)
        BisStar.refresh()
    elseif kind == "loot" then
        refreshLoot()
    end
end

--- Registers the events and hooks the client functions this client has. Safe to call without any of them.
function BisStar.install()
    local frame = CreateFrame("Frame")
    for event in pairs(EVENTS) do
        safely(frame.RegisterEvent, frame, event)
    end
    frame:SetScript("OnEvent", function(...)
        safely(onEvent, ...)
    end)
    installHooks()
end
