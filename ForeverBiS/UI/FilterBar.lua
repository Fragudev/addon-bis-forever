-- The search box, source chips, faction and maker buttons and the dungeon dropdown. It only edits the shared
-- Filters state and asks for a redraw; the item list reads the state.
local _, ns = ...

local FilterBar = {}
ns.FilterBar = FilterBar

local Filters, Player, Sources, L = ns.Filters, ns.Player, ns.Sources, ns.L

local FILTER_LEFT = 22
local FILTER_ROW_SEARCH, FILTER_ROW_BUTTONS, FILTER_ROW_DUNGEON = -84, -110, -130

local sourceChips = {
    { "quest", "Quests", Sources.categoryIcons.quest },
    { "dungeon", "Dungeons and raids", Sources.categoryIcons.dungeon },
    { "world", "World", Sources.categoryIcons.world },
    { "profession", "Professions", Sources.categoryIcons.profession },
}

local searchBox, searchHint, clearSearchButton
local factionButton, makerButton, dungeonDrop
local sourceChipButtons, lastChip = {}, nil
local dungeonOptions = Filters.dungeonOptions()

--- Every filter change redraws from the top of the list.
local function changed()
    ns.requestRender({ scrollTop = true })
end

local function setFilterActive(button, active)
    button.filterActive = active
    if active then
        button:LockHighlight()
    else
        button:UnlockHighlight()
    end
    local label = button:GetFontString()
    if label then
        if active then
            label:SetTextColor(1, 0.89, 0.35)
        else
            label:SetTextColor(0.75, 0.75, 0.75)
        end
    end
end

local function attachFilterTooltip(button, heading, description)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(heading, 1, 0.89, 0.35)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function createFilterButton(parent, name, width)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 22)
    return button
end

local function createSearch(parent)
    searchBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    searchBox:SetSize(224, 20)
    searchBox:SetPoint("TOPLEFT", parent, "TOPLEFT", FILTER_LEFT, FILTER_ROW_SEARCH)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(48)
    searchBox:SetTextInsets(5, 22, 0, 0)
    searchHint = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchHint:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
    searchHint:SetText(L["Search item, boss or zone"])
    clearSearchButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    clearSearchButton:SetSize(16, 16)
    clearSearchButton:SetPoint("RIGHT", searchBox, "RIGHT", 0, 0)
    clearSearchButton:SetText("x")
    clearSearchButton:Hide()

    searchBox:SetScript("OnTextChanged", function(self)
        Filters.setSearch(self:GetText())
        changed()
    end)
    searchBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    clearSearchButton:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:ClearFocus()
    end)
end

local function createSourceChips(parent)
    for _, chip in ipairs(sourceChips) do
        local category, label, texture = chip[1], chip[2], chip[3]
        local button = createFilterButton(parent, "ForeverBiSFilter" .. category, 28)
        if lastChip then
            button:SetPoint("LEFT", lastChip, "RIGHT", 4, 0)
        else
            button:SetPoint("TOPLEFT", parent, "TOPLEFT", FILTER_LEFT, FILTER_ROW_BUTTONS)
        end
        local icon = button:CreateTexture(nil, "OVERLAY")
        icon:SetTexture(texture)
        icon:SetSize(14, 14)
        icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        attachFilterTooltip(
            button,
            L[label],
            L["Show only %s sources. Select several to combine them."]:format(string.lower(L[label]))
        )
        button:SetScript("OnClick", function()
            Filters.toggleSource(category)
            changed()
        end)
        sourceChipButtons[category] = button
        lastChip = button
    end
end

local function createFactionAndMaker(parent)
    factionButton = createFilterButton(parent, "ForeverBiSFilterFaction", 70)
    makerButton = createFilterButton(parent, "ForeverBiSFilterMaker", 92)
    attachFilterTooltip(
        makerButton,
        L["Maker-only items"],
        L["Some profession items can only be worn by the player who crafted them. Click to cycle: all items, only those maker-only items, or hide them. Items any player can use are treated as normal."]
    )
    attachFilterTooltip(
        factionButton,
        L["Faction"],
        L["Show items for your faction only. Click to show both factions."]
    )
    factionButton:SetScript("OnClick", function()
        Filters.toggleBothFactions()
        changed()
    end)
    makerButton:SetScript("OnClick", function()
        Filters.cycleMaker()
        changed()
    end)
end

local function updateDungeonText()
    for _, option in ipairs(dungeonOptions) do
        if option[1] == Filters.state.dungeon then
            UIDropDownMenu_SetText(dungeonDrop, option[2])
            break
        end
    end
end

local function createDungeonDropdown(parent)
    dungeonDrop = CreateFrame("Frame", "ForeverBiSDungeonFilter", parent, "UIDropDownMenuTemplate")
    dungeonDrop:SetPoint("TOPLEFT", parent, "TOPLEFT", FILTER_LEFT - 16, FILTER_ROW_DUNGEON)
    UIDropDownMenu_SetWidth(dungeonDrop, 150)
    UIDropDownMenu_Initialize(dungeonDrop, function(_, level)
        for _, option in ipairs(dungeonOptions) do
            local optionValue, optionLabel = option[1], option[2]
            local info = UIDropDownMenu_CreateInfo()
            info.text = optionLabel
            info.checked = Filters.state.dungeon == optionValue
            info.func = function()
                Filters.setDungeon(optionValue)
                changed()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

function FilterBar.create(parent)
    createSearch(parent)
    createSourceChips(parent)
    createFactionAndMaker(parent)
    createDungeonDropdown(parent)
end

local function refreshSearchWidgets()
    -- A reset empties the shared state; the text box follows (typing never leaves it empty while text remains).
    if Filters.state.search == "" and (searchBox:GetText() or "") ~= "" then
        searchBox:SetText("")
    end
    if (searchBox:GetText() or "") ~= "" then
        searchHint:Hide()
        clearSearchButton:Show()
    else
        searchHint:Show()
        clearSearchButton:Hide()
    end
end

--- Syncs every filter widget with the shared Filters state.
function FilterBar.refresh()
    local state = Filters.state
    for category, button in pairs(sourceChipButtons) do
        setFilterActive(button, state.sources[category] == true)
    end

    local faction = Player.faction()
    factionButton:ClearAllPoints()
    makerButton:ClearAllPoints()
    if faction then
        factionButton:Show()
        factionButton:SetPoint("LEFT", lastChip, "RIGHT", 10, 0)
        factionButton:SetText(state.bothFactions and L["Both"] or L[faction])
        setFilterActive(factionButton, not state.bothFactions)
        makerButton:SetPoint("LEFT", factionButton, "RIGHT", 4, 0)
    else
        factionButton:Hide()
        makerButton:SetPoint("LEFT", lastChip, "RIGHT", 10, 0)
    end
    makerButton:SetText(Filters.makerLabels[state.maker])
    setFilterActive(makerButton, state.maker ~= "all")

    if state.sources.dungeon == true then
        dungeonDrop:Show()
    else
        dungeonDrop:Hide()
    end
    updateDungeonText()
    refreshSearchWidgets()
end
