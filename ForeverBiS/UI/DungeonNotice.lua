-- A small clickable notice offering the BiS items of the dungeon the player just entered.
local _, ns = ...

local DungeonNotice = {}
ns.DungeonNotice = DungeonNotice

local notice, text
local onClick

function DungeonNotice.create()
    notice = CreateFrame("Button", "ForeverBiSDungeonNotice", UIParent, "BackdropTemplate")
    notice:SetSize(340, 30)
    notice:SetPoint("TOP", UIParent, "TOP", 0, -140)
    notice:SetFrameStrata("DIALOG")
    notice:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    notice:SetBackdropColor(0.18, 0.12, 0.07, 0.92)
    notice:SetBackdropBorderColor(0.58, 0.39, 0.18, 1)
    text = notice:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", notice, "CENTER", 0, 0)
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
