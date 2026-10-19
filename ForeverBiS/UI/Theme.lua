-- Design tokens of the "ember" look: colors, fonts and metrics. Every widget asks the theme, so the look changes in
-- one place. Nothing here touches the client except Theme.Font (CreateFont), which only runs when a widget is built.
local ADDON, ns = ...

local Theme = {}
ns.Theme = Theme

--- "#RRGGBB" (or "RRGGBB") -> { r, g, b, a } with each channel in 0..1, or nil when the text is not a color.
function Theme.Hex(value, alpha)
    local red, green, blue = tostring(value):match("^#?(%x%x)(%x%x)(%x%x)$")
    if not red then
        return nil
    end
    return { tonumber(red, 16) / 255, tonumber(green, 16) / 255, tonumber(blue, 16) / 255, alpha or 1 }
end

local hex = Theme.Hex

-- White washes are white with a low alpha, so they tint whatever sits below.
Theme.colors = {
    bg = hex("121010"),
    panel = hex("191614"),
    side = hex("0D0C0B"),
    control = hex("231F1C"),
    input = hex("0B0A09"),
    border = { 1, 1, 1, 0.08 },
    text = hex("F3EFEA"),
    dim = hex("F3EFEA", 0.68),
    muted = hex("F3EFEA", 0.5),
    accent = hex("3FA7FF"),
    onAccent = hex("0A0C10"),
    success = hex("5BD69A"),
    warning = hex("F5B84C"),
    danger = hex("F07272"),
    hover = { 1, 1, 1, 0.06 },
    selected = { 1, 1, 1, 0.07 },
    stripe = { 0, 0, 0, 0.14 },
    transparent = { 0, 0, 0, 0 },
}

--- r, g, b, a of a token, optionally with another alpha ("danger" at 0.14 is a chip ground). Unknown tokens
--- read as the text color.
function Theme.Color(name, alpha)
    local color = Theme.colors[name] or Theme.colors.text
    return color[1], color[2], color[3], alpha or color[4]
end

--- "|cffRRGGBB" for inline text color, from a token (the alpha is ignored).
function Theme.Code(name)
    local red, green, blue = Theme.Color(name)
    return ("|cff%02x%02x%02x"):format(
        math.floor(red * 255 + 0.5),
        math.floor(green * 255 + 0.5),
        math.floor(blue * 255 + 0.5)
    )
end

-- The token for a status word, so every widget colors "owned" or "missing" the same way.
local STATUS_TOKENS = {
    success = "success",
    owned = "success",
    equipped = "success",
    warning = "warning",
    partial = "warning",
    danger = "danger",
    missing = "danger",
    accent = "accent",
}

--- The color token for a status word; anything unknown reads as muted.
function Theme.StatusColor(word)
    return STATUS_TOKENS[word] or "muted"
end

-- Sizes in interface units.
Theme.metrics = {
    header = 52,
    logo = 30,
    closeButton = 32,
    padding = 20,
    button = 28,
    buttonPrimary = 30,
    input = 28,
    row = 28,
    bar = 6,
    scrollbar = 4,
}

local MEDIA = "Interface\\AddOns\\" .. ADDON .. "\\Media\\"

-- Fira Sans (SIL OFL 1.1, Media/Fonts/OFL.txt). When a file cannot be loaded the game font is used instead.
Theme.FONT_FILES = {
    regular = MEDIA .. "Fonts\\FiraSans-Regular.ttf",
    medium = MEDIA .. "Fonts\\FiraSans-Medium.ttf",
    semibold = MEDIA .. "Fonts\\FiraSans-SemiBold.ttf",
}

local ICONS = {
    alert = true,
    check = true,
    chevron = true,
    close = true,
    cross = true,
    dash = true,
    gear = true,
    list = true,
    search = true,
}

--- The texture path of a stroke icon (white, tinted at runtime), or nil for an unknown name.
function Theme.Icon(name)
    if not ICONS[name] then
        return nil
    end
    return MEDIA .. "Icons\\" .. name
end

local fonts = {}

--- A font object for the size and weight ("regular", "medium" or "semibold"), made on first use and kept. Falls
--- back to the game font when the file cannot be loaded, so a broken install still draws readable text.
function Theme.Font(size, weight)
    weight = Theme.FONT_FILES[weight] and weight or "regular"
    local key = weight .. size
    if fonts[key] then
        return fonts[key]
    end
    local font = CreateFont("ForeverBiSFont" .. key)
    local ok, loaded = pcall(font.SetFont, font, Theme.FONT_FILES[weight], size, "")
    if not (ok and loaded) then
        pcall(font.SetFont, font, STANDARD_TEXT_FONT, size, "")
    end
    fonts[key] = font
    return font
end
