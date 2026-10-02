-- Slash commands. Adding one means adding an entry to the handlers table.
local _, ns = ...

local Commands = {}
ns.Commands = Commands

local Settings, L = ns.Settings, ns.L

--- Subcommand handlers by lowercase name. A handler gets the lowercase argument and returns true when it handled
--- the input; anything else falls through to toggling the window.
Commands.handlers = {
    -- /bis tooltip toggles the BiS tooltip block; /bis tooltip all toggles other classes in it.
    tooltip = function(argument)
        if argument == "all" then
            local on = Settings.toggleTooltipAllClasses()
            print(L["Forever BiS tooltips: "] .. (on and L["all classes"] or L["your class only"]))
            return true
        end
        if argument == "" then
            local on = Settings.toggleTooltip()
            print(L["Forever BiS tooltips: "] .. (on and L["on"] or L["off"]))
            return true
        end
        return false
    end,
}

--- Splits "command argument" into lowercase parts; both are empty strings for blank input.
function Commands.parse(message)
    local command, argument = string.lower(message or ""):match("^%s*(%S+)%s*(%S*)")
    return command or "", argument or ""
end

function Commands.dispatch(message)
    local command, argument = Commands.parse(message)
    local handler = Commands.handlers[command]
    if not (handler and handler(argument)) then
        ns.toggleWindow()
    end
end

function Commands.install()
    SLASH_FOREVERBIS1 = "/bis"
    SLASH_FOREVERBIS2 = "/foreverbis"
    SlashCmdList["FOREVERBIS"] = Commands.dispatch
end
