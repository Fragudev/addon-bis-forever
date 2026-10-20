-- The search box, source chips, faction and maker buttons and the dungeon dropdown. It only edits the shared
-- Filters state and asks for a redraw; the item list reads the state.
local _, ns = ...

local FilterBar = {}
ns.FilterBar = FilterBar

local Filters, Player, Sources, Dropdown, Theme, Skin, L =
    ns.Filters, ns.Player, ns.Sources, ns.Dropdown, ns.Theme, ns.Skin, ns.L

local FILTER_LEFT = 20
local FILTER_ROW_SEARCH, FILTER_ROW_BUTTONS, FILTER_ROW_DUNGEON = -98, -134, -170

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

--- An active filter shows the selected wash with accent text and underline.
local function setFilterActive(button, active)
    button.filterActive = active
    Skin.setActive(button, active)
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
    local button = CreateFrame("Button", name, parent)
    button:SetSize(width, Theme.metrics.button)
    Skin.button(button, "secondary")
    return button
end

local function createSearch(parent)
    searchBox = CreateFrame("EditBox", nil, parent)
    searchBox:SetSize(224, Theme.metrics.input)
    searchBox:SetPoint("TOPLEFT", parent, "TOPLEFT", FILTER_LEFT, FILTER_ROW_SEARCH)
    searchBox:SetAutoFocus(false)
    searchBox:SetMaxLetters(48)
    Skin.editBox(searchBox, { icon = "search", right = 28 })
    searchHint = Skin.label(searchBox, 13, "regular", "muted")
    searchHint:SetPoint("LEFT", searchBox, "LEFT", 28, 0)
    searchHint:SetText(L["Search item, boss or zone"])
    clearSearchButton = CreateFrame("Button", nil, searchBox)
    clearSearchButton:SetSize(20, 20)
    clearSearchButton:SetPoint("RIGHT", searchBox, "RIGHT", -4, 0)
    Skin.button(clearSearchButton, "ghost")
    Skin.buttonIcon(clearSearchButton, "close", 10)
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
            Dropdown.setText(dungeonDrop, option[2])
            break
        end
    end
end

local function dungeonItems()
    local items = {}
    for _, option in ipairs(dungeonOptions) do
        local optionValue = option[1]
        items[#items + 1] = {
            text = option[2],
            checked = Filters.state.dungeon == optionValue,
            func = function()
                Filters.setDungeon(optionValue)
                changed()
            end,
        }
    end
    return items
end

local function createDungeonDropdown(parent)
    dungeonDrop = Dropdown.create(parent, "ForeverBiSDungeonFilter", { width = 190, items = dungeonItems })
    dungeonDrop:SetPoint("TOPLEFT", parent, "TOPLEFT", FILTER_LEFT, FILTER_ROW_DUNGEON)
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
