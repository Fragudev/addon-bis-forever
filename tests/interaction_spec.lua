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
        it("hides items exclusive to the other faction", function()
            local key, item = findListWithItem(function(source)
                return source:find("alliance", 1, true) and not source:find("horde", 1, true)
            end)
            assert(key, "no alliance-only item in the data")
            loadList(key)
            assert.is_true(WowStub.hasText(item[1]))

            chooseOption(ForeverBiSFactionFilter, "Horde")
            assert.is_false(WowStub.hasText(item[1]))
            chooseOption(ForeverBiSFactionFilter, "Alliance")
            assert.is_true(WowStub.hasText(item[1]))
            chooseOption(ForeverBiSFactionFilter, "All Factions")
            assert.is_true(WowStub.hasText(item[1]))
        end)

        it("hides items exclusive to the other faction when filtering for alliance", function()
            local key, item = findListWithItem(function(source)
                return source:find("horde", 1, true) and not source:find("alliance", 1, true)
            end)
            assert(key, "no horde-only item in the data")
            loadList(key)
            chooseOption(ForeverBiSFactionFilter, "Alliance")
            assert.is_false(WowStub.hasText(item[1]))
        end)

        it("filters by source category", function()
            local key, item = findListWithItem(function(source)
                return source:find("^quest:") ~= nil
            end)
            assert(key, "no quest item in the data")
            loadList(key)
            assert.is_true(WowStub.hasText(item[1]))
            chooseOption(ForeverBiSSourceFilter, "Professions")
            assert.is_false(WowStub.hasText(item[1]))
            chooseOption(ForeverBiSSourceFilter, "Quests")
            assert.is_true(WowStub.hasText(item[1]))
        end)

        it("clears the search and every dropdown filter", function()
            local key, item = findListWithItem(function(source)
                return source:find("^quest:") ~= nil
            end)
            loadList(key)
            chooseOption(ForeverBiSSourceFilter, "Professions")
            local searchBox = textChangedBox()
            searchBox:SetText("zzzz-no-such-item")
            WowStub.fire(searchBox, "OnTextChanged")
            assert.is_true(WowStub.hasText("No items match"))

            local clear = WowStub.find("Button", function(b)
                return b.text == "Clear Filters"
            end)[1]
            WowStub.fire(clear, "OnClick")
            assert.is_false(WowStub.hasText("No items match"))
            assert.is_true(WowStub.hasText(item[1]))
            assert.are.equal("", searchBox:GetText())
        end)

        it("collapses and expands the filter bar", function()
            WowStub.load(nil)
            local toggle = WowStub.find("Button", function(b)
                return b.text == "Show Filters"
            end)[1]
            WowStub.fire(toggle, "OnClick")
            assert.are.equal("Hide Filters", toggle:GetText())
            assert.is_true(ForeverBiSFactionFilter:IsShown())
            WowStub.fire(toggle, "OnClick")
            assert.are.equal("Show Filters", toggle:GetText())
            assert.is_false(ForeverBiSFactionFilter:IsShown())
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
end)
