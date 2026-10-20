-- Small helpers that apply the theme to raw frames: fills, cards, text styles, icons, buttons and edit boxes.
-- The panels still build their own frames; Skin only paints them, so the look stays in one place.
local _, ns = ...

local Skin = {}
ns.Skin = Skin

local Theme, Pixel = ns.Theme, ns.Pixel

--- Paints the frame's background with a theme token (one texture, reused when called again). Returns it.
function Skin.fill(frame, token)
    local fill = frame.skinFill
    if not fill then
        fill = frame:CreateTexture(nil, "BACKGROUND")
        fill:SetAllPoints(frame)
        frame.skinFill = fill
    end
    fill:SetColorTexture(Theme.Color(token))
    return fill
end

--- A card: panel fill and a 1px border. Returns the border so callers can tint it.
function Skin.card(frame, token)
    Skin.fill(frame, token or "panel")
    frame.skinBorder = Pixel.Border(frame, "border")
    return frame.skinBorder
end

--- Sets a font string to a size ("regular", "medium" or "semibold") and token color. Call it before SetText:
--- a font string without a font cannot hold text.
function Skin.text(fontString, size, weight, token)
    fontString:SetFontObject(Theme.Font(size, weight))
    fontString:SetTextColor(Theme.Color(token or "text"))
    return fontString
end

--- A new font string already styled by Skin.text.
function Skin.label(parent, size, weight, token, layer)
    return Skin.text(parent:CreateFontString(nil, layer or "OVERLAY"), size, weight, token)
end

--- A small section label: 11 semibold uppercase in the muted color. The text is optional.
function Skin.sectionLabel(fontString, text)
    Skin.text(fontString, 11, "semibold", "muted")
    if text then
        fontString:SetText(string.upper(text))
    end
    return fontString
end

--- Draws the stroke icon `name` on a texture in a token color. An unknown name hides the texture.
function Skin.icon(texture, name, token)
    local path = Theme.Icon(name)
    if not path then
        texture:Hide()
        return false
    end
    texture:SetTexture(path)
    texture:SetVertexColor(Theme.Color(token or "text"))
    texture:Show()
    return true
end

--- What a button looks like in a state, as plain data: fill token (nil = none), wash { token, alpha }, text token,
--- whether the border and the accent underline show. state: hover, active, disabled; hoverToken tints the hover.
function Skin.buttonStyle(kind, state)
    local style = { fill = "control", border = true, text = "text", underline = false }
    if kind == "primary" then
        style.fill, style.border, style.text = "accent", false, "onAccent"
    elseif kind == "ghost" then
        style.fill, style.border, style.text = nil, false, "dim"
    end
    if state.disabled then
        style.text = "muted"
        if kind == "primary" then
            style.fill = "control"
        end
        return style
    end
    if state.active then
        style.wash = { "selected" }
        style.underline = true
        if kind ~= "primary" then
            style.text = "accent"
        end
    end
    if state.hover then
        local token = state.hoverToken
        style.wash = token and { token, 0.14 } or { "hover" }
        if kind ~= "primary" and not state.active then
            style.text = token or "text"
        end
    end
    return style
end

local function applyButton(button)
    local state = button.skin
    local style = Skin.buttonStyle(state.kind, state)
    if style.fill then
        state.fill:SetColorTexture(Theme.Color(style.fill))
    else
        state.fill:SetColorTexture(Theme.Color("transparent"))
    end
    state.border:SetShown(style.border)
    if style.wash then
        state.wash:SetColorTexture(Theme.Color(style.wash[1], style.wash[2]))
    else
        state.wash:SetColorTexture(Theme.Color("transparent"))
    end
    if style.underline then
        state.underline:Show()
    else
        state.underline:Hide()
    end
    state.label:SetTextColor(Theme.Color(style.text))
    if state.icon then
        state.icon:SetVertexColor(Theme.Color(style.text))
    end
end

--- Paints a plain Button as "secondary" (control fill and border), "primary" (accent fill) or "ghost" (no fill).
--- Options: hover is a token that tints the hover (the close button uses "danger"). Text is set with SetText.
function Skin.button(button, kind, options)
    local state = { kind = kind, hoverToken = options and options.hover }
    button.skin = state
    state.fill = button:CreateTexture(nil, "BACKGROUND")
    state.fill:SetAllPoints(button)
    state.wash = button:CreateTexture(nil, "BORDER")
    state.wash:SetAllPoints(button)
    state.border = Pixel.Border(button, "border")
    state.underline = button:CreateTexture(nil, "OVERLAY")
    state.underline:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
    state.underline:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    state.underline:SetHeight(2)
    state.underline:SetColorTexture(Theme.Color("accent"))
    state.label = button:GetFontString()
    if not state.label then
        state.label = button:CreateFontString(nil, "OVERLAY")
        button:SetFontString(state.label)
    end
    Skin.text(state.label, 12, "regular", "text")
    state.label:SetPoint("CENTER", button, "CENTER", 0, 0)
    button:HookScript("OnEnter", function()
        state.hover = true
        applyButton(button)
    end)
    button:HookScript("OnLeave", function()
        state.hover = false
        applyButton(button)
    end)
    applyButton(button)
    return button
end

--- Puts a centered stroke icon on a skinned button; it follows the button's text color.
function Skin.buttonIcon(button, name, size)
    local state = button.skin
    state.icon = button:CreateTexture(nil, "ARTWORK")
    state.icon:SetSize(size or 14, size or 14)
    state.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    Skin.icon(state.icon, name, "text")
    applyButton(button)
    return state.icon
end

--- Marks a skinned button as on or off (a toggle or an active filter).
function Skin.setActive(button, active)
    button.skin.active = active == true
    applyButton(button)
end

--- Enables or disables a skinned button, and repaints it.
function Skin.setEnabled(button, enabled)
    if enabled then
        button:Enable()
    else
        button:Disable()
    end
    button.skin.disabled = not enabled
    applyButton(button)
end

--- Paints a plain EditBox: input fill, a border that turns accent while it has focus, 13 text and an optional
--- left search icon (options.icon). Returns the border.
function Skin.editBox(box, options)
    Skin.fill(box, "input")
    local border = Pixel.Border(box, "border")
    box.skinBorder = border
    box:SetFontObject(Theme.Font(13, "regular"))
    box:SetTextColor(Theme.Color("text"))
    local left = 8
    if options and options.icon then
        local icon = box:CreateTexture(nil, "ARTWORK")
        icon:SetSize(14, 14)
        icon:SetPoint("LEFT", box, "LEFT", 8, 0)
        Skin.icon(icon, options.icon, "muted")
        left = 28
    end
    box:SetTextInsets(left, options and options.right or 8, 0, 0)
    box:HookScript("OnEditFocusGained", function()
        border:SetColor("accent")
    end)
    box:HookScript("OnEditFocusLost", function()
        border:SetColor("border")
    end)
    return border
end
