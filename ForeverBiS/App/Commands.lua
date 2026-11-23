-- Slash commands. Adding one means adding an entry to the handlers table.
local _, ns = ...

local Commands = {}
ns.Commands = Commands

local Settings, Player, Lists, Items, Share, Chat, L =
    ns.Settings, ns.Player, ns.Lists, ns.Items, ns.Share, ns.Chat, ns.L

local function currentView()
    local route = Settings.route()
    return Lists.view(route, Settings.bracket(route, Player.level()))
end

local function rankedParts(slot)
    local parts = {}
    for rank, item in ipairs(slot[2]) do
        parts[#parts + 1] = rank .. ". " .. Items.link(item[1])
    end
    return parts
end

local function topParts(slots)
    local parts = {}
    for _, slot in ipairs(slots) do
        if slot[2][1] then
            parts[#parts + 1] = slot[1] .. ": " .. Items.link(slot[2][1][1])
        end
    end
    return parts
end

--- The chat messages for /bis link: every ranked item of the named slot, or the top item of each slot.
--- Returns nil and the valid slot names when the name matches no slot.
local function linkMessages(view, slotQuery)
    local slots = view.data.slots
    if slotQuery == "" then
        local label = ForeverBiSModel.label(view.route) or view.route
        return Share.chunk(L["%s BiS: "]:format(label), topParts(slots))
    end
    local matched = Share.matchSlots(slots, slotQuery)
    if #matched == 0 then
        return nil, Share.slotNames(slots)
    end
    local messages = {}
    for _, slot in ipairs(matched) do
        for _, message in ipairs(Share.chunk(L["%s BiS: "]:format(slot[1]), rankedParts(slot), " ")) do
            messages[#messages + 1] = message
        end
    end
    return messages
end

--- /bis link [slot] posts the selected build and phase to the group (party, raid or say).
local function postLinks(_, rest, typed)
    local view = currentView()
    if not view.data then
        print(L["No BiS list is loaded for this build."])
        return true
    end
    local messages, validSlots = linkMessages(view, rest)
    if not messages then
        print(L["Unknown slot '%s'. Valid slots: %s"]:format(typed, table.concat(validSlots, ", ")))
        return true
    end
    for _, message in ipairs(messages) do
        Chat.send(message)
    end
    return true
end

--- Subcommand handlers by lowercase name. A handler gets the lowercase first argument, everything after the command
--- in lowercase, and the same text as typed. It returns true when it handled the input; anything else falls through
--- to toggling the window.
Commands.handlers = {
    -- /bis tooltip toggles the whole BiS tooltip block. /bis tooltip spec|specs|classes toggles one part of it (your
    -- spec, your class's other specs, other classes) and /bis tooltip compact toggles compact mode (hold Shift for the
    -- full rows). /bis tooltip all is kept as the old name of /bis tooltip classes.
    tooltip = function(argument)
        if argument == "all" then
            local on = Settings.toggleTooltipOption("classes")
            print(L["Forever BiS tooltips: "] .. (on and L["all classes"] or L["your class only"]))
            return true
        end
        if argument == "" then
            local on = Settings.toggleTooltip()
            print(L["Forever BiS tooltips: "] .. (on and L["on"] or L["off"]))
            return true
        end
        local names = {
            spec = L["your spec"],
            specs = L["your other specs"],
            classes = L["other classes"],
            compact = L["compact mode"],
        }
        if names[argument] then
            local on = Settings.toggleTooltipOption(argument)
            print(L["Forever BiS tooltip, %s: "]:format(names[argument]) .. (on and L["on"] or L["off"]))
            return true
        end
        return false
    end,
    link = postLinks,
    -- /bis dungeon toggles the notice offered when you enter a dungeon with listed items (on by default).
    dungeon = function()
        local on = Settings.toggleDungeonNotice()
        print(L["Forever BiS dungeon notice: "] .. (on and L["on"] or L["off"]))
        return true
    end,
    -- /bis minimap hides or shows the minimap button (shown by default).
    minimap = function()
        local on = Settings.toggleMinimapHidden()
        if ns.MinimapButton then
            ns.MinimapButton.refresh()
        end
        print(L["Forever BiS minimap button: "] .. (on and L["on"] or L["off"]))
        return true
    end,
    -- /bis stars toggles the BiS stars on bag, loot and quest reward buttons (on by default).
    stars = function()
        local on = Settings.toggleBisStars()
        if ns.BisStar then
            ns.BisStar.refresh()
        end
        print(L["Forever BiS stars: "] .. (on and L["on"] or L["off"]))
        return true
    end,
    -- /bis alerts toggles the BiS loot alerts (on by default).
    alerts = function()
        local on = Settings.toggleAlerts()
        print(L["Forever BiS alerts: "] .. (on and L["on"] or L["off"]))
        return true
    end,
}

--- Splits "command argument rest" into lowercase parts: the command, its first word and everything after the
--- command. All are empty strings for blank input.
function Commands.parse(message)
    local command, rest = string.lower(message or ""):match("^%s*(%S+)%s*(.-)%s*$")
    rest = rest or ""
    return command or "", rest:match("^%S*"), rest
end

function Commands.dispatch(message)
    local command, argument, rest = Commands.parse(message)
    local typed = (message or ""):match("^%s*%S+%s*(.-)%s*$") or ""
    local handler = Commands.handlers[command]
    if not (handler and handler(argument, rest, typed)) then
        ns.toggleWindow()
    end
end

function Commands.install()
    SLASH_FOREVERBIS1 = "/bis"
    SLASH_FOREVERBIS2 = "/foreverbis"
    SlashCmdList["FOREVERBIS"] = Commands.dispatch
end
