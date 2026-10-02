-- The BEST IN SLOT panel: character model, name and level, one icon per slot with its top BiS item, and the
-- Equipped Only toggle. Clicking an icon asks the item list to show that slot.
local _, ns = ...

local PaperDoll = {}
ns.PaperDoll = PaperDoll

local Catalog, Filters, Settings, Items, Inventory, ItemWidgets, Player, L =
    ns.Catalog, ns.Filters, ns.Settings, ns.Items, ns.Inventory, ns.ItemWidgets, ns.Player, ns.L

local gearPanel, gearContent, characterModel, equippedOnlyButton
local showEquippedOnly = false

local function refreshCharacterModel()
    if not characterModel:IsShown() then
        return
    end
    if characterModel.SetUnit then
        characterModel:SetUnit("player", false)
    end
    if characterModel.RefreshCamera then
        characterModel:RefreshCamera()
    end
end

local function createCharacterModel()
    characterModel = CreateFrame("PlayerModel", nil, gearContent)
    characterModel:SetSize(128, 190)
    characterModel:SetPoint("TOP", gearContent, "TOP", 0, -42)
    characterModel:SetScript("OnModelLoaded", function(self)
        if self.RefreshCamera then
            self:RefreshCamera()
        end
        if self.SetAnimation then
            self:SetAnimation(0)
        end
        if self.SetPaused then
            self:SetPaused(true)
        end
    end)
    characterModel:SetScript("OnShow", refreshCharacterModel)
    local events = CreateFrame("Frame")
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("UNIT_MODEL_CHANGED")
    events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    events:SetScript("OnEvent", function(_, event, unit)
        if event ~= "UNIT_MODEL_CHANGED" or unit == "player" then
            refreshCharacterModel()
        end
    end)
end

local function createEquippedOnlyButton()
    equippedOnlyButton = CreateFrame("Button", nil, gearPanel, "UIPanelButtonTemplate")
    equippedOnlyButton:SetSize(142, 20)
    equippedOnlyButton:SetPoint("TOP", gearPanel, "TOP", 0, -30)
    local function updateText()
        equippedOnlyButton:SetText(showEquippedOnly and L["Equipped Only: On"] or L["Equipped Only: Off"])
    end
    equippedOnlyButton:SetScript("OnClick", function()
        showEquippedOnly = not showEquippedOnly
        updateText()
        ns.requestRender()
    end)
    equippedOnlyButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["Equipped Only"], 1, 0.89, 0.35)
        GameTooltip:AddLine(L["Show only BiS items already equipped in their matching slots."], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    equippedOnlyButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    updateText()
end

--- Builds the panel inside the window frame and returns it, so the progress line can sit on it.
function PaperDoll.create(parent)
    gearPanel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    gearPanel:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -18, -84)
    gearPanel:SetSize(330, 390)
    gearPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 18,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    gearPanel:SetBackdropColor(0.18, 0.12, 0.07, 0.92)
    gearPanel:SetBackdropBorderColor(0.58, 0.39, 0.18, 1)
    local gearTitle = gearPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    gearTitle:SetPoint("TOP", gearPanel, "TOP", 0, -12)
    gearTitle:SetText("|cffffe35b" .. L["BEST IN SLOT"] .. "|r")
    createEquippedOnlyButton()
    gearContent = CreateFrame("Frame", nil, gearPanel)
    gearContent:SetPoint("TOPLEFT", gearPanel, "TOPLEFT", 5, -55)
    gearContent:SetPoint("BOTTOMRIGHT", gearPanel, "BOTTOMRIGHT", -5, 5)
    createCharacterModel()
    return gearPanel
end

local function clearContent()
    for _, child in ipairs({ gearContent:GetChildren() }) do
        if child ~= characterModel then
            child:Hide()
            child:SetParent(nil)
        end
    end
    for _, region in ipairs({ gearContent:GetRegions() }) do
        region:Hide()
        region:SetParent(nil)
    end
end

local function addPlayerLabels()
    local player = Player.identity()
    local nameLabel = gearContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOP", gearContent, "TOP", 0, -242)
    nameLabel:SetWidth(gearContent:GetWidth() - 24)
    nameLabel:SetJustifyH("CENTER")
    local fullName = player.name
    if player.realm and player.realm ~= "" then
        fullName = fullName .. " " .. player.realm
    end
    nameLabel:SetText(fullName)

    local classLabel = gearContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    classLabel:SetPoint("TOP", gearContent, "TOP", 0, -257)
    classLabel:SetText(player.className)
    local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[player.classToken]
    if classColor then
        classLabel:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        classLabel:SetTextColor(1, 1, 1)
    end

    local levelLabel = gearContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelLabel:SetPoint("TOP", gearContent, "TOP", 0, -272)
    levelLabel:SetText(L["Level %s"]:format(tostring(player.level)))
    levelLabel:SetTextColor(1, 0.89, 0.35)
