-- Rows of the item list: one BiS item and one enchant. Builders only; the list decides where they go.
local _, ns = ...

local ItemRows = {}
ns.ItemRows = ItemRows

local Items, Inventory, Lists, Sources, ItemWidgets, Chat, Theme, Pixel, Skin, L =
    ns.Items, ns.Inventory, ns.Lists, ns.Sources, ns.ItemWidgets, ns.Chat, ns.Theme, ns.Pixel, ns.Skin, ns.L

local SOURCE_X = 86

local function addSeparator(content, y)
    local separator = content:CreateTexture(nil, "ARTWORK")
    separator:SetColorTexture(Theme.Color("border"))
    separator:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    separator:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
    separator:SetHeight(Pixel.Size(content))
end

--- The darker band behind every other row, from rowTop down to the bottom edge.
local function addStripe(content, rowTop, bottom)
    local stripe = content:CreateTexture(nil, "BACKGROUND")
    stripe:SetColorTexture(Theme.Color("stripe"))
    stripe:SetPoint("TOPLEFT", content, "TOPLEFT", 0, rowTop)
    stripe:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, rowTop)
    stripe:SetHeight(rowTop - bottom)
end

--- A transparent frame over the row that washes it on hover. It is made before the row's buttons, so they stay on
--- top; returns it with setHover(on), which those buttons call too, since entering a child leaves the row.
local function createHoverRow(content, rowTop)
    local row = CreateFrame("Frame", nil, content)
    row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, rowTop)
    row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, rowTop)
    row:EnableMouse(true)
    local wash = row:CreateTexture(nil, "BACKGROUND")
    wash:SetAllPoints(row)
    wash:SetColorTexture(Theme.Color("transparent"))
    function row.setHover(on)
        wash:SetColorTexture(Theme.Color(on and "hover" or "transparent"))
    end
    row:SetScript("OnEnter", function()
        row.setHover(true)
    end)
    row:SetScript("OnLeave", function()
        row.setHover(false)
    end)
    return row
end

local function addIconButton(content, rowTop, itemName, slotKey, itemSource, hoverRow)
    local iconButton = CreateFrame("Button", nil, content)
    iconButton:SetSize(38, 38)
    iconButton:SetPoint("TOPLEFT", content, "TOPLEFT", 32, rowTop - 2)
    local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
    iconTexture:SetAllPoints(iconButton)
    iconTexture:SetTexture(Items.icon(itemName))
    ItemWidgets.addQualityBorder(iconButton, itemName)
    ItemWidgets.addOwnershipMark(iconButton, itemName, slotKey)
    iconButton:HookScript("OnEnter", function()
        hoverRow.setHover(true)
    end)
    iconButton:HookScript("OnLeave", function()
        hoverRow.setHover(false)
    end)
    iconButton:SetScript("OnEnter", function(self)
        ItemWidgets.showItemTooltip(self, "ANCHOR_RIGHT", itemName)
        GameTooltip:AddLine(L["Source: %s"]:format(itemSource), 0.85, 0.85, 0.85, true)
        ItemWidgets.addOwnershipTooltip(itemName, slotKey)
        GameTooltip:Show()
    end)
    iconButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    -- Shift-click puts the item link in the chat edit box, like any item in the game.
    iconButton:SetScript("OnClick", function()
        if Chat.linkModifierHeld() then
            Chat.insertLink(Items.link(itemName))
        end
    end)
end

--- A small chip with the faction emblem and name, in the faction's color on a faint ground of the same color.
local function addFactionBadge(content, rowTop, faction, nameWidth)
    local token = faction == "Horde" and "danger" or "accent"
    local chip = content:CreateTexture(nil, "BACKGROUND")
    chip:SetColorTexture(Theme.Color(token, 0.14))
    chip:SetHeight(18)
    chip:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X + nameWidth + 3, rowTop - 5)
    local factionIcon = content:CreateTexture(nil, "ARTWORK")
    factionIcon:SetSize(14, 14)
    factionIcon:SetPoint("LEFT", chip, "LEFT", 3, 0)
    factionIcon:SetTexture(
        faction == "Horde" and "Interface\\TargetingFrame\\UI-PVP-Horde" or "Interface\\TargetingFrame\\UI-PVP-Alliance"
    )
    local factionLabel = Skin.label(content, 11, "semibold", token)
    factionLabel:SetPoint("LEFT", factionIcon, "RIGHT", 3, 0)
    factionLabel:SetText(L[faction])
    chip:SetWidth(3 + 14 + 3 + factionLabel:GetStringWidth() + 6)
end

