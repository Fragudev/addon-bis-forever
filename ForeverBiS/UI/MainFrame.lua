-- The window: frame, header (logo, title, version, close button), resize handle and show/hide.
local ADDON, ns = ...

local MainFrame = {}
ns.MainFrame = MainFrame

local L, Theme, Pixel, Skin, Dropdown = ns.L, ns.Theme, ns.Pixel, ns.Skin, ns.Dropdown

local MIN_WIDTH, MIN_HEIGHT = 760, 520
local LOGO = "Interface\\AddOns\\" .. ADDON .. "\\ForeverBiSIcon.tga"
-- Once the player drags the resize handle the window keeps their size instead of fitting the screen.
local userSized = false
local frame, title

local function createFrame()
    frame = CreateFrame("Frame", "ForeverBiSFrame", UIParent)
    frame:SetWidth(MIN_WIDTH)
    frame:SetHeight(MIN_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, UIParent:GetWidth() - 40, UIParent:GetHeight() - 40)
    else
        frame:SetMinResize(MIN_WIDTH, MIN_HEIGHT)
    end
    Skin.fill(frame, "bg")
    Pixel.Border(frame, "border")
    frame:SetScript("OnHide", function()
        Dropdown.close()
    end)
    frame:Hide()
end

local function createResizeHandle()
    local handle = CreateFrame("Button", nil, frame)
    handle:SetSize(36, 14)
    handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 5)
    for index, barWidth in ipairs({ 22, 16, 10 }) do
        local gripBar = handle:CreateTexture(nil, "OVERLAY")
        gripBar:SetColorTexture(Theme.Color("muted"))
        gripBar:SetSize(barWidth, 1)
        gripBar:SetPoint("CENTER", handle, "CENTER", 0, 4 - index * 3)
    end
    handle:SetScript("OnMouseDown", function()
        userSized = true
        frame:StartSizing("BOTTOM")
    end)
    handle:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        ns.requestRender()
    end)
    handle:SetScript("OnHide", function()
        frame:StopMovingOrSizing()
    end)
end

--- The version from the .toc, or nil when the client cannot say.
local function addonVersion()
    local getter = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    if not getter then
        return nil
    end
    local ok, version = pcall(getter, ADDON, "Version")
    if ok and type(version) == "string" and version ~= "" then
        return version
    end
    return nil
end

--- The small bordered chip beside the title that shows the version.
local function createVersionBadge(header, version)
    local badge = CreateFrame("Frame", nil, header)
    Skin.fill(badge, "control")
    Pixel.Border(badge, "border")
    local text = Skin.label(badge, 11, "medium", "muted")
    text:SetPoint("CENTER", badge, "CENTER", 0, 0)
    text:SetText(version)
    badge:SetSize(text:GetStringWidth() + 14, 18)
    badge:SetPoint("LEFT", title, "RIGHT", 10, 0)
end

local function createCloseButton(header)
    local close = CreateFrame("Button", nil, header)
    close:SetSize(Theme.metrics.closeButton, Theme.metrics.closeButton)
    close:SetPoint("RIGHT", header, "RIGHT", -10, 0)
    Skin.button(close, "ghost", { hover = "danger" })
    Skin.buttonIcon(close, "close", 14)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)
end

--- The strip along the top: the drag area of the window.
local function createHeader()
    local header = CreateFrame("Frame", nil, frame)
    header:SetHeight(Theme.metrics.header)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    header:EnableMouse(true)
    Skin.fill(header, "side")
    local divider = header:CreateTexture(nil, "BORDER")
    divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    divider:SetHeight(Pixel.Size(header))
    divider:SetColorTexture(Theme.Color("border"))
    header:SetScript("OnMouseDown", function()
        frame:StartMoving()
    end)
    header:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)

    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(Theme.metrics.logo, Theme.metrics.logo)
    logo:SetPoint("LEFT", header, "LEFT", Theme.metrics.padding, 0)
    logo:SetTexture(LOGO)
    title = Skin.label(header, 15, "semibold", "text")
    title:SetPoint("LEFT", logo, "RIGHT", 10, 0)
    title:SetText(L["BiS Forever"])
    local version = addonVersion()
    if version then
        createVersionBadge(header, version)
    end
    createCloseButton(header)
end

--- Builds the window and returns its frame, the parent every panel attaches to.
function MainFrame.create()
    createFrame()
    createHeader()
    createResizeHandle()
    return frame
end

function MainFrame.isShown()
    return frame:IsShown()
end

--- Opening the window redraws it, since the game state may have changed while it was closed.
function MainFrame.toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        ns.requestRender()
    end
end

--- Shows the window if it is closed (and draws it); does nothing when it is already open.
function MainFrame.open()
    if not frame:IsShown() then
        frame:Show()
        ns.requestRender()
    end
end

--- Sets the title and fits the width to the screen unless the player resized it. Returns the width.
function MainFrame.refresh()
    title:SetText(L["BiS Forever"])
    local width = userSized and frame:GetWidth() or math.min(MIN_WIDTH, UIParent:GetWidth() - 50)
    if not userSized then
        frame:SetWidth(width)
    end
    return width
end

--- Fits the height to the screen unless the player resized it.
function MainFrame.settle()
    if not userSized then
        frame:SetHeight(math.min(MIN_HEIGHT, UIParent:GetHeight() - 50))
    end
end
