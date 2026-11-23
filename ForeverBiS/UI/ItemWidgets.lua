-- Pooled widgets for the panels that redraw: frames, textures and labels taken back on every draw.
local _, ns = ...

local ItemWidgets = {}
ns.ItemWidgets = ItemWidgets

local Skin = ns.Skin

-- Widgets are never freed by the client, so every drawn widget comes from a per-container pool: release() hides the
-- ones taken since the last release and parks them under a hidden holder, and the next draw takes them back.
local holder

local function holderFrame()
    if not holder then
        holder = CreateFrame("Frame")
        holder:Hide()
    end
    return holder
end

local function poolOf(container)
    local pool = container.widgetPool
    if not pool then
        pool = { free = {}, active = {} }
        container.widgetPool = pool
    end
    return pool
end

--- A pooled widget of the kind `key` inside container: a free one when there is, else the result of create().
local function take(container, key, create)
    local pool = poolOf(container)
    local free = pool.free[key]
    local widget = free and table.remove(free)
    if widget then
        widget:SetParent(container)
        widget:Show()
    else
        widget = create()
        widget.poolKey = key
    end
    table.insert(pool.active, widget)
    return widget
end

--- Hides and parks every widget taken from the container since the last release.
function ItemWidgets.release(container)
    local pool = container.widgetPool
    if not pool then
        return
    end
    -- Parked back to front, so the next draw takes the widgets in the order they were drawn.
    for index = #pool.active, 1, -1 do
        local widget = pool.active[index]
        if widget.poolReset then
            widget:poolReset()
        end
        widget:Hide()
        widget:ClearAllPoints()
        widget:SetParent(holderFrame())
        local free = pool.free[widget.poolKey]
        if not free then
            free = {}
            pool.free[widget.poolKey] = free
        end
        table.insert(free, widget)
    end
    pool.active = {}
end

--- A pooled frame of frameType. build(frame) runs once when it is created; it may set frame.poolReset, called on
--- release. Pooled frames are created in any order, so creation order cannot keep a row's buttons above the frame
--- that washes the row on hover: each draw sets the level explicitly instead. `levelOffset` (default 2) is added to
--- the container's level; the hover frame passes 1 so the buttons over it keep the mouse and their tooltips.
function ItemWidgets.frame(container, key, frameType, build, levelOffset)
    local frame = take(container, key, function()
        local created = CreateFrame(frameType, nil, container)
        build(created)
        return created
    end)
    frame:SetFrameLevel(container:GetFrameLevel() + (levelOffset or 2))
    return frame
end

--- A pooled texture on the given draw layer (and sublevel), clean of what it showed before.
function ItemWidgets.texture(container, layer, sublevel)
    return take(container, "texture:" .. layer .. ":" .. (sublevel or 0), function()
        local texture = container:CreateTexture(nil, layer, nil, sublevel)
        texture.poolReset = function(self)
            self:SetTexture(nil)
            self:SetVertexColor(1, 1, 1, 1)
            self:SetDesaturated(false)
            self:SetSize(0, 0)
        end
        return texture
    end)
end

--- A pooled font string styled by Skin.label, clean of the text, width and alignment it had before.
function ItemWidgets.label(container, size, weight, token, layer)
    local label = take(container, "label:" .. (layer or "OVERLAY"), function()
        local fontString = Skin.label(container, size, weight, token, layer)
        fontString.poolReset = function(self)
            self:SetText("")
            self:SetWidth(0)
            self:SetJustifyH("CENTER")
            self:SetWordWrap(true)
            self:SetShadowOffset(0, 0)
        end
        return fontString
    end)
    return Skin.text(label, size, weight, token)
end
