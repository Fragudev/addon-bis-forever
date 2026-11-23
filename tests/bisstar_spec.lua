-- BiS star overlay on item buttons: bags, the loot window and quest rewards.

local GOLD_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"

-- Client globals the overlay may hook or read; every test starts without them.
local CLIENT_GLOBALS = {
    "hooksecurefunc",
    "C_Container",
    "GetContainerItemID",
    "GetContainerItemLink",
    "ContainerFrame_Update",
    "ContainerFrame1",
    "ContainerFrame1Item1",
    "ContainerFrame1Item2",
    "ContainerFrameCombinedBags",
    "NUM_CONTAINER_FRAMES",
    "LootFrame_UpdateButton",
    "LootButton1",
    "LootButton2",
    "LOOTFRAME_NUMBUTTONS",
    "GetLootSlotLink",
    "QuestInfo_Display",
    "QuestInfoFrame",
    "QuestInfoRewardsFrame",
    "QuestInfoRewardsFrameQuestInfoItem1",
    "QuestInfoRewardsFrameQuestInfoItem2",
    "QuestFrameItems_Update",
    "QuestRewardItem1",
    "QuestLogItem1",
    "GetQuestItemLink",
    "GetQuestLogItemLink",
    "GetTalentTabInfo",
}

local function clearClientGlobals()
    for _, name in ipairs(CLIENT_GLOBALS) do
        _G[name] = nil
    end
end

--- The client's hooksecurefunc: runs the hook after the original, for a global or a table method.
local function installHooksecurefunc()
    _G.hooksecurefunc = function(target, method, hook)
        if type(target) ~= "table" then
            target, method, hook = _G, target, method
        end
        local original = target[method]
        target[method] = function(...)
            local results = { original(...) }
            hook(...)
            return unpack(results)
        end
    end
end

local function item(id)
    return { id = id, name = "Item " .. id, source = { kind = "unknown", text = "" } }
end

