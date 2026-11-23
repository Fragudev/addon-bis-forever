-- Composition root: layers the modules and wires them together. Core (pure logic) feeds Adapters (the only
-- callers of the client API), UI panels draw and never call each other, and App owns events and commands.
local _, ns = ...

local rendering, queued = false, false

local function renderOnce()
    ns.Selectors.refresh()
    ns.MainFrame.refresh()
    ns.BisGrid.refresh()
    ns.MainFrame.settle()
end

--- The single way a panel asks for a redraw. Requests made while drawing run once afterwards, and requests made
--- while the window is hidden are dropped: showing the window redraws it.
function ns.requestRender()
    -- A hidden window draws nothing: opening it always asks for a redraw, so nothing is lost.
    if not ns.MainFrame.isShown() then
        return
    end
    if rendering then
        queued = true
        return
    end
    rendering = true
    local ok, err = pcall(function()
        renderOnce()
        while queued do
            queued = false
            renderOnce()
        end
    end)
    rendering = false
    if not ok then
        error(err, 0)
    end
end

--- Opening the window detects the spec first, so the first open shows the player's own list.
function ns.toggleWindow()
    if not ns.MainFrame.isShown() then
        ns.Events.detectSelection()
    end
    ns.MainFrame.toggle()
end

function ns.openWindow()
    if not ns.MainFrame.isShown() then
        ns.Events.detectSelection()
    end
    ns.MainFrame.open()
end

ns.Settings.bind()
local frame = ns.MainFrame.create()
ns.Selectors.create(frame)
ns.Help.create(frame)
ns.BisGrid.create(frame)
-- Closing the window ends an inspection: the next open shows the player's own list again.
frame:HookScript("OnHide", ns.Selectors.clearInspect)
ns.MinimapButton.create()
ns.DungeonNotice.create()
ns.Events.install()
ns.ZoneWatcher.install()
ns.Alerts.install()
ns.BisStar.install()
ns.Commands.install()
ns.Inspect.install()
ns.requestRender()