end

--- Makes the item visible in the list (clearing filters that hide it, expanding its slot), then scrolls to it.
local function jumpToItem(view, slotKey, item)
    local redraw = false
    local faction = Player.faction()
    if not Filters.matches(item, faction) then
        Filters.reset()
        if not Filters.matches(item, faction) then
            Filters.state.bothFactions = true
        end
        redraw = true
    end
    local collapseKey = view.route .. ":" .. (view.headings[slotKey] or slotKey)
    if Settings.isCollapsed(collapseKey) then
        Settings.expand(collapseKey)
        redraw = true
    end
    ns.requestRender({ jumpTo = slotKey, redraw = redraw })
end

--- One slot icon. slot: listSlot (key in the view), markSlot (where ownership is checked), label (tooltip heading)
--- and ownerSlot (what the tooltip's ownership line checks).
local function addSlotButton(view, item, slot, x, y, anchor)
    local button = CreateFrame("Button", nil, gearContent)
    button:SetSize(32, 32)
    button:SetPoint("TOPLEFT", gearContent, "TOPLEFT", x, y)
    local texture = button:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints(button)
    texture:SetTexture(Items.icon(item[1]))
    ItemWidgets.addQualityBorder(button, item[1])
    ItemWidgets.addOwnershipMark(button, item[1], slot.markSlot)
    button:SetScript("OnEnter", function(self)
        ItemWidgets.showItemTooltip(self, anchor, item[1])
        GameTooltip:AddLine(L["Best in slot: %s"]:format(slot.label), 1, 0.89, 0.35)
        GameTooltip:AddLine(L["Source: %s"]:format(item[2]), 0.85, 0.85, 0.85, true)
        ItemWidgets.addOwnershipTooltip(item[1], slot.ownerSlot)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function()
        jumpToItem(view, slot.listSlot, item)
    end)
end

local function isShown(item, slotName)
    return not showEquippedOnly or Inventory.isEquippedInSlot(Items.id(item[1]), slotName)
end

--- Returns whether any icon was drawn.
local function addGearSlots(view)
    local drawn = false
    for _, slotInfo in ipairs(Catalog.paperDollSlots) do
        local displayName, listSlot, column, row, rank = unpack(slotInfo)
        local item = view.ranked[listSlot] and view.ranked[listSlot][rank or 1]
        if item and isShown(item, listSlot) then
            drawn = true
            local x = column == 1 and 5 or gearContent:GetWidth() - 37
            local slot = { listSlot = listSlot, markSlot = listSlot, label = displayName, ownerSlot = displayName }
            addSlotButton(view, item, slot, x, -((row - 1) * 37), "ANCHOR_LEFT")
        end
    end
    return drawn
end

local function addWeaponSlots(view)
    local drawn = false
    local center = math.floor(gearContent:GetWidth() / 2)
    local positions = { center - 57, center - 19, center + 19 }
    for index, slotName in ipairs(Catalog.weaponSlots) do
        local item = view.best[slotName]
        if item and isShown(item, slotName) then
            drawn = true
            local label = slotName == "Ranged" and (view.headings[slotName] or slotName) or slotName
            local slot = { listSlot = slotName, markSlot = slotName, label = label, ownerSlot = slotName }
            addSlotButton(view, item, slot, positions[index], -292, "ANCHOR_LEFT")
        end
    end
    return drawn
end

--- Redraws the player labels and the slot icons for the view (see Lists.view).
function PaperDoll.refresh(view)
    clearContent()
    addPlayerLabels()
    if not view.data then
        return
    end
    local gearDrawn = addGearSlots(view)
    local weaponsDrawn = addWeaponSlots(view)
    if showEquippedOnly and not (gearDrawn or weaponsDrawn) then
        local empty = gearContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        empty:SetPoint("CENTER", gearContent, "CENTER", 0, 0)
        empty:SetWidth(gearContent:GetWidth() - 36)
        empty:SetJustifyH("CENTER")
        empty:SetWordWrap(true)
        empty:SetText(L["No equipped BiS items found."])
    end
end
