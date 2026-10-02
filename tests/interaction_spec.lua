local SLOT_IDS = {
    head = 1,
    neck = 2,
    shoulder = 3,
    chest = 5,
    waist = 6,
    legs = 7,
    feet = 8,
    wrist = 9,
    hands = 10,
    back = 15,
}

local function sortedKeys(map)
    local keys = {}
    for key in pairs(map) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function loadList(listKey)
    local class = listKey:match("^[^/]+")
    local build = listKey:match("/.*") or ""
    WowStub.load({ class = class, build = build })
end

--- The first list holding an item whose source satisfies the predicate.
local function findListWithItem(predicate)
    WowStub.loadData()
    for _, key in ipairs(sortedKeys(ForeverBiSLists)) do
        for _, slot in ipairs(ForeverBiSLists[key].slots) do
            for _, item in ipairs(slot[2]) do
                if predicate(string.lower(item[2])) then
                    return key, item
                end
            end
        end
    end
end

local function chooseOption(dropdown, label)
    WowStub.menus = {}
    dropdown.initializer(dropdown, 1)
    for _, info in ipairs(WowStub.menus) do
        if info.text == label then
            return info.func()
        end
    end
    error("no menu entry " .. label)
end

local function textChangedBox()
    for _, candidate in ipairs(WowStub.frames) do
        if candidate.scripts.OnTextChanged then
            return candidate
        end
    end
end

local function iconButtons(size)
    return WowStub.find("Button", function(button)
        return button.width == size and button.height == size and button.scripts.OnEnter
    end)
end

