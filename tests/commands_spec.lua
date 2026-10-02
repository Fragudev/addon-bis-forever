local realPrint = print
local printed, toggles

local function loadCommands(db)
    WowStub.reset()
    _G.ForeverBiSDB = db or {}
    local ns = WowStub.loadFiles({
        "ForeverBiS_Locale.lua",
        "ForeverBiS_Data.lua",
        "ForeverBiS_Model.lua",
        "Core/Settings.lua",
        "Core/Catalog.lua",
        "Core/Sources.lua",
        "Core/Lists.lua",
        "Core/Share.lua",
        "Adapters/Items.lua",
        "Adapters/Player.lua",
        "Adapters/Chat.lua",
        "App/Commands.lua",
    })
    ns.Settings.bind()
    toggles = 0
    ns.toggleWindow = function()
        toggles = toggles + 1
    end
    return ns.Commands
end

describe("Commands", function()
    before_each(function()
        printed = {}
        _G.print = function(...)
            table.insert(printed, table.concat({ ... }, " "))
        end
    end)

    after_each(function()
        _G.print = realPrint
        _G.ForeverBiSDB = nil
    end)

    describe("parse", function()
        it("splits the command from its argument in lowercase", function()
            local Commands = loadCommands()
            assert.are.same({ "tooltip", "all", "all" }, { Commands.parse("  Tooltip   ALL  ") })
            assert.are.same({ "tooltip", "", "" }, { Commands.parse("tooltip") })
        end)

        it("keeps everything after the command so a slot name can have several words", function()
            local Commands = loadCommands()
            assert.are.same({ "link", "main", "main hand" }, { Commands.parse("link  Main Hand ") })
        end)

        it("returns empty parts for blank or missing input", function()
            local Commands = loadCommands()
            assert.are.same({ "", "", "" }, { Commands.parse("") })
            assert.are.same({ "", "", "" }, { Commands.parse("   ") })
            assert.are.same({ "", "", "" }, { Commands.parse(nil) })
        end)
    end)

    describe("dispatch", function()
        it("toggles the tooltip block with /bis tooltip", function()
            local Commands = loadCommands()
            Commands.dispatch("tooltip")
            assert.is_false(ForeverBiSDB.tooltip)
            assert.are.same({ "Forever BiS tooltips: off" }, printed)
            assert.are.equal(0, toggles)
        end)

        it("toggles other classes with /bis tooltip all", function()
            local Commands = loadCommands()
            Commands.dispatch("tooltip all")
            assert.is_true(ForeverBiSDB.tooltipAllClasses)
            assert.are.same({ "Forever BiS tooltips: all classes" }, printed)
            Commands.dispatch("tooltip all")
            assert.are.equal("Forever BiS tooltips: your class only", printed[2])
        end)

        it("toggles the window for empty and unknown input", function()
            local Commands = loadCommands()
            Commands.dispatch("")
            Commands.dispatch(nil)
            Commands.dispatch("options")
            assert.are.equal(3, toggles)
            assert.are.same({}, printed)
        end)

        it("toggles the window for a tooltip argument it does not know", function()
            local Commands = loadCommands()
            Commands.dispatch("tooltip nonsense")
            assert.are.equal(1, toggles)
            assert.is_nil(ForeverBiSDB.tooltip)
        end)

        it("runs a handler added to the table", function()
            local Commands = loadCommands()
            local received
            Commands.handlers.ping = function(argument)
                received = argument
                return true
            end
            Commands.dispatch("Ping now")
            assert.are.equal("now", received)
            assert.are.equal(0, toggles)
        end)
    end)

    it("registers /bis and /foreverbis", function()
        local Commands = loadCommands()
        Commands.install()
        assert.are.equal("/bis", _G.SLASH_FOREVERBIS1)
        assert.are.equal("/foreverbis", _G.SLASH_FOREVERBIS2)
        assert.are.equal(Commands.dispatch, SlashCmdList["FOREVERBIS"])
    end)

    describe("link", function()
        local function sent()
            local messages = {}
            for _, entry in ipairs(WowStub.chat) do
                table.insert(messages, entry.message)
            end
            return messages
        end

        it("posts the ranked items of a slot", function()
            local Commands = loadCommands()
            Commands.dispatch("link head")
            local messages = sent()
            assert.is_true(#messages >= 1)
            assert.are.equal("Head BiS: 1. ", messages[1]:sub(1, 13))
            assert.is_truthy(messages[1]:find("|Hitem:", 1, true))
            assert.are.equal(0, toggles)
        end)

        it("accepts a slot name with several words, in any case", function()
            local Commands = loadCommands()
            Commands.dispatch("link Main Hand")
            assert.is_true(#sent() >= 1)
            for _, message in ipairs(sent()) do
                assert.is_truthy(message:find(" BiS: ", 1, true))
            end
        end)

        it("posts one top item per slot, split under the chat limit", function()
            local Commands = loadCommands()
            Commands.dispatch("link")
            local messages = sent()
            assert.is_true(#messages > 1)
            for _, message in ipairs(messages) do
                assert.is_true(#message < 255, #message)
                assert.is_truthy(message:find("BiS: ", 1, true))
            end
            assert.is_truthy(messages[1]:find("Head: ", 1, true))
        end)

        it("posts to the party, the raid or say depending on the group", function()
            local Commands = loadCommands()
            local channels = {}
            for _, group in ipairs({ "solo", "party", "raid" }) do
                WowStub.chat = {}
                WowStub.group = group ~= "solo" and group or nil
                Commands.dispatch("link head")
                channels[#channels + 1] = WowStub.chat[1].channel
            end
            assert.are.same({ "SAY", "PARTY", "RAID" }, channels)
        end)

        it("prints the valid slots for an unknown slot name and sends nothing", function()
            local Commands = loadCommands()
            Commands.dispatch("link tabard")
            assert.are.equal(0, #WowStub.chat)
            assert.is_truthy(printed[1]:find("Unknown slot 'tabard'", 1, true))
            assert.is_truthy(printed[1]:find("Head", 1, true))
        end)

        it("says so when no list is loaded", function()
            local Commands = loadCommands()
            _G.ForeverBiSData, _G.ForeverBiSLists = nil, nil
            Commands.dispatch("link")
            assert.are.equal(0, #WowStub.chat)
            assert.is_truthy(printed[1]:find("No BiS list", 1, true))
        end)
    end)
end)