--- Draws one ranked BiS item whose top edge is at rowTop; striped rows get the darker band. Returns the y just
--- below its separator.
function ItemRows.addItem(content, rowTop, rank, item, slotKey, striped)
    local itemName, itemSource = item[1], item[2]
    local sourceWidth = content:GetWidth() - SOURCE_X - 8
    local hoverRow = createHoverRow(content, rowTop)
    local rankText = Skin.label(content, 13, "medium", "dim")
    rankText:SetPoint("TOPLEFT", content, "TOPLEFT", 0, rowTop - 11)
    rankText:SetWidth(28)
    rankText:SetJustifyH("RIGHT")
    rankText:SetText(tostring(rank))
    addIconButton(content, rowTop, itemName, slotKey, itemSource, hoverRow)

    local name = Skin.label(content, 13, "medium", "text")
    name:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, rowTop - 5)
    local faction = Sources.exclusiveFaction(itemSource)
    local nameWidth = faction and math.max(80, sourceWidth - 80) or sourceWidth
    name:SetWidth(nameWidth)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(true)
    name:SetText(itemName)
    name:SetTextColor(Items.qualityColor(itemName))
    if faction then
        addFactionBadge(content, rowTop, faction, nameWidth)
    end

    local source = Skin.label(content, 12, "regular", "dim")
    local sourceTop = rowTop - name:GetStringHeight() - 9
    local sourceIcon = content:CreateTexture(nil, "ARTWORK")
    sourceIcon:SetSize(16, 16)
    sourceIcon:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, sourceTop + 1)
    sourceIcon:SetTexture(Sources.icon(itemSource))
    source:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X + 20, sourceTop)
    source:SetWidth(sourceWidth - 20)
    source:SetJustifyH("LEFT")
    source:SetWordWrap(true)
    source:SetText(Sources.format(itemSource))

    local bottom = rowTop - math.max(48, name:GetStringHeight() + source:GetStringHeight() + 14)
    hoverRow:SetPoint("BOTTOMLEFT", content, "TOPLEFT", 0, bottom)
    if striped then
        addStripe(content, rowTop, bottom)
    end
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
    Pixel.Border(iconButton, "border", "OVERLAY")
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
    local header = Skin.sectionLabel(Skin.label(content, 11, "semibold", "muted"), L["ENCHANTS"])
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 32, y - 4)
    y = y - 24
    for _, enchant in ipairs(enchants) do
        local effect, spellName, enchantSource, formulaID = enchant[1], enchant[2], enchant[3], enchant[4]
        local rowTop = y
        addEnchantIcon(content, rowTop, spellName, enchantSource, formulaID)

        local effectText = Skin.label(content, 13, "medium", "success")
        effectText:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, rowTop - 2)
        effectText:SetWidth(sourceWidth)
        effectText:SetJustifyH("LEFT")
        effectText:SetWordWrap(true)
        effectText:SetText(effect)

        local detailText = Skin.label(content, 12, "regular", "dim")
        detailText:SetPoint("TOPLEFT", content, "TOPLEFT", SOURCE_X, rowTop - effectText:GetStringHeight() - 6)
        detailText:SetWidth(sourceWidth)
        detailText:SetJustifyH("LEFT")
        detailText:SetWordWrap(true)
        detailText:SetText(spellName .. " - " .. enchantSource)

        y = rowTop - math.max(36, effectText:GetStringHeight() + detailText:GetStringHeight() + 10)
    end
    return y - 3
end

local EQUIPPED_ICON_SIZE = 12
local EQUIPPED_LINE_HEIGHT = 14

--- One right-aligned "[icon] Name  #3" (or "Not listed") line for something worn in the slot.
local function addEquippedLine(content, lineY, itemID, rank)
    local rankText = Skin.label(content, 12, "medium", rank and "warning" or "muted")
    rankText:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, lineY)
    rankText:SetJustifyH("RIGHT")
    rankText:SetText(rank and L["#%d"]:format(rank) or L["Not listed"])
    local name = Skin.label(content, 12, "regular", "text")
    name:SetPoint("RIGHT", rankText, "LEFT", -5, 0)
    name:SetWidth(150)
    name:SetJustifyH("RIGHT")
    name:SetText(Items.nameById(itemID) or L["Item %d"]:format(itemID))
    name:SetTextColor(Items.qualityColorById(itemID))
    local icon = content:CreateTexture(nil, "ARTWORK")
    icon:SetSize(EQUIPPED_ICON_SIZE, EQUIPPED_ICON_SIZE)
    icon:SetPoint("RIGHT", name, "LEFT", -3, 0)
    icon:SetTexture(Items.iconById(itemID))
end

--- Shows what the player wears in a slot beside its heading, with its rank in the slot's list. A ring or trinket
--- slot shows both items. slotItems are the slot's { name, source } entries.
function ItemRows.addEquipped(content, y, slotKey, slotItems)
    for index, itemID in ipairs(Inventory.equippedIds(slotKey)) do
        Items.track(itemID)
        local rank = Lists.rankOf(slotItems, itemID, Items.id)
        addEquippedLine(content, y - 2 - (index - 1) * EQUIPPED_LINE_HEIGHT, itemID, rank)
    end
end
