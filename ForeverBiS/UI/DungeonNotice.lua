-- A small clickable notice offering the BiS items of the dungeon the player just entered.
local _, ns = ...

local DungeonNotice = {}
ns.DungeonNotice = DungeonNotice

local Theme, Skin, L = ns.Theme, ns.Skin, ns.L

local notice, text
local onClick

function DungeonNotice.create()
    notice = CreateFrame("Button", "ForeverBiSDungeonNotice", UIParent)
    notice:SetSize(380, 48)
    notice:SetPoint("TOP", UIParent, "TOP", 0, -140)
    notice:SetFrameStrata("DIALOG")
    local border = Skin.card(notice)
    local bar = notice:CreateTexture(nil, "OVERLAY")
    bar:SetWidth(3)
    bar:SetPoint("TOPLEFT", notice, "TOPLEFT", 0, 0)
    bar:SetPoint("BOTTOMLEFT", notice, "BOTTOMLEFT", 0, 0)
    bar:SetColorTexture(Theme.Color("accent"))
    local icon = notice:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", notice, "LEFT", 16, 0)
    Skin.icon(icon, "list", "accent")
    local title = Skin.label(notice, 13, "semibold", "text")
    title:SetPoint("TOPLEFT", notice, "TOPLEFT", 44, -9)
    title:SetText(L["Forever BiS"])
    text = Skin.label(notice, 12, "regular", "dim")
    text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
    text:SetPoint("RIGHT", notice, "RIGHT", -12, 0)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(false)
    -- The border turns accent under the mouse, since the whole notice is a button.
    notice:HookScript("OnEnter", function()
        border:SetColor("accent")
    end)
    notice:HookScript("OnLeave", function()
        border:SetColor("border")
    end)
    notice:SetScript("OnClick", function()
        notice:Hide()
        if onClick then
            onClick()
        end
    end)
    notice:Hide()
end

--- Shows the message; clicking the notice hides it and runs the callback.
function DungeonNotice.show(message, callback)
    text:SetText(message)
    onClick = callback
    notice:Show()
end

function DungeonNotice.hide()
    notice:Hide()
end

function DungeonNotice.isShown()
    return notice:IsShown()
end