describe("ForeverBiS interactions", function()
    describe("collapsing a slot", function()
        it("hides its items when the header button is clicked and shows them on a second click", function()
            WowStub.load({ class = "druid", build = "" })
            local slot = ForeverBiSLists["druid"].slots[1]
            local topItem = slot[2][1][1]
            assert.is_true(WowStub.hasText(topItem))

            WowStub.fire(
                WowStub.find("Button", function(b)
                    return b.width == 18
                end)[1],
                "OnClick"
            )
            assert.is_true(ForeverBiSDB.collapsed["druid:" .. slot[1]])
            assert.is_false(WowStub.hasText(topItem))

            WowStub.fire(
                WowStub.find("Button", function(b)
                    return b.width == 18
                end)[1],
                "OnClick"
            )
            assert.is_nil(ForeverBiSDB.collapsed["druid:" .. slot[1]])
            assert.is_true(WowStub.hasText(topItem))
        end)
    end)

    describe("tooltips", function()
        it("shows the item link and its source on an item icon", function()
            WowStub.load({ class = "druid", build = "" })
            local slot = ForeverBiSLists["druid"].slots[1]
            WowStub.fire(iconButtons(38)[1], "OnEnter")
            assert.are.equal("Source: " .. slot[2][1][2], WowStub.tooltip.lines[1])
            local itemID = ForeverBiSItemIDs[slot[2][1][1]]
            if itemID then
                assert.are.equal("item:" .. itemID, WowStub.tooltip.hyperlink)
            else
                assert.are.equal(slot[2][1][1], WowStub.tooltip.title)
            end
        end)

        it("shows the formula link and source on an enchant icon, or the spell name without a formula", function()
            WowStub.load({ class = "druid", build = "" })
            local expected = {}
            for _, slot in ipairs(ForeverBiSLists["druid"].slots) do
                for _, enchant in ipairs(slot[3] or {}) do
                    table.insert(expected, enchant)
                end
            end
            local buttons = iconButtons(28)
            assert.are.equal(#expected, #buttons)

            local checkedFormula, checkedPlain = false, false
            for index, enchant in ipairs(expected) do
                WowStub.fire(buttons[index], "OnEnter")
                assert.are.equal("Source: " .. enchant[3], WowStub.tooltip.lines[1])
                if enchant[4] then
                    assert.are.equal("item:" .. enchant[4], WowStub.tooltip.hyperlink)
                    checkedFormula = true
                else
                    assert.are.equal(enchant[2], WowStub.tooltip.title)
                    checkedPlain = true
                end
            end
            assert.is_true(checkedFormula and checkedPlain, "data should cover both enchant kinds")
        end)

        it("hides the tooltip when the pointer leaves", function()
            WowStub.load({ class = "druid", build = "" })
            local button = iconButtons(28)[1]
            WowStub.fire(button, "OnEnter")
            GameTooltip:Show()
            WowStub.fire(button, "OnLeave")
            assert.is_false(GameTooltip:IsShown())
        end)
    end)

    describe("filters", function()
        local function click(button)
            WowStub.fire(button, "OnClick")
        end

        local function loadWithFaction(key, faction)
            WowStub.load({ class = key:match("^[^/]+"), build = key:match("/.*") or "" }, nil, {
                class = "Rogue",
                token = "ROGUE",
                level = 30,
                faction = faction,
            })
        end

        it("hides items exclusive to the other faction by default and shows them with Both", function()
            local key, item = findListWithItem(function(source)
                return source:find("alliance", 1, true) and not source:find("horde", 1, true)
            end)
            assert(key, "no alliance-only item in the data")
            loadWithFaction(key, "Horde")
            assert.is_false(WowStub.hasText(item[1]))
            assert.are.equal("Horde", ForeverBiSFilterFaction:GetText())

            click(ForeverBiSFilterFaction)
            assert.are.equal("Both", ForeverBiSFilterFaction:GetText())
            assert.is_true(WowStub.hasText(item[1]))
        end)

        it("keeps alliance-exclusive items for an alliance player", function()
            local key, item = findListWithItem(function(source)
                return source:find("alliance", 1, true) and not source:find("horde", 1, true)
            end)
            loadWithFaction(key, "Alliance")
            assert.is_true(WowStub.hasText(item[1]))
        end)

        it("hides the faction button when the faction is unknown", function()
            WowStub.load(nil)
            assert.is_false(ForeverBiSFilterFaction:IsShown())
        end)

        it("filters by source category and combines several", function()
            local key, quest = findListWithItem(function(source)
                return source:find("^quest:") ~= nil
            end)
            assert(key, "no quest item in the data")
            loadList(key)
            assert.is_true(WowStub.hasText(quest[1]))

            click(ForeverBiSFilterprofession)
            assert.is_false(WowStub.hasText(quest[1]))
            click(ForeverBiSFilterquest)
            assert.is_true(WowStub.hasText(quest[1]))
            click(ForeverBiSFilterprofession)
            click(ForeverBiSFilterquest)
            assert.is_true(WowStub.hasText(quest[1]))
        end)

        it("shows the dungeon picker only while the dungeon button is active", function()
            WowStub.load(nil)
            assert.is_false(ForeverBiSDungeonFilter:IsShown())
            click(ForeverBiSFilterdungeon)
            assert.is_true(ForeverBiSDungeonFilter:IsShown())
            chooseOption(ForeverBiSDungeonFilter, "The Deadmines")
            click(ForeverBiSFilterdungeon)
            assert.is_false(ForeverBiSDungeonFilter:IsShown())
        end)

        it("cycles the maker button through all, only and hide", function()
            local function isMaker(item)
                return item[2]:lower():find("only its maker can wear it", 1, true) ~= nil
            end
            local key, maker = findListWithItem(function(source)
                return source:find("only its maker can wear it", 1, true) ~= nil
            end)
            assert(key, "no maker-only item in the data")
            local other
            for _, slot in ipairs(ForeverBiSLists[key].slots) do
                for _, item in ipairs(slot[2]) do
                    if not isMaker(item) then
                        other = other or item
                    end
                end
            end
            assert(other, "no regular item next to the maker-only one")
            loadList(key)
            assert.are.equal("Maker: all", ForeverBiSFilterMaker:GetText())
            assert.is_false(ForeverBiSFilterMaker.filterActive)
            assert.is_true(WowStub.hasText(maker[1]))
            assert.is_true(WowStub.hasText(other[1]))

            click(ForeverBiSFilterMaker)
            assert.are.equal("Maker: only", ForeverBiSFilterMaker:GetText())
            assert.is_true(ForeverBiSFilterMaker.filterActive)
            assert.is_true(WowStub.hasText(maker[1]))
            assert.is_false(WowStub.hasText(other[1]))

            click(ForeverBiSFilterMaker)
            assert.are.equal("Maker: hide", ForeverBiSFilterMaker:GetText())
            assert.is_false(WowStub.hasText(maker[1]))
            assert.is_true(WowStub.hasText(other[1]))

            click(ForeverBiSFilterMaker)
            assert.are.equal("Maker: all", ForeverBiSFilterMaker:GetText())
            assert.is_true(WowStub.hasText(maker[1]))
            assert.is_true(WowStub.hasText(other[1]))
        end)

        it("searches the source text as well as the name", function()
            local key, item = findListWithItem(function(source)
                return source:find("^quest:") ~= nil
            end)
            loadList(key)
            local searchBox = textChangedBox()
            searchBox:SetText("quest:")
            WowStub.fire(searchBox, "OnTextChanged")
            assert.is_true(WowStub.hasText(item[1]))
        end)

        it("shows how many items match once something is filtered", function()
            local key = findListWithItem(function(source)
                return source:find("^quest:") ~= nil
            end)
            loadList(key)
            assert.is_true(WowStub.hasText(" items"))
            click(ForeverBiSFilterquest)
            assert.is_true(WowStub.hasText("|r/"))
        end)

        it("clears the search and every filter from the empty state", function()
            local key, item = findListWithItem(function(source)
                return source:find("^quest:") ~= nil
            end)
            loadList(key)
            click(ForeverBiSFilterprofession)
            local searchBox = textChangedBox()
            searchBox:SetText("zzzz-no-such-item")
            WowStub.fire(searchBox, "OnTextChanged")
            assert.is_true(WowStub.hasText("No items match"))

            local clear = WowStub.find("Button", function(b)
                return b.text == "Clear filters"
            end)[1]
            click(clear)
            assert.is_false(WowStub.hasText("No items match"))
            assert.is_true(WowStub.hasText(item[1]))
            assert.are.equal("", searchBox:GetText())
            assert.is_false(ForeverBiSFilterprofession.filterActive)
        end)

        it("clears only the search with the x button", function()
            WowStub.load(nil)
            local searchBox = textChangedBox()
            searchBox:SetText("abc")
            WowStub.fire(searchBox, "OnTextChanged")
            local clear = WowStub.find("Button", function(b)
                return b.text == "x"
            end)[1]
            assert.is_true(clear:IsShown())
            click(clear)
            assert.are.equal("", searchBox:GetText())
            -- The client fires OnTextChanged from SetText; the stub does not.
            WowStub.fire(searchBox, "OnTextChanged")
            assert.is_false(clear:IsShown())
        end)
    end)

    describe("ownership marks", function()
        local function topItemWithID()
            for _, slot in ipairs(ForeverBiSLists["druid"].slots) do
                local slotID = SLOT_IDS[string.lower(slot[1])]
                local itemID = slotID and ForeverBiSItemIDs[slot[2][1][1]]
                if itemID then
                    return slot, slotID, itemID
                end
            end
        end

        it("marks a BiS item equipped in its slot", function()
            WowStub.load({ class = "druid", build = "" })
            local slot, slotID, itemID = topItemWithID()
            assert(slot, "no top item with a known id")
            WowStub.equipped[slotID] = itemID
            _G.SlashCmdList["FOREVERBIS"]()
            local checks = WowStub.find("Texture", function(t)
                return t.texture == "Interface\\RaidFrame\\ReadyCheck-Ready"
            end)
            assert.is_true(#checks > 0)
        end)

        it("shows how many copies of a BiS item are in the bags", function()
            WowStub.load({ class = "druid", build = "" })
            local _, _, itemID = topItemWithID()
            WowStub.bagCounts[itemID] = 3
            _G.SlashCmdList["FOREVERBIS"]()
            assert.is_true(WowStub.hasText("x3"))
        end)

        it("shows an empty message for Equipped Only when nothing is equipped, then lists what is", function()
            WowStub.load({ class = "druid", build = "" })
            local slot, slotID, itemID = topItemWithID()
            local button = WowStub.find("Button", function(b)
                return b.text == "Equipped Only: Off"
            end)[1]
            WowStub.fire(button, "OnClick")
            assert.are.equal("Equipped Only: On", button:GetText())
            assert.is_true(WowStub.hasText("No equipped BiS items found."))

            WowStub.equipped[slotID] = itemID
            WowStub.fire(button, "OnClick") -- off
            WowStub.fire(button, "OnClick") -- on again, now with an equipped item
            assert.is_false(WowStub.hasText("No equipped BiS items found."))
            assert.is_truthy(slot)
        end)
    end)

    describe("item data events", function()
        local function watcher()
            for _, candidate in ipairs(WowStub.frames) do
                if candidate.events.GET_ITEM_INFO_RECEIVED then
                    return candidate
                end
            end
        end

        it("re-renders when a tracked item finishes loading, and ignores unknown or failed loads", function()
            WowStub.load({ class = "druid", build = "" })
            ForeverBiSFrame:Show()
            local itemID = next(ForeverBiSItemIDs) and ForeverBiSItemIDs[sortedKeys(ForeverBiSItemIDs)[1]]

            local before = #WowStub.fontStrings
            WowStub.fire(watcher(), "OnEvent", "GET_ITEM_INFO_RECEIVED", -1, true)
            WowStub.fire(watcher(), "OnEvent", "GET_ITEM_INFO_RECEIVED", itemID, false)
            assert.are.equal(before, #WowStub.fontStrings)

            WowStub.fire(watcher(), "OnEvent", "GET_ITEM_INFO_RECEIVED", itemID, true)
            assert.is_true(#WowStub.fontStrings > before)
        end)
    end)
end)

-- Gives the druid list a second phase with its own title, so the phase selector has something to choose.
local function withSecondPhase(data)
    table.insert(data.phases, { id = "lvl40", label = "Level 40", level = 40 })
    local base = data.lists["druid"].phases.lvl30
    local slots = {}
    for _, slot in ipairs(base.slots) do
        slots[#slots + 1] = slot
    end
    data.lists["druid"].phases.lvl40 = { title = "Druid at level 40", slots = slots }
    slots[1] = {
        slot = slots[1].slot,
        items = { { name = "Level Forty Hood", source = { kind = "unknown", text = "Somewhere" } } },
    }
end

describe("ForeverBiS phase selector", function()
    local function playerAt(level)
        return { class = "Druid", token = "DRUID", level = level }
    end

    it("is hidden while the route has a single phase", function()
        WowStub.load({ class = "druid", build = "" })
        assert.is_false(ForeverBiSPhaseDropDown:IsShown())
    end)

    it("is shown when the route has several phases, and reports the automatic phase", function()
        WowStub.load({ class = "druid", build = "" }, withSecondPhase, playerAt(35))
        assert.is_true(ForeverBiSPhaseDropDown:IsShown())
        assert.are.equal("Auto (Level 40)", ForeverBiSPhaseDropDown.menuText)
    end)

    it("lists Auto first, then every phase of the route in order", function()
        WowStub.load({ class = "druid", build = "" }, withSecondPhase, playerAt(35))
        WowStub.menus = {}
        ForeverBiSPhaseDropDown.initializer(ForeverBiSPhaseDropDown, 1)
        local labels = {}
        for _, info in ipairs(WowStub.menus) do
            labels[#labels + 1] = info.text
        end
        assert.are.same({ "Auto (Level 40)", "Level 30", "Level 40" }, labels)
        assert.is_true(WowStub.menus[1].checked)
    end)

    it("renders the chosen phase and stores it, and Auto clears it", function()
        WowStub.load({ class = "druid", build = "" }, withSecondPhase, playerAt(35))
        assert.is_true(WowStub.hasText("Level Forty Hood"))

        chooseOption(ForeverBiSPhaseDropDown, "Level 30")
        assert.are.equal("lvl30", ForeverBiSDB.phase)
        assert.are.equal("Level 30", ForeverBiSPhaseDropDown.menuText)
        assert.is_false(WowStub.hasText("Level Forty Hood"))

        chooseOption(ForeverBiSPhaseDropDown, "Auto (Level 40)")
        assert.is_nil(ForeverBiSDB.phase)
        assert.is_true(WowStub.hasText("Level Forty Hood"))
    end)

    it("makes Auto follow the player level", function()
        WowStub.load({ class = "druid", build = "" }, withSecondPhase, playerAt(20))
        assert.are.equal("Auto (Level 30)", ForeverBiSPhaseDropDown.menuText)
        assert.is_false(WowStub.hasText("Level Forty Hood"))
    end)

    it("honours a saved phase and shows its label", function()
        WowStub.load({ class = "druid", build = "", phase = "lvl40" }, withSecondPhase, playerAt(20))
        assert.are.equal("Level 40", ForeverBiSPhaseDropDown.menuText)
        assert.is_true(WowStub.hasText("Level Forty Hood"))
    end)

    it("drops a saved phase the route does not have, and when the class changes to such a route", function()
        WowStub.load({ class = "druid", build = "", phase = "lvl99" })
        assert.is_nil(ForeverBiSDB.phase)

        WowStub.load({ class = "druid", build = "", phase = "lvl40" }, withSecondPhase)
        chooseOption(ForeverBiSClassDropDown, "Rogue")
        assert.is_nil(ForeverBiSDB.phase)
        assert.is_false(ForeverBiSPhaseDropDown:IsShown())
    end)

    it("marks the class as chosen when picked by hand", function()
        WowStub.load({ class = "druid", build = "" })
        assert.is_nil(ForeverBiSDB.classChosen)
        chooseOption(ForeverBiSClassDropDown, "Mage")
        assert.is_true(ForeverBiSDB.classChosen)
    end)

    it("keeps collapsed state keyed by route so it survives a phase change", function()
        WowStub.load({ class = "druid", build = "" }, withSecondPhase, playerAt(35))
        local head = ForeverBiSLists["druid"].slots[1][1]
        WowStub.fire(
            WowStub.find("Button", function(b)
                return b.width == 18
            end)[1],
            "OnClick"
        )
        assert.is_true(ForeverBiSDB.collapsed["druid:" .. head])
        chooseOption(ForeverBiSPhaseDropDown, "Level 30")
        assert.is_true(ForeverBiSDB.collapsed["druid:" .. head])
    end)

    describe("progress line", function()
        local function currentList()
            local phase = ForeverBiSModel.effectivePhase("druid", nil, WowStub.player.level)
            return ForeverBiSModel.list("druid", phase)
        end

        local function progressText()
            for _, fontString in ipairs(WowStub.fontStrings) do
                if fontString.text and fontString.text:match("^BiS %d+/%d+$") and WowStub.attached(fontString) then
                    return fontString
                end
            end
        end

        --- The progress frame is the live frame with an OnEnter handler and the line's size, shown or not.
        local function progressFrame()
            for _, candidate in ipairs(WowStub.frames) do
                if candidate.scripts.OnEnter and candidate.width == 78 and candidate.height == 20 then
                    return candidate
                end
            end
        end

        local function itemWatcher()
            for _, candidate in ipairs(WowStub.frames) do
                if candidate.events.BAG_UPDATE then
                    return candidate
                end
            end
        end

        local function hover()
            WowStub.fire(progressFrame(), "OnEnter")
            return WowStub.tooltip
        end

        --- First single-slot list position whose first two items have ids: slot id, rank 1 id, rank 2 id.
        local function headIds()
            for _, slot in ipairs(currentList().slots) do
                if slot[1] == "Head" then
                    return SLOT_IDS.head, ForeverBiSItemIDs[slot[2][1][1]], ForeverBiSItemIDs[slot[2][2][1]]
                end
            end
        end

        local function totalSlots()
            return ForeverBiSModel.progress(currentList(), { equipped = {} }).total
        end

        it("shows BiS x/y with a gold fill that follows the owned items", function()
            WowStub.load({ class = "druid", build = "" })
            local text = assert(progressText())
            assert.are.equal("BiS 0/" .. totalSlots(), text.text)
            assert.is_true(text.parent.shown)

            local slotID, first = headIds()
            WowStub.equipped[slotID] = first
            ForeverBiSFrame:Show()
            WowStub.fire(itemWatcher(), "OnEvent", "PLAYER_EQUIPMENT_CHANGED")
            local refreshed = progressText()
            assert.are.equal("BiS 1/" .. totalSlots(), refreshed.text)
            local fill
            for _, region in ipairs(refreshed.parent.regions) do
                if region.shown and region.height == 4 and region.width ~= 78 then
                    fill = region
                end
            end
            assert.is_truthy(fill)
            assert.are.equal(78 / totalSlots(), fill.width)
        end)

        it("updates after a bag change and flags upgrades in the bags", function()
            WowStub.load({ class = "druid", build = "" })
            local _, _, second = headIds()
            WowStub.bagCounts[second] = 1
            ForeverBiSFrame:Show()
            WowStub.fire(itemWatcher(), "OnEvent", "BAG_UPDATE")
            local lines = hover().lines
            local found
            for _, line in ipairs(lines) do
                if line:find("Head: Equip: ", 1, true) then
                    found = line
                end
            end
            assert.is_truthy(found, "no Equip: line for the bagged upgrade")
        end)

        it("breaks the missing slots down by source category, adding up to the missing count", function()
            WowStub.load({ class = "druid", build = "" })
            local remaining
            for _, line in ipairs(hover().lines) do
                if line:find("^Remaining: ") then
                    remaining = line
                end
            end
            assert.is_truthy(remaining, "no Remaining line")
            local plain = remaining:gsub("|T.-|t", "")
            local sum = 0
            for count in plain:gmatch(" (%d+)") do
                sum = sum + tonumber(count)
            end
            assert.are.equal(totalSlots(), sum)
            assert.is_nil(plain:find(" 0"), "a category with nothing missing should be hidden")
        end)

        it("follows the class selection", function()
            WowStub.load({ class = "druid", build = "" })
            local rogue = ForeverBiSModel.progress(ForeverBiSModel.list("rogue"), { equipped = {} }).total
            ForeverBiSDB.class, ForeverBiSDB.build = "rogue", ""
            ForeverBiSFrame:Show()
            WowStub.fire(itemWatcher(), "OnEvent", "BAG_UPDATE")
            assert.are.equal("BiS 0/" .. rogue, progressText().text)
        end)

        it("caps the tooltip at 8 slot lines plus a +N more line", function()
            WowStub.load({ class = "druid", build = "" })
            local total = totalSlots()
            assert(total > 8, "fixture needs more than 8 open slots")
            local tooltip = hover()
            local lines = tooltip.lines
            assert.is_truthy(tooltip.title:find("%S"))
            assert.are.equal("BiS: 0/" .. total .. " slots - Listed: 0/" .. total, lines[1])
            assert.are.equal(1 + 1 + 8 + 1, #lines) -- summary, remaining by category, 8 slots, +N more
            assert.are.equal("+" .. (total - 8) .. " more", lines[#lines])
            assert.is_truthy(lines[3]:match("^[%w ]+: .+"))
        end)

        it("lists every open slot without a +N more line when there are few", function()
            WowStub.load({ class = "druid", build = "" }, function(data)
                for _, entry in pairs(data.lists) do
                    for _, phase in pairs(entry.phases) do
                        local kept = {}
                        for index = 1, 3 do
                            kept[index] = phase.slots[index]
                        end
                        phase.slots = kept
                    end
                end
            end)
            local lines = hover().lines
            assert.are.equal(1 + 1 + 3, #lines)
            assert.is_nil(lines[#lines]:find("more", 1, true))
        end)

        it("hides the progress line when the list has no trackable slots", function()
            WowStub.load({ class = "druid", build = "" }, function(data)
                for _, entry in pairs(data.lists) do
                    for _, phase in pairs(entry.phases) do
                        for _, slot in ipairs(phase.slots) do
                            slot.slot = "Tabard"
                        end
                    end
                end
            end)
            assert.is_false(progressFrame().shown)
            local lines = hover().lines
            assert.are.equal(0, #lines)
        end)

        it("hides the progress line when the selected list is missing", function()
            WowStub.load({ class = "druid", build = "" }, function(data)
                data.lists = {}
            end)
            ForeverBiSDB.class = "druid"
            assert.is_false(progressFrame().shown)
        end)
    end)
end)
