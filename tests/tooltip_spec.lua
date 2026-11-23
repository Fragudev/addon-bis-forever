-- Item tooltip decoration against a tiny inline fixture and recording tooltips.
local PHASES = {
    { id = "lvl20", label = "Level 20", level = 20 },
    { id = "lvl40", label = "Level 40", level = 40 },
    { id = "lvl60", label = "Level 60 (pre-raid)", level = 60 },
}

local DAGGER_SOURCE = {
    kind = "dungeon",
    text = "Defias Strip Miner, The Deadmines",
    zone = "The Deadmines",
    boss = "Defias Strip Miner",
    dropRate = 4.2,
}

local function item(id, source)
    return { id = id, name = "Item " .. id, source = source }
end

--- A route whose phases each list one Head slot; phases not given are empty (every real route has every bracket).
local function route(label, phases)
    local result = { label = label, phases = {} }
    for _, phase in ipairs(PHASES) do
        result.phases[phase.id] = { slots = { { slot = "Head", items = phases[phase.id] or {} } } }
    end
    return result
end

-- Item 1 (Dagger) is wanted by many specs; item 3 only by Combat at 60; item 4 only by Feral; item 6 only by Fire.
local function fixture()
    return {
        schema = 2,
        phases = PHASES,
        lists = {
            ["rogue/combat"] = route("Combat", {
                lvl20 = { item(1, DAGGER_SOURCE), item(2, { kind = "world", text = "World Drop" }) },
                lvl40 = { item(2), item(1, DAGGER_SOURCE) },
                lvl60 = { item(3, { kind = "dungeon", text = "Boss, Zone", dropRate = 30.0 }), item(1) },
            }),
            ["rogue/assassination"] = route("Assassination", { lvl20 = { item(1) } }),
            ["rogue/subtlety"] = route("Subtlety", { lvl20 = { item(9), item(8), item(1) } }),
            ["druid/feral"] = route("Feral", { lvl20 = { item(4), item(1) } }),
            ["druid/tank"] = route("Guardian", { lvl20 = { item(1) } }),
            ["warrior/fury"] = route("Fury", { lvl20 = { item(9), item(8), item(1) } }),
            ["mage/fire"] = route("Fire", { lvl20 = { item(5), item(6), item(7), item(8), item(1) } }),
            ["priest/shadow"] = route("Shadow", { lvl60 = { item(1), item(7) } }),
        },
    }
end

local function newTooltip()
    local tooltip = { lines = {} }
    function tooltip.AddLine(self, text, r, g, b)
        table.insert(self.lines, { text = text, r = r, g = g, b = b })
    end
    return tooltip
end

-- The stubbed GameTooltip global is read-only for luacheck; this accessor lets specs override its methods.
local function gameTooltip()
    return _G.GameTooltip
end

--- Line texts with texture escapes (class icons) removed.
local function texts(tooltip)
    local result = {}
    for _, line in ipairs(tooltip.lines) do
        table.insert(result, (line.text:gsub("|T.-|t ?", "")))
    end
    return result
end

local function color(line)
    return { line.r, line.g, line.b }
end

-- Talent points per tree (1-3) for the stubbed GetTalentTabInfo; nil means no point spent.
local talents

-- Chunks from loadfile run in the real _G, so write the globals through it.
local function setup(player, data, points)
    WowStub.reset()
    WowStub.player = player or { class = "Rogue", token = "ROGUE", level = 20 }
    talents = points or { 0, 31, 0 }
    _G.GetTalentTabInfo = function(tab)
        return tab, "Tree " .. tab, "", "icon" .. tab, talents[tab] or 0
    end
    _G.ForeverBiSData = WowStub.wrapSource(data or fixture())
    WowStub.loadFiles({ "ForeverBiS_Model.lua" })
end

local function installProcessor()
    local calls = {}
    _G.Enum = { TooltipDataType = { Item = 0 } }
    _G.TooltipDataProcessor = {
        AddTooltipPostCall = function(kind, callback)
            table.insert(calls, { kind = kind, callback = callback })
        end,
    }
    WowStub.loadTooltip()
    return calls
end

