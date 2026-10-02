-- Rows of the item list: one BiS item and one enchant. Builders only; the list decides where they go.
local _, ns = ...

local ItemRows = {}
ns.ItemRows = ItemRows

local Items, Sources, ItemWidgets, L = ns.Items, ns.Sources, ns.ItemWidgets, ns.L

local SOURCE_X = 86

local function addSeparator(content, y)
    local separator = content:CreateTexture(nil, "ARTWORK")
    separator:SetTexture("Interface\\Buttons\\WHITE8X8")
    separator:SetVertexColor(0.35, 0.42, 0.53, 0.85)
    separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    separator:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
    separator:SetHeight(1)
end

local function addIconButton(content, rowTop, itemName, slotKey, itemSource)
    local iconButton = CreateFrame("Button", nil, content)
    iconButton:SetSize(38, 38)
    iconButton:SetPoint("TOPLEFT", content, "TOPLEFT", 32, rowTop - 2)
    local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
    iconTexture:SetAllPoints(iconButton)
    iconTexture:SetTexture(Items.icon(itemName))
    ItemWidgets.addQualityBorder(iconButton, itemName)
    ItemWidgets.addOwnershipMark(iconButton, itemName, slotKey, true)
    iconButton:SetScript("OnEnter", function(self)
        ItemWidgets.showItemTooltip(self, "ANCHOR_RIGHT", itemName)
        GameTooltip:AddLine(L["Source: %s"]:format(itemSource), 0.85, 0.85, 0.85, true)
        ItemWidgets.addOwnershipTooltip(itemName, slotKey)
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function addFactionBadge(content, rowTop, faction, nameWidth)
    local factionIcon = content:CreateTexture(nil, "ARTWORK")
    factionIcon:SetSize(14, 14)
    factionIcon:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X + nameWidth + 3, rowTop - 5)
    factionIcon:SetTexture(
        faction == "Horde" and "Interface\\TargetingFrame\\UI-PVP-Horde" or "Interface\\TargetingFrame\\UI-PVP-Alliance"
    )
    local factionLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    factionLabel:SetPoint("LEFT", factionIcon, "RIGHT", 2, 0)
    factionLabel:SetText(L[faction])
    factionLabel:SetFont(STANDARD_TEXT_FONT, 11, "THICKOUTLINE")
    if faction == "Horde" then
        factionLabel:SetTextColor(1, 0.2, 0.2)
    else
        factionLabel:SetTextColor(0.3, 0.65, 1)
    end
end

--- Draws one ranked BiS item whose top edge is at rowTop. Returns the y just below its separator.
function ItemRows.addItem(content, rowTop, rank, item, slotKey)
    local itemName, itemSource = item[1], item[2]
    local sourceWidth = content:GetWidth() - SOURCE_X - 8
    local rankText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rankText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, rowTop - 9)
    rankText:SetWidth(28)
    rankText:SetJustifyH("RIGHT")
    rankText:SetText(tostring(rank))
    addIconButton(content, rowTop, itemName, slotKey, itemSource)

    local name = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, rowTop - 4)
    local faction = Sources.exclusiveFaction(itemSource)
    local nameWidth = faction and math.max(80, sourceWidth - 66) or sourceWidth
    name:SetWidth(nameWidth)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(true)
    name:SetText(itemName)
    name:SetTextColor(Items.qualityColor(itemName))
    if faction then
        addFactionBadge(content, rowTop, faction, nameWidth)
    end

    local source = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    local sourceTop = rowTop - name:GetStringHeight() - 8
    local sourceIcon = content:CreateTexture(nil, "ARTWORK")
    sourceIcon:SetSize(16, 16)
    sourceIcon:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, sourceTop + 1)
    sourceIcon:SetTexture(Sources.icon(itemSource))
    source:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X + 20, sourceTop)
    source:SetWidth(sourceWidth - 20)
    source:SetJustifyH("LEFT")
    source:SetWordWrap(true)
    source:SetText(Sources.format(itemSource))

    local bottom = rowTop - math.max(48, name:GetStringHeight() + source:GetStringHeight() + 12)
    addSeparator(content, bottom)
    return bottom - 3
end

local function addEnchantIcon(content, rowTop, spellName, enchantSource, formulaID)
    local iconButton = CreateFrame("Button", nil, content)
    iconButton:SetSize(28, 28)
    iconButton:SetPoint("TOPLEFT", content, "TOPLEFT", 36, rowTop - 2)
    local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
    iconTexture:SetAllPoints(iconButton)
    iconTexture:SetTexture("Interface\\Icons\\Trade_Engraving")
    iconButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if formulaID then
            GameTooltip:SetHyperlink("item:" .. formulaID)
        else
            GameTooltip:SetText(spellName, 1, 1, 1)
        end
        GameTooltip:AddLine(L["Source: %s"]:format(enchantSource), 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

--- Draws the ENCHANTS block of a slot starting at y. Returns the y below it.
function ItemRows.addEnchants(content, y, enchants)
    local sourceWidth = content:GetWidth() - SOURCE_X - 8
    local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 32, y - 4)
    header:SetText("|cff8fb3ff" .. L["ENCHANTS"] .. "|r")
    y = y - 22
    for _, enchant in ipairs(enchants) do
        local effect, spellName, enchantSource, formulaID = enchant[1], enchant[2], enchant[3], enchant[4]
        local rowTop = y
        addEnchantIcon(content, rowTop, spellName, enchantSource, formulaID)

        local effectText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        effectText:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, rowTop - 2)
        effectText:SetWidth(sourceWidth)
        effectText:SetJustifyH("LEFT")
        effectText:SetWordWrap(true)
        effectText:SetText(effect)
        effectText:SetTextColor(0.12, 1, 0)

        local detailText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        detailText:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, rowTop - effectText:GetStringHeight() - 6)
        detailText:SetWidth(sourceWidth)
        detailText:SetJustifyH("LEFT")
        detailText:SetWordWrap(true)
        detailText:SetText(spellName .. " - " .. enchantSource)

        y = rowTop - math.max(36, effectText:GetStringHeight() + detailText:GetStringHeight() + 10)
    end
    return y - 3
end
