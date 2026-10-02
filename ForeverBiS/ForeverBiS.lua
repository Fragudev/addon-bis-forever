-- Composition root: layers the modules and wires them together. Core (pure logic) feeds Adapters (the only
-- callers of the client API), UI panels draw and never call each other, and App owns events and commands.
local _, ns = ...

local rendering, queued = false, nil

local function renderOnce(options)
    ns.Selectors.refresh()
    ns.FilterBar.refresh()
    local route = ns.Settings.route()
    local view = ns.Lists.view(route, ns.Settings.effectivePhase(route, ns.Player.level()))
    view.width = ns.MainFrame.refresh()
    ns.Progress.refresh(view)
    ns.ItemList.refresh(view, options)
    ns.PaperDoll.refresh(view)
    ns.MainFrame.settle()
end

--- The single way a panel asks for a redraw. Options: scrollTop, jumpTo (a slot key) and redraw (false skips the
--- redraw when only the scroll position changes). Requests made while drawing run once afterwards.
function ns.requestRender(options)
    if options and options.jumpTo and options.redraw == false then
        ns.ItemList.jumpTo(options.jumpTo)
        return
    end
    if rendering then
        queued = options or {}
        return
    end
    rendering = true
    local ok, err = pcall(function()
        renderOnce(options)
        while queued do
            local nextOptions = queued
            queued = nil
            renderOnce(nextOptions)
        end
    end)
    rendering = false
    if not ok then
        error(err, 0)
    end
end

ns.toggleWindow = ns.MainFrame.toggle
ns.openWindow = ns.MainFrame.open

ns.Settings.bind()
local frame = ns.MainFrame.create()
ns.Selectors.create(frame)
ns.Help.create(frame)
ns.ItemList.create(frame)
ns.Progress.create(ns.PaperDoll.create(frame))
ns.FilterBar.create(frame)
ns.MinimapButton.create()
ns.DungeonNotice.create()
ns.Events.install()
ns.ZoneWatcher.install()
ns.Alerts.install()
ns.Commands.install()
ns.requestRender()