--- The tooltip lines for an item through the public post call hook.
local function show(itemId)
    local tooltip = newTooltip()
    installProcessor()[1].callback(tooltip, { id = itemId })
    return tooltip
end

local FULL_DAGGER = {
    " ",
    "Forever BiS",
    "BiS #1 for Combat (Level 20)",
    "Source: Defias Strip Miner, The Deadmines (4.2%)",
    "Also for: Assassination #1, Subtlety #3",
    "Druid: Guardian #1, Feral #2",
    "Warrior: Fury #3",
    "Mage: Fire #5",
}

describe("ForeverBiS tooltips", function()
    after_each(function()
        _G.ForeverBiSData, _G.ForeverBiSDB = nil, nil
        _G.ForeverBiSModel, _G.ForeverBiSLists, _G.ForeverBiSItemIDs, _G.ForeverBiSBuildLabels = nil, nil, nil, nil
        _G.GetItemInfo = function() end
        _G.GetTalentTabInfo, _G.CLASS_ICON_TCOORDS, _G.LOCALIZED_CLASS_NAMES_MALE = nil, nil, nil
    end)

    describe("hook selection", function()
        it("registers a post call for item tooltips when TooltipDataProcessor exists", function()
            setup()
            local calls = installProcessor()
            assert.are.equal(1, #calls)
            assert.are.equal(0, calls[1].kind)
            assert.are.equal("processor", ForeverBiSTooltip.install())
        end)

        it("appends the BiS block through the post call", function()
            setup()
            local tooltip = show(2)
            assert.are.same({
                " ",
                "Forever BiS",
                "BiS #2 for Combat (Level 20)",
                "Source: World Drop",
            }, texts(tooltip))
            assert.are.same({ 1, 0.89, 0.35 }, color(tooltip.lines[2]))
        end)

        it("falls back to the item name for data rows without an id", function()
            local data = fixture()
            data.lists["rogue/combat"].phases.lvl20.slots[1].items[3] = { name = "Nameless" }
            setup(nil, data)
            _G.GetItemInfo = function(id)
                return id == 555 and "Nameless" or nil
            end
            assert.are.equal("BiS #3 for Combat (Level 20)", show(555).lines[3].text)
        end)

        it("prefers C_Item.GetItemNameByID for the fallback name", function()
            local data = fixture()
            data.lists["rogue/combat"].phases.lvl20.slots[1].items[3] = { name = "Nameless" }
            setup(nil, data)
            _G.C_Item.GetItemNameByID = function()
                return "Nameless"
            end
            local tooltip = show(555)
            _G.C_Item.GetItemNameByID = nil
            assert.are.equal(3, #tooltip.lines)
        end)

        it("uses OnTooltipSetItem hooks on GameTooltip and ItemRefTooltip without TooltipDataProcessor", function()
            setup()
            _G.ItemRefTooltip = CreateFrame("GameTooltip", nil, UIParent)
            WowStub.loadTooltip()
            for _, tooltip in ipairs({ GameTooltip, ItemRefTooltip }) do
                local lines = {}
                tooltip.AddLine = function(_, text)
                    table.insert(lines, text)
                end
                tooltip.GetItem = function()
                    return "Item 2", "|cff1eff00|Hitem:2::::::::20|h[Item 2]|h|r"
                end
                WowStub.fireHooks(tooltip, "OnTooltipSetItem")
                assert.are.same({ " ", "Forever BiS", "BiS #2 for Combat (Level 20)", "Source: World Drop" }, lines)
            end
        end)

        it("decorates a tooltip once until it is cleared", function()
            setup()
            WowStub.loadTooltip()
            local lines = {}
            gameTooltip().AddLine = function(_, text)
                table.insert(lines, text)
            end
            gameTooltip().GetItem = function()
                return "Item 2", "item:2"
            end
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            assert.are.equal(4, #lines)
            WowStub.fireHooks(GameTooltip, "OnTooltipCleared")
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            assert.are.equal(8, #lines)
        end)

        it("ignores tooltips without an item link", function()
            setup()
            WowStub.loadTooltip()
            gameTooltip().GetItem = function() end
            assert.has_no.errors(function()
                WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            end)
            gameTooltip().GetItem = function()
                return "x", "spell:1"
            end
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            assert.are.same({}, WowStub.tooltip.lines)
        end)

        it("loads without any tooltip API", function()
            setup()
            _G.GameTooltip = nil
            assert.has_no.errors(WowStub.loadTooltip)
            WowStub.reset()
        end)
    end)

    describe("block (a): your spec", function()
        it("shows the rank in the current bracket in green for rank 1 and neutral below", function()
            setup()
            local tooltip = show(1)
            assert.are.equal("BiS #1 for Combat (Level 20)", tooltip.lines[3].text)
            assert.are.same({ 0.35, 1, 0.35 }, color(tooltip.lines[3]))
            setup({ class = "Rogue", token = "ROGUE", level = 45 })
            tooltip = show(1)
            assert.are.equal("BiS #2 for Combat (Level 40)", tooltip.lines[3].text)
            assert.are.same({ 0.85, 0.85, 0.85 }, color(tooltip.lines[3]))
        end)

        it("takes the highest bracket at or below the player's level, and the lowest one below level 20", function()
            for level, expected in pairs({
                [12] = "BiS #1 for Combat (Level 20)",
                [39] = "BiS #1 for Combat (Level 20)",
                [40] = "BiS #2 for Combat (Level 40)",
                [60] = "BiS #2 for Combat (Level 60 (pre-raid))",
            }) do
                setup({ class = "Rogue", token = "ROGUE", level = level })
                assert.are.equal(expected, show(1).lines[3].text)
            end
        end)

        it("ignores the phase picked in the window", function()
            setup()
            _G.ForeverBiSCharDB = { phase = "lvl60" }
            assert.are.equal("BiS #1 for Combat (Level 20)", show(1).lines[3].text)
            _G.ForeverBiSCharDB = nil
        end)

        it("names the brackets that list the item when the current one does not", function()
            setup()
            assert.are.same({
                " ",
                "Forever BiS",
                "BiS for Combat at Level 60 (pre-raid) #1",
                "Source: Boss, Zone (30%)",
            }, texts(show(3)))
        end)

        it("says the item is not BiS for your spec when only others want it", function()
            setup()
            local tooltip = show(4)
            assert.are.same({ " ", "Forever BiS", "Not BiS for Combat", "Druid: Feral #1" }, texts(tooltip))
            assert.are.same({ 0.6, 0.6, 0.6 }, color(tooltip.lines[3]))
        end)

        it("formats the drop chance with at most two decimals and greys the source line", function()
            local data = fixture()
            local items = data.lists["rogue/combat"].phases.lvl20.slots[1].items
            items[1].source = { kind = "dungeon", text = "Boss, Zone", dropRate = 0.456 }
            items[2].source = { kind = "dungeon", text = "Boss, Zone", dropRate = 0 }
            setup(nil, data)
            local tooltip = show(1)
            assert.are.equal("Source: Boss, Zone (0.46%)", tooltip.lines[4].text)
            assert.are.same({ 0.6, 0.6, 0.6 }, color(tooltip.lines[4]))
            assert.are.equal("Source: Boss, Zone", show(2).lines[4].text)
        end)

        it("leaves out sources the data does not know", function()
            local data = fixture()
            data.lists["rogue/combat"].phases.lvl20.slots[1].items[2].source =
                { kind = "unknown", text = "Source not listed by wowsims" }
            setup(nil, data)
            assert.are.same({ " ", "Forever BiS", "BiS #2 for Combat (Level 20)" }, texts(show(2)))
        end)
    end)

    describe("block (b): your other specs", function()
        it("lists the other specs of your class by rank", function()
            setup()
            assert.are.equal("Also for: Assassination #1, Subtlety #3", show(1).lines[5].text)
        end)

        it("only counts specs that list the item in their current bracket", function()
            setup({ class = "Rogue", token = "ROGUE", level = 40 })
            assert.are.same({
                " ",
                "Forever BiS",
                "BiS #2 for Combat (Level 40)",
                "Source: Defias Strip Miner, The Deadmines (4.2%)",
            }, texts(show(1)))
        end)

        it("treats every spec of your class alike without talent points", function()
            setup(nil, nil, { 0, 0, 0 })
            assert.are.same({
                " ",
                "Forever BiS",
                "Source: Defias Strip Miner, The Deadmines (4.2%)",
                "Your class: Assassination #1, Combat #1, Subtlety #3",
                "Druid: Guardian #1, Feral #2",
                "Warrior: Fury #3",
                "+1 more - hold Shift",
            }, texts(show(1)))
        end)

        it("shows nothing without a spec when only your class wants it and other specs are off", function()
            setup(nil, nil, { 0, 0, 0 })
            _G.ForeverBiSDB = { tooltipSpecs = false }
            assert.are.same({}, show(2).lines)
        end)
    end)

    describe("block (c): other classes", function()
        it("shows one class-colored row per class, best class first, with every spec and rank", function()
            setup()
            _G.ForeverBiSDB = { tooltipCompact = false }
            local tooltip = show(1)
            assert.are.same(FULL_DAGGER, texts(tooltip))
            assert.are.same({ 1, 0.49, 0.04 }, color(tooltip.lines[6]))
            assert.are.same({ 0.85, 0.85, 0.85 }, color(tooltip.lines[7])) -- no RAID_CLASS_COLORS entry
        end)

        it("leads each row with the class icon and uses the client's class names", function()
            setup()
            _G.CLASS_ICON_TCOORDS = { DRUID = { 0.75, 1, 0, 0.25 } }
            _G.LOCALIZED_CLASS_NAMES_MALE = { DRUID = "Druida" }
            local row = show(4).lines[4].text
            assert.are.equal(
                "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:14:14:0:0:256:256:192:256:0:64|t "
                    .. "Druida: Feral #1",
                row
            )
        end)

        it("leaves out classes whose current bracket does not list the item", function()
            setup()
            _G.ForeverBiSDB = { tooltipCompact = false }
            assert.is_nil(table.concat(texts(show(1)), "|"):find("Shadow", 1, true))
        end)

        it("caps the rows in compact mode, which is on by default", function()
            setup()
            local tooltip = show(1)
            assert.are.same({
                "Druid: Guardian #1, Feral #2",
                "Warrior: Fury #3",
                "+1 more - hold Shift",
            }, { texts(tooltip)[6], texts(tooltip)[7], texts(tooltip)[8] })
            assert.are.equal(8, #tooltip.lines)
            assert.are.same({ 0.6, 0.6, 0.6 }, color(tooltip.lines[8]))
        end)

        it("shows the full rows while Shift is held in compact mode", function()
            setup()
            WowStub.shift = true
            assert.are.same(FULL_DAGGER, texts(show(1)))
        end)

        it("shows nothing for another class's item outside your class, or for an unknown item", function()
            setup({ class = "Priest", token = "PRIEST", level = 20 })
            local tooltip = show(3)
            assert.are.same({}, tooltip.lines)
            assert.are.same({}, show(12345).lines)
        end)
    end)

    describe("refreshing on Shift", function()
        local function modifierFrame()
            for _, frame in ipairs(WowStub.frames) do
                if frame.events.MODIFIER_STATE_CHANGED then
                    return frame
                end
            end
        end

        local function hoveredItem()
            local entered = 0
            local owner = CreateFrame("Button", nil, UIParent)
            owner:SetScript("OnEnter", function()
                entered = entered + 1
            end)
            gameTooltip().GetOwner = function()
                return owner
            end
            gameTooltip().GetItem = function()
                return "Item 1", "item:1"
            end
            return function()
                return entered
            end
        end

        it("re-enters the hovered item's owner when Shift changes in compact mode", function()
            setup()
            installProcessor()
            local entered = hoveredItem()
            local frame = modifierFrame()
            WowStub.fire(frame, "OnEvent", "MODIFIER_STATE_CHANGED", "LSHIFT", 1)
            assert.are.equal(1, entered())
            WowStub.fire(frame, "OnEvent", "MODIFIER_STATE_CHANGED", "LCTRL", 1)
            assert.are.equal(1, entered())
        end)

        it("does nothing outside compact mode or without a shown item tooltip", function()
            setup()
            installProcessor()
            local entered = hoveredItem()
            local frame = modifierFrame()
            _G.ForeverBiSDB = { tooltipCompact = false }
            WowStub.fire(frame, "OnEvent", "MODIFIER_STATE_CHANGED", "RSHIFT", 1)
            _G.ForeverBiSDB = nil
            gameTooltip():Hide()
            WowStub.fire(frame, "OnEvent", "MODIFIER_STATE_CHANGED", "RSHIFT", 0)
            gameTooltip():Show()
            gameTooltip().GetItem = function() end
            WowStub.fire(frame, "OnEvent", "MODIFIER_STATE_CHANGED", "RSHIFT", 1)
            assert.are.equal(0, entered())
        end)
    end)

    describe("settings", function()
        it("adds nothing when ForeverBiSDB.tooltip is false", function()
            setup()
            _G.ForeverBiSDB = { tooltip = false }
            assert.are.same({}, show(1).lines)
        end)

        it("treats a missing ForeverBiSDB as enabled and reads it at tooltip time", function()
            setup()
            _G.ForeverBiSDB = nil
            local callback = installProcessor()[1].callback
            _G.ForeverBiSDB = { tooltip = false } -- replaced after load, like the client does at PLAYER_LOGIN
            local tooltip = newTooltip()
            callback(tooltip, { id = 2 })
            assert.are.same({}, tooltip.lines)
            _G.ForeverBiSDB = nil
            callback(tooltip, { id = 2 })
            assert.are.equal(4, #tooltip.lines)
        end)

        it("drops your spec line and the source with tooltipSpec off", function()
            setup()
            _G.ForeverBiSDB = { tooltipSpec = false, tooltipCompact = false }
            assert.are.same({
                " ",
                "Forever BiS",
                "Also for: Assassination #1, Subtlety #3",
                "Druid: Guardian #1, Feral #2",
                "Warrior: Fury #3",
                "Mage: Fire #5",
            }, texts(show(1)))
        end)

        it("drops your other specs with tooltipSpecs off", function()
            setup()
            _G.ForeverBiSDB = { tooltipSpecs = false }
            assert.is_nil(table.concat(texts(show(1)), "|"):find("Also for", 1, true))
        end)

        it("drops the class rows with tooltipClasses off", function()
            setup()
            _G.ForeverBiSDB = { tooltipClasses = false }
            assert.are.same({
                " ",
                "Forever BiS",
                "BiS #1 for Combat (Level 20)",
                "Source: Defias Strip Miner, The Deadmines (4.2%)",
                "Also for: Assassination #1, Subtlety #3",
            }, texts(show(1)))
            assert.are.same({}, show(4).lines)
        end)

        it("adds nothing with every block off", function()
            setup()
            _G.ForeverBiSDB = { tooltipSpec = false, tooltipSpecs = false, tooltipClasses = false }
            assert.are.same({}, show(1).lines)
        end)
    end)

    describe("failing silently", function()
        it("does not error when the model is missing", function()
            setup()
            local callback = installProcessor()[1].callback
            _G.ForeverBiSModel = nil
            local tooltip = newTooltip()
            assert.has_no.errors(function()
                callback(tooltip, { id = 1 })
            end)
            assert.are.same({}, tooltip.lines)
        end)

        it("does not error when the data is missing", function()
            setup()
            local callback = installProcessor()[1].callback
            _G.ForeverBiSData = nil
            assert.has_no.errors(function()
                callback(newTooltip(), { id = 1 })
            end)
        end)

        it("does not error on odd tooltips or payloads", function()
            setup()
            local callback = installProcessor()[1].callback
            assert.has_no.errors(function()
                callback(nil, { id = 1 })
                callback(newTooltip(), nil)
                callback(newTooltip(), { id = "1" })
                callback({}, { id = 1 })
                callback(
                    setmetatable({}, {
                        __index = function()
                            error("boom")
                        end,
                    }),
                    { id = 1 }
                )
            end)
        end)

        it("does not error when UnitClass is not usable", function()
            setup()
            _G.UnitClass = function() end
            local tooltip = show(1)
            _G.UnitClass = function()
                return WowStub.player.class, WowStub.player.token
            end
            assert.are.same({}, tooltip.lines)
        end)

        it("does not error without the talent API", function()
            setup()
            _G.GetTalentTabInfo = nil
            assert.are.equal("Your class: Assassination #1, Combat #1, Subtlety #3", show(1).lines[4].text)
        end)
    end)

    describe("the addon's own window", function()
        it("is skipped when the tooltip owner lives inside the window", function()
            setup()
            local window = CreateFrame("Frame", "ForeverBiSFrame", UIParent)
            local content = CreateFrame("Frame", nil, window)
            local icon = CreateFrame("Button", nil, content)
            local tooltip = newTooltip()
            tooltip.GetOwner = function()
                return icon
            end
            local callback = installProcessor()[1].callback
            callback(tooltip, { id = 2 })
            assert.are.same({}, tooltip.lines)
            tooltip.GetOwner = function()
                return UIParent
            end
            callback(tooltip, { id = 2 })
            assert.are.equal(4, #tooltip.lines)
            _G.ForeverBiSFrame = nil
        end)

        it("is skipped on the OnTooltipSetItem path too", function()
            setup()
            local window = CreateFrame("Frame", "ForeverBiSFrame", UIParent)
            WowStub.loadTooltip()
            local added = 0
            gameTooltip().AddLine = function()
                added = added + 1
            end
            gameTooltip().GetOwner = function()
                return window
            end
            gameTooltip().GetItem = function()
                return "Item 1", "item:1"
            end
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            assert.are.equal(0, added)
            _G.ForeverBiSFrame = nil
        end)
    end)

    describe("slash subcommands", function()
        local printed, realPrint

        before_each(function()
            printed, realPrint = {}, _G.print
            _G.print = function(text)
                table.insert(printed, text)
            end
        end)

        after_each(function()
            _G.print = realPrint
        end)

        it("toggles the tooltip block with /bis tooltip", function()
            WowStub.load({ class = "rogue", build = "pve" })
            SlashCmdList["FOREVERBIS"]("tooltip")
            assert.is_false(ForeverBiSDB.tooltip)
            assert.are.same({ "Forever BiS tooltips: off" }, printed)
            SlashCmdList["FOREVERBIS"](" TOOLTIP ")
            assert.is_true(ForeverBiSDB.tooltip)
            assert.are.equal("Forever BiS tooltips: on", printed[2])
            assert.is_false(ForeverBiSFrame:IsShown())
        end)

        it("toggles the other-classes block with /bis tooltip all", function()
            WowStub.load({ class = "rogue", build = "pve" })
            SlashCmdList["FOREVERBIS"]("tooltip all")
            assert.is_false(ForeverBiSDB.tooltipClasses)
            assert.are.same({ "Forever BiS tooltips: your class only" }, printed)
            SlashCmdList["FOREVERBIS"]("tooltip all")
            assert.is_true(ForeverBiSDB.tooltipClasses)
            assert.are.equal("Forever BiS tooltips: all classes", printed[2])
        end)

        it("turns a block off for the next tooltip", function()
            WowStub.load({ class = "rogue", build = "pve" })
            SlashCmdList["FOREVERBIS"]("tooltip classes")
            assert.are.same({ "Forever BiS tooltip, other classes: off" }, printed)
            assert.is_false(WowStub.ns.Settings.tooltipOption("classes"))
        end)

        it("keeps toggling the window for anything else", function()
            WowStub.load({ class = "rogue", build = "pve" })
            SlashCmdList["FOREVERBIS"]()
            assert.is_true(ForeverBiSFrame:IsShown())
            SlashCmdList["FOREVERBIS"]("")
            assert.is_false(ForeverBiSFrame:IsShown())
            SlashCmdList["FOREVERBIS"]("tooltip nonsense")
            assert.is_true(ForeverBiSFrame:IsShown())
            SlashCmdList["FOREVERBIS"]("options")
            assert.is_false(ForeverBiSFrame:IsShown())
            assert.are.same({}, printed)
            assert.is_nil(ForeverBiSDB.tooltip)
        end)
    end)
end)
