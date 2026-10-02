local realPrint = print
local printed, toggles

local function loadCommands(db)
    WowStub.reset()
    _G.ForeverBiSDB = db or {}
    local ns = WowStub.loadFiles({ "ForeverBiS_Locale.lua", "Core/Settings.lua", "App/Commands.lua" })
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
            assert.are.same({ "tooltip", "all" }, { Commands.parse("  Tooltip   ALL  ") })
            assert.are.same({ "tooltip", "" }, { Commands.parse("tooltip") })
        end)

        it("returns empty parts for blank or missing input", function()
            local Commands = loadCommands()
            assert.are.same({ "", "" }, { Commands.parse("") })
            assert.are.same({ "", "" }, { Commands.parse("   ") })
            assert.are.same({ "", "" }, { Commands.parse(nil) })
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
end)