local function slot(name, ids)
    local items = {}
    for _, id in ipairs(ids) do
        items[#items + 1] = item(id)
    end
    return { slot = name, items = items }
end

-- Two rogue routes and one warrior route over three brackets.
--   100: combat lvl30 rank 1.        101: combat lvl30 rank 2, assassination lvl30 rank 1.
--   106: combat lvl30 rank 6.        107: combat lvl30 rank 7 (beyond the stars).
--   200: combat lvl20 rank 1 only.   400: combat lvl40 rank 1 only.   900: warrior only.
local function fixture()
    local phases = {
        { id = "lvl20", label = "Level 20", level = 20 },
        { id = "lvl30", label = "Level 30", level = 30 },
        { id = "lvl40", label = "Level 40", level = 40 },
    }
    return {
        schema = 3,
        sources = {
            leveling = {
                label = "ForeverBiS",
                order = 0,
                phases = phases,
                lists = {
                    ["rogue/combat"] = {
                        label = "Combat",
                        phases = {
                            lvl20 = { title = "20", slots = { slot("Head", { 200, 101 }) } },
                            lvl30 = {
                                title = "30",
                                slots = { slot("Head", { 100, 101, 102, 103, 104, 106, 107 }) },
                            },
                            lvl40 = { title = "40", slots = { slot("Head", { 400 }) } },
                        },
                    },
                    ["rogue/assassination"] = {
                        label = "Assassination",
                        phases = {
                            lvl20 = { title = "20", slots = { slot("Head", { 201 }) } },
                            lvl30 = { title = "30", slots = { slot("Head", { 101, 100 }) } },
                            lvl40 = { title = "40", slots = { slot("Head", { 401 }) } },
                        },
                    },
                    ["warrior/arms"] = {
                        label = "Arms",
                        phases = { lvl30 = { title = "30", slots = { slot("Head", { 900 }) } } },
                    },
                },
            },
        },
    }
end

local function link(id)
    return "|cffffffff|Hitem:" .. id .. "::::::::30:::::|h[Item " .. id .. "]|h|r"
end

--- Points spent per talent tree; nil leaves the client without the talent API.
local function talents(points)
    _G.GetTalentTabInfo = function(tab)
        return "Tree", nil, nil, nil, points[tab] or 0
    end
end

local function load(account)
    local player = WowStub.player
    WowStub.reset()
    WowStub.player = player
    _G.ForeverBiSData = fixture()
    _G.ForeverBiSDB = account
    local ns = WowStub.loadFiles({
        "ForeverBiS_Locale.lua",
        "ForeverBiS_Model.lua",
        "Core/Settings.lua",
        "Core/Catalog.lua",
        "Adapters/Player.lua",
        "UI/BisStar.lua",
    })
    ns.Settings.bind()
    return ns.BisStar, ns
end

local function button(name, parent, id)
    local frame = CreateFrame("Button", name, parent or UIParent)
    frame.GetID = function()
        return id
    end
    return frame
end

local function starState(BisStar, frame)
    local star = BisStar.starOf(frame)
    if not star or not star.shown then
        return "none"
    end
    assert.are.equal(GOLD_TEXTURE, star.texture)
    return star.desaturated and "silver" or "gold"
end

--- The frame that registered for a client event.
local function eventFrame(event)
    for _, frame in ipairs(WowStub.frames) do
        if frame.events[event] then
            return frame
        end
    end
end

local function fireEvent(event, ...)
    local frame = assert(eventFrame(event), "nothing registered " .. event)
    frame.scripts.OnEvent(frame, event, ...)
end

describe("BisStar", function()
    before_each(function()
        clearClientGlobals()
        WowStub.reset()
        WowStub.player = { class = "Rogue", token = "ROGUE", level = 30 }
    end)

    after_each(function()
        clearClientGlobals()
        _G.ForeverBiSDB, _G.ForeverBiSCharDB = nil, nil
        _G.ForeverBiSData = nil
    end)

    describe("rank", function()
        it("gives the rank in the spec the talents point to", function()
            talents({ 0, 11, 0 })
            local BisStar = load()
            assert.are.same({ "rogue/combat" }, BisStar.routes())
            assert.are.equal(1, BisStar.rankOf(100))
            assert.are.equal(2, BisStar.rankOf(101))
            assert.are.equal(6, BisStar.rankOf(106))
        end)

        it("uses the best rank among every route of the class without talent points", function()
            talents({ 0, 0, 0 })
            local BisStar = load()
            assert.are.same({ "rogue/assassination", "rogue/combat" }, BisStar.routes())
            assert.are.equal(1, BisStar.rankOf(101))
            assert.are.equal(1, BisStar.rankOf(100))
        end)

        it("uses every route of the class when the client has no talent API", function()
            local BisStar = load()
            assert.are.equal(1, BisStar.rankOf(101))
        end)

        it("ignores items listed only for other classes and unknown ids", function()
            local BisStar = load()
            assert.is_nil(BisStar.rankOf(900))
            assert.is_nil(BisStar.rankOf(123456))
            assert.is_nil(BisStar.rankOf(nil))
        end)
    end)

    describe("bracket", function()
        it("is the highest phase at or below the player's level, and the first one below it", function()
            local BisStar = load()
            assert.are.equal("lvl20", BisStar.bracket(1))
            assert.are.equal("lvl20", BisStar.bracket(19))
            assert.are.equal("lvl20", BisStar.bracket(29))
            assert.are.equal("lvl30", BisStar.bracket(30))
            assert.are.equal("lvl30", BisStar.bracket(39))
            assert.are.equal("lvl40", BisStar.bracket(60))
            assert.are.equal("lvl20", BisStar.bracket(nil))
        end)

        it("ranks items in the bracket for the player's level only", function()
            WowStub.player.level = 25
            local BisStar = load()
            assert.are.equal(1, BisStar.rankOf(200))
            assert.is_nil(BisStar.rankOf(100))
        end)

        it("is rebuilt on level up and talent changes, not on every lookup", function()
            talents({ 0, 11, 0 })
            local BisStar = load()
            BisStar.install()
            assert.are.equal(1, BisStar.rankOf(100))
            WowStub.player.level = 40
            assert.are.equal(1, BisStar.rankOf(100), "cached until an event says otherwise")
            fireEvent("PLAYER_LEVEL_UP", 40)
            assert.is_nil(BisStar.rankOf(100))
            assert.are.equal(1, BisStar.rankOf(400))
            talents({ 11, 0, 0 })
            assert.is_nil(BisStar.rankOf(401))
            fireEvent("CHARACTER_POINTS_CHANGED")
            assert.are.equal(1, BisStar.rankOf(401))
        end)

        it("trusts the level the level-up event carries over a stale UnitLevel", function()
            local BisStar = load()
            BisStar.install()
            fireEvent("PLAYER_LEVEL_UP", 40)
            assert.are.equal("lvl40", BisStar.currentBracket())
        end)
    end)

    describe("apply", function()
        it("shows a gold star for rank 1", function()
            talents({ 0, 11, 0 })
            local BisStar = load()
            local frame = button("Bag1")
            BisStar.apply(frame, 100)
            assert.are.equal("gold", starState(BisStar, frame))
        end)

        it("shows a silver star for ranks 2 to 6", function()
            talents({ 0, 11, 0 })
            local BisStar = load()
            for _, id in ipairs({ 101, 102, 103, 104, 106 }) do
                local frame = button(nil)
                BisStar.apply(frame, id)
                assert.are.equal("silver", starState(BisStar, frame), id)
            end
        end)

        it("shows no star past rank 6 or for items off the list", function()
            talents({ 0, 11, 0 })
            local BisStar = load()
            for _, id in ipairs({ 107, 900, 555 }) do
                local frame = button(nil)
                BisStar.apply(frame, id)
                assert.are.equal("none", starState(BisStar, frame), id)
            end
        end)

        it("reuses one star per button and hides it when the button changes item", function()
            talents({ 0, 11, 0 })
            local BisStar = load()
            local frame = button(nil)
            BisStar.apply(frame, 100)
            local star = BisStar.starOf(frame)
            BisStar.apply(frame, 101)
            assert.are.equal(star, BisStar.starOf(frame))
            assert.are.equal("silver", starState(BisStar, frame))
            BisStar.apply(frame, 100)
            assert.are.equal("gold", starState(BisStar, frame))
            BisStar.apply(frame, nil)
            assert.are.equal("none", starState(BisStar, frame))
            assert.are.equal(1, #frame.regions)
        end)

        it("creates nothing for a button that never shows a star", function()
            local BisStar = load()
            local frame = button(nil)
            BisStar.apply(frame, 555)
            assert.is_nil(BisStar.starOf(frame))
        end)

        it("pins the star to the top-left corner", function()
            local BisStar = load()
            local frame = button(nil)
            BisStar.apply(frame, 100)
            assert.are.equal("TOPLEFT", BisStar.starOf(frame).points[1][1])
        end)
    end)

    describe("setting", function()
        it("is on by default", function()
            local _, ns = load()
            assert.is_true(ns.Settings.bisStarsEnabled())
        end)

        it("turning it off hides existing stars on the next update", function()
            installHooksecurefunc()
            _G.GetLootSlotLink = function()
                return link(100)
            end
            _G.LootFrame_UpdateButton = function() end
            local loot = button("LootButton1")
            loot.slot = 1
            local BisStar, ns = load()
            BisStar.install()
            _G.LootFrame_UpdateButton(1)
            assert.are.equal("gold", starState(BisStar, loot))
            assert.is_false(ns.Settings.toggleBisStars())
            assert.is_false(ForeverBiSDB.bisStars)
            BisStar.refresh()
            assert.are.equal("none", starState(BisStar, loot))
            assert.is_true(ns.Settings.toggleBisStars())
            _G.LootFrame_UpdateButton(1)
            assert.are.equal("gold", starState(BisStar, loot))
        end)

        it("shows no star while saved off", function()
            local BisStar = load({ bisStars = false })
            local frame = button(nil)
            BisStar.apply(frame, 100)
            assert.are.equal("none", starState(BisStar, frame))
        end)
    end)

    describe("bags", function()
        local function bagFrame()
            local frame = CreateFrame("Frame", "ContainerFrame1", UIParent)
            frame.size = 2
            frame.GetID = function()
                return 0
            end
            frame.GetName = function()
                return "ContainerFrame1"
            end
            button("ContainerFrame1Item1", frame, 2)
            button("ContainerFrame1Item2", frame, 1)
            return frame
        end

        it("stars the bag item buttons through C_Container", function()
            talents({ 0, 11, 0 })
            installHooksecurefunc()
            _G.ContainerFrame_Update = function() end
            local contents = { [1] = 100, [2] = 101 }
            _G.C_Container = {
                GetContainerItemID = function(bag, slotIndex)
                    return bag == 0 and contents[slotIndex] or nil
                end,
            }
            local frame = bagFrame()
            local BisStar = load()
            BisStar.install()
            _G.ContainerFrame_Update(frame)
            assert.are.equal("silver", starState(BisStar, _G.ContainerFrame1Item1))
            assert.are.equal("gold", starState(BisStar, _G.ContainerFrame1Item2))
            contents[1] = nil
            _G.ContainerFrame_Update(frame)
            assert.are.equal("none", starState(BisStar, _G.ContainerFrame1Item2))
        end)

        it("falls back to the legacy GetContainerItemID", function()
            installHooksecurefunc()
            _G.ContainerFrame_Update = function() end
            _G.GetContainerItemID = function(_, slotIndex)
                return slotIndex == 1 and 100 or nil
            end
            local frame = bagFrame()
            local BisStar = load()
            BisStar.install()
            _G.ContainerFrame_Update(frame)
            assert.are.equal("gold", starState(BisStar, _G.ContainerFrame1Item2))
            assert.are.equal("none", starState(BisStar, _G.ContainerFrame1Item1))
        end)

        it("reads the item from the container link when no id API exists", function()
            installHooksecurefunc()
            _G.ContainerFrame_Update = function() end
            _G.GetContainerItemLink = function(_, slotIndex)
                return slotIndex == 1 and link(100) or nil
            end
            local frame = bagFrame()
            local BisStar = load()
            BisStar.install()
            _G.ContainerFrame_Update(frame)
            assert.are.equal("gold", starState(BisStar, _G.ContainerFrame1Item2))
        end)

        it("stars the combined bag through its item update and each button's bag id", function()
            installHooksecurefunc()
            local combined = CreateFrame("Frame", "ContainerFrameCombinedBags", UIParent)
            local slotButton = button(nil, combined, 3)
            slotButton.GetBagID = function()
                return 2
            end
            combined.UpdateItems = function() end
            combined.EnumerateValidItems = function()
                local done = false
                return function()
                    if not done then
                        done = true
                        return 1, slotButton
                    end
                end
            end
            _G.C_Container = {
                GetContainerItemID = function(bag, slotIndex)
                    return bag == 2 and slotIndex == 3 and 100 or nil
                end,
            }
            local BisStar = load()
            BisStar.install()
            combined:UpdateItems()
            assert.are.equal("gold", starState(BisStar, slotButton))
        end)
    end)

    describe("loot window", function()
        it("stars loot buttons when the client updates them", function()
            talents({ 0, 11, 0 })
            installHooksecurefunc()
            _G.LootFrame_UpdateButton = function() end
            _G.GetLootSlotLink = function(slotIndex)
                return slotIndex == 1 and link(101) or nil
            end
            local loot = button("LootButton1")
            loot.slot = 1
            local BisStar = load()
            BisStar.install()
            _G.LootFrame_UpdateButton(1)
            assert.are.equal("silver", starState(BisStar, loot))
        end)

        it("stars every loot button on LOOT_OPENED and hides emptied slots on LOOT_SLOT_CHANGED", function()
            local links = { link(100), link(555) }
            _G.GetLootSlotLink = function(slotIndex)
                return links[slotIndex]
            end
            _G.LOOTFRAME_NUMBUTTONS = 2
            local first, second = button("LootButton1"), button("LootButton2")
            first.slot, second.slot = 1, 2
            local BisStar = load()
            BisStar.install()
            fireEvent("LOOT_OPENED")
            assert.are.equal("gold", starState(BisStar, first))
            assert.are.equal("none", starState(BisStar, second))
            links[1] = nil
            fireEvent("LOOT_SLOT_CHANGED")
            assert.are.equal("none", starState(BisStar, first))
        end)
    end)

    describe("quest rewards", function()
        local function rewardButton(name, kind, index)
            local frame = button(name, _G.QuestInfoRewardsFrame, index)
            frame.type, frame.objectType = kind, "item"
            return frame
        end

        it("stars quest reward and choice buttons from the quest giver", function()
            installHooksecurefunc()
            _G.QuestInfo_Display = function() end
            _G.QuestInfoRewardsFrame = CreateFrame("Frame", "QuestInfoRewardsFrame", UIParent)
            local reward = rewardButton("QuestInfoRewardsFrameQuestInfoItem1", "choice", 1)
            local other = rewardButton("QuestInfoRewardsFrameQuestInfoItem2", "reward", 1)
            _G.GetQuestItemLink = function(kind, index)
                if kind == "choice" and index == 1 then
                    return link(100)
                end
                return link(102)
            end
            local BisStar = load()
            BisStar.install()
            _G.QuestInfo_Display()
            assert.are.equal("gold", starState(BisStar, reward))
            assert.are.equal("silver", starState(BisStar, other))
        end)

        it("reads quest log links while the quest log shows the rewards", function()
            installHooksecurefunc()
            _G.QuestInfo_Display = function() end
            _G.QuestInfoFrame = { questLog = true }
            _G.QuestInfoRewardsFrame = CreateFrame("Frame", "QuestInfoRewardsFrame", UIParent)
            local reward = rewardButton("QuestInfoRewardsFrameQuestInfoItem1", "reward", 1)
            _G.GetQuestItemLink = function()
                return nil
            end
            _G.GetQuestLogItemLink = function()
                return link(100)
            end
            local BisStar = load()
            BisStar.install()
            _G.QuestInfo_Display()
            assert.are.equal("gold", starState(BisStar, reward))
        end)

        it("stars the legacy quest frame item buttons", function()
            talents({ 0, 11, 0 })
            installHooksecurefunc()
            _G.QuestFrameItems_Update = function() end
            local reward = button("QuestRewardItem1", UIParent, 1)
            reward.type = "reward"
            local logItem = button("QuestLogItem1", UIParent, 1)
            logItem.type = "reward"
            _G.GetQuestItemLink = function()
                return link(101)
            end
            _G.GetQuestLogItemLink = function()
                return link(100)
            end
            local BisStar = load()
            BisStar.install()
            _G.QuestFrameItems_Update("QuestReward")
            _G.QuestFrameItems_Update("QuestLog")
            assert.are.equal("silver", starState(BisStar, reward))
            assert.are.equal("gold", starState(BisStar, logItem))
        end)
    end)

    describe("missing or failing client APIs", function()
        it("installs without any of the hooked APIs", function()
            local BisStar = load()
            assert.has_no.errors(function()
                BisStar.install()
                BisStar.refresh()
                fireEvent("LOOT_OPENED")
                fireEvent("PLAYER_LEVEL_UP", 31)
            end)
        end)

        it("installs hooks only for the APIs the client has", function()
            installHooksecurefunc()
            _G.LootFrame_UpdateButton = function() end
            local BisStar = load()
            assert.has_no.errors(function()
                BisStar.install()
            end)
            assert.is_nil(_G.ContainerFrame_Update)
            assert.is_nil(_G.QuestInfo_Display)
        end)

        it("never lets a failing client call escape a hook", function()
            installHooksecurefunc()
            _G.LootFrame_UpdateButton = function() end
            _G.ContainerFrame_Update = function() end
            _G.QuestInfo_Display = function() end
            _G.GetLootSlotLink = function()
                error("boom")
            end
            _G.C_Container = {
                GetContainerItemID = function()
                    error("boom")
                end,
            }
            local loot = button("LootButton1")
            loot.slot = 1
            local BisStar = load()
            BisStar.install()
            assert.has_no.errors(function()
                _G.LootFrame_UpdateButton(1)
                _G.ContainerFrame_Update(CreateFrame("Frame", nil, UIParent))
                _G.ContainerFrame_Update(nil)
                _G.QuestInfo_Display()
                fireEvent("LOOT_OPENED")
            end)
        end)

        it("skips buttons and links it cannot read", function()
            installHooksecurefunc()
            _G.LootFrame_UpdateButton = function() end
            _G.GetLootSlotLink = function()
                return "not a link"
            end
            local loot = button("LootButton1")
            loot.slot = 1
            local BisStar = load()
            BisStar.install()
            _G.LootFrame_UpdateButton(1)
            _G.LootFrame_UpdateButton(9)
            assert.are.equal("none", starState(BisStar, loot))
        end)
    end)
end)
