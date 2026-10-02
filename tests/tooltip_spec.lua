-- Item tooltip decoration against a tiny inline fixture and recording tooltips.
local function fixture()
    local function phase(items)
        return { slots = { { slot = "Head", items = items } } }
    end
    return {
        schema = 2,
        phases = {
            { id = "lvl30", label = "Level 30", level = 30 },
            { id = "lvl60", label = "Level 60", level = 60 },
        },
        lists = {
            ["rogue"] = {
                label = "Combat PvE",
                phases = {
                    lvl30 = phase({ { id = 1, name = "Dagger" }, { id = 2, name = "Mace" }, { name = "Nameless" } }),
                    lvl60 = phase({ { id = 3, name = "Blade" }, { id = 1, name = "Dagger" } }),
                },
            },
            ["druid"] = {
                label = "Feral PvE",
                phases = { lvl30 = phase({ { id = 2, name = "Mace" }, { id = 1, name = "Dagger" } }) },
            },
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

local function texts(tooltip)
    local result = {}
    for _, line in ipairs(tooltip.lines) do
        table.insert(result, line.text)
    end
    return result
end

-- Chunks from loadfile run in the real _G, so write the globals through it.
local function setup(player, data)
    WowStub.reset()
    WowStub.player = player or { class = "Rogue", token = "ROGUE", level = 30 }
    _G.ForeverBiSData = data or fixture()
    assert(loadfile("ForeverBiS/ForeverBiS_Model.lua"))()
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

describe("ForeverBiS tooltips", function()
    after_each(function()
        _G.ForeverBiSData, _G.ForeverBiSDB = nil, nil
        _G.ForeverBiSModel, _G.ForeverBiSLists, _G.ForeverBiSItemIDs, _G.ForeverBiSBuildLabels = nil, nil, nil, nil
        _G.GetItemInfo = function() end
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
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            assert.are.same({ " ", "Forever BiS", "BiS #1 Head - Combat PvE (Level 30)" }, texts(tooltip))
            assert.are.same({ 1, 0.89, 0.35 }, { tooltip.lines[2].r, tooltip.lines[2].g, tooltip.lines[2].b })
            assert.are.same({ 0.35, 1, 0.35 }, { tooltip.lines[3].r, tooltip.lines[3].g, tooltip.lines[3].b })
        end)

        it("colors lower ranks neutral", function()
            setup()
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 2 })
            assert.are.equal("BiS #2 Head - Combat PvE (Level 30)", tooltip.lines[3].text)
            assert.are.same({ 0.85, 0.85, 0.85 }, { tooltip.lines[3].r, tooltip.lines[3].g, tooltip.lines[3].b })
        end)

        it("falls back to the item name for data rows without an id", function()
            setup()
            _G.GetItemInfo = function(id)
                return id == 555 and "Nameless" or nil
            end
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 555 })
            assert.are.equal("BiS #3 Head - Combat PvE (Level 30)", tooltip.lines[3].text)
        end)

        it("prefers C_Item.GetItemNameByID for the fallback name", function()
            setup()
            _G.C_Item.GetItemNameByID = function()
                return "Nameless"
            end
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 555 })
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
                    return "Dagger", "|cff1eff00|Hitem:1::::::::30|h[Dagger]|h|r"
                end
                WowStub.fireHooks(tooltip, "OnTooltipSetItem")
                assert.are.same({ " ", "Forever BiS", "BiS #1 Head - Combat PvE (Level 30)" }, lines)
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
                return "Dagger", "item:1"
            end
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            assert.are.equal(3, #lines)
            WowStub.fireHooks(GameTooltip, "OnTooltipCleared")
            WowStub.fireHooks(GameTooltip, "OnTooltipSetItem")
            assert.are.equal(6, #lines)
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

    describe("content", function()
        it("shows only the player's class by default", function()
            setup()
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 2 })
            assert.are.equal(3, #tooltip.lines)
            assert.is_nil(table.concat(texts(tooltip), "|"):find("Feral", 1, true))
        end)

        it("shows every class with tooltipAllClasses and ranks the best first", function()
            setup()
            _G.ForeverBiSDB = { tooltipAllClasses = true }
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            assert.are.same({
                " ",
                "Forever BiS",
                "BiS #1 Head - Combat PvE (Level 30)",
                "BiS #2 Head - Feral PvE (Level 30)",
            }, texts(tooltip))
        end)

        it("shows nothing for another class's item or an unknown item", function()
            setup({ class = "Mage", token = "MAGE", level = 30 })
            local tooltip = newTooltip()
            local callback = installProcessor()[1].callback
            callback(tooltip, { id = 1 })
            callback(tooltip, { id = 12345 })
            assert.are.same({}, tooltip.lines)
        end)

        it("shows only the effective phase for the player's level", function()
            setup({ class = "Rogue", token = "ROGUE", level = 25 })
            local callback = installProcessor()[1].callback
            local tooltip = newTooltip()
            callback(tooltip, { id = 1 })
            assert.are.same({ " ", "Forever BiS", "BiS #1 Head - Combat PvE (Level 30)" }, texts(tooltip))
            _G.UnitLevel = function()
                return 60
            end
            tooltip = newTooltip()
            callback(tooltip, { id = 1 })
            assert.are.same({ " ", "Forever BiS", "BiS #2 Head - Combat PvE (Level 60)" }, texts(tooltip))
            _G.UnitLevel = function()
                return WowStub.player.level
            end
        end)

        it("ignores the phase picked in the window", function()
            setup()
            _G.ForeverBiSDB = { phase = "lvl60" }
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            assert.are.equal("BiS #1 Head - Combat PvE (Level 30)", tooltip.lines[3].text)
        end)

        it("still shows an item that is BiS only in another phase, with its phase label", function()
            setup()
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 3 })
            assert.are.same({ " ", "Forever BiS", "BiS #1 Head - Combat PvE (Level 60)" }, texts(tooltip))
        end)

        it("caps the block at four lines plus a +N more line", function()
            local data = fixture()
            local slots = {}
            for index = 1, 6 do
                slots[index] = { slot = "Slot" .. index, items = { { id = 1, name = "Dagger" } } }
            end
            data.lists.rogue.phases.lvl30.slots = slots
            setup(nil, data)
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            assert.are.equal(2 + 4 + 1, #tooltip.lines)
            assert.are.equal("+2 more", tooltip.lines[7].text)
        end)

        it("shows exactly four entries without a +N more line", function()
            local data = fixture()
            local slots = {}
            for index = 1, 4 do
                slots[index] = { slot = "Slot" .. index, items = { { id = 1, name = "Dagger" } } }
            end
            data.lists.rogue.phases.lvl30.slots = slots
            setup(nil, data)
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            assert.are.equal(6, #tooltip.lines)
        end)
    end)

    describe("settings", function()
        it("adds nothing when ForeverBiSDB.tooltip is false", function()
            setup()
            _G.ForeverBiSDB = { tooltip = false }
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            assert.are.same({}, tooltip.lines)
        end)

        it("treats a missing ForeverBiSDB as enabled and reads it at tooltip time", function()
            setup()
            _G.ForeverBiSDB = nil
            local callback = installProcessor()[1].callback
            _G.ForeverBiSDB = { tooltip = false } -- replaced after load, like the client does at PLAYER_LOGIN
            local tooltip = newTooltip()
            callback(tooltip, { id = 1 })
            assert.are.same({}, tooltip.lines)
            _G.ForeverBiSDB = nil
            callback(tooltip, { id = 1 })
            assert.are.equal(3, #tooltip.lines)
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
            local tooltip = newTooltip()
            installProcessor()[1].callback(tooltip, { id = 1 })
            _G.UnitClass = function()
                return WowStub.player.class, WowStub.player.token
            end
            assert.are.same({}, tooltip.lines)
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
            callback(tooltip, { id = 1 })
            assert.are.same({}, tooltip.lines)
            tooltip.GetOwner = function()
                return UIParent
            end
            callback(tooltip, { id = 1 })
            assert.are.equal(3, #tooltip.lines)
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
                return "Dagger", "item:1"
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

        it("toggles all classes with /bis tooltip all", function()
            WowStub.load({ class = "rogue", build = "pve" })
            SlashCmdList["FOREVERBIS"]("tooltip all")
            assert.is_true(ForeverBiSDB.tooltipAllClasses)
            assert.are.same({ "Forever BiS tooltips: all classes" }, printed)
            SlashCmdList["FOREVERBIS"]("tooltip all")
            assert.is_false(ForeverBiSDB.tooltipAllClasses)
            assert.are.equal("Forever BiS tooltips: your class only", printed[2])
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
