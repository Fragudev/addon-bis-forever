-- The window: frame, title, close button, resize handle and show/hide.
local _, ns = ...

local MainFrame = {}
ns.MainFrame = MainFrame

local L = ns.L

local MIN_WIDTH, MIN_HEIGHT = 760, 500
-- Once the player drags the resize handle the window keeps their size instead of fitting the screen.
local userSized = false
local frame, title

local function createFrame()
    frame = CreateFrame("Frame", "ForeverBiSFrame", UIParent, "BackdropTemplate")
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
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:SetScript("OnMouseDown", function()
        frame:StartMoving()
    end)
    frame:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)
    frame:Hide()
end

local function createResizeHandle()
    local handle = CreateFrame("Button", nil, frame)
    handle:SetSize(36, 14)
    handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 5)
    for index, barWidth in ipairs({ 22, 16, 10 }) do
        local gripBar = handle:CreateTexture(nil, "OVERLAY")
        gripBar:SetTexture("Interface\\Buttons\\WHITE8X8")
        gripBar:SetVertexColor(0.72, 0.58, 0.32, 0.9)
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

--- Builds the window and returns its frame, the parent every panel attaches to.
function MainFrame.create()
    createFrame()
    title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -18)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
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
