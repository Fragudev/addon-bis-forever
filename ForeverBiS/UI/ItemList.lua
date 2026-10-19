-- The scrolling BiS list: slot headings with collapse buttons, item and enchant rows, the empty state and the
-- item counter. Filters and collapsed slots are read from shared state, never from other panels.
local _, ns = ...

local ItemList = {}
ns.ItemList = ItemList

local Filters, Settings, Player, ItemRows, Theme, Skin, L =
    ns.Filters, ns.Settings, ns.Player, ns.ItemRows, ns.Theme, ns.Skin, ns.L

local HEADING_X = 24
-- The list fills the left column: it ends where the gear panel (330 wide, 20 from the edge) begins, 14 apart.
local COLUMN_RIGHT = 364
-- Room kept at the right of the rows for the scrollbar, and the width the rows lose to the window margins.
local BAR_ROOM = 10
local SCROLL_STEP = 48
-- The list sits lower while the dungeon dropdown row is showing.
local SCROLL_TOP, SCROLL_TOP_WITH_DUNGEONS = -172, -208
local SCROLL_BOTTOM = 36

local frame, scroll, content, countText
local track, thumb
local slotTops = {}

--- How far the list can scroll: its height beyond the visible area.
local function scrollRange()
    return math.max(0, content:GetHeight() - scroll:GetHeight())
end

--- Sizes and places the scrollbar thumb for the current scroll; the bar hides when everything fits.
local function updateScrollbar()
    local range = scrollRange()
    if range <= 0 then
        track:Hide()
        return
    end
    track:Show()
    local visible = scroll:GetHeight()
    local thumbHeight = math.max(24, visible * visible / content:GetHeight())
    local travel = visible - thumbHeight
    local top = (scroll:GetVerticalScroll() or 0) / range * travel
    thumb:SetHeight(thumbHeight)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOPRIGHT", track, "TOPRIGHT", 0, -math.max(0, math.min(travel, top)))
end

local function scrollTo(position)
    scroll:SetVerticalScroll(math.max(0, math.min(position, scrollRange())))
end

--- A thin track and thumb at the right edge of the list; the thumb drags and the wheel scrolls.
local function createScrollbar()
    track = CreateFrame("Frame", nil, frame)
    track:SetWidth(Theme.metrics.scrollbar)
    track:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
    track:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 0, 0)
    Skin.fill(track, "border")
    thumb = CreateFrame("Button", nil, track)
    thumb:SetWidth(Theme.metrics.scrollbar)
    thumb:SetHeight(24)
    local thumbFill = Skin.fill(thumb, "muted")
    thumb:HookScript("OnEnter", function()
        thumbFill:SetColorTexture(Theme.Color("dim"))
    end)
    thumb:HookScript("OnLeave", function()
        thumbFill:SetColorTexture(Theme.Color("muted"))
    end)
    thumb:SetScript("OnMouseDown", function(self)
        local _, cursorY = GetCursorPosition()
        self.dragFrom, self.dragStart = cursorY / self:GetEffectiveScale(), scroll:GetVerticalScroll() or 0
        self:SetScript("OnUpdate", function()
            local _, nowY = GetCursorPosition()
            local travel = scroll:GetHeight() - self:GetHeight()
            if travel > 0 then
                local moved = self.dragFrom - nowY / self:GetEffectiveScale()
                scrollTo(self.dragStart + moved / travel * scrollRange())
            end
        end)
    end)
    thumb:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(_, delta)
        scrollTo((scroll:GetVerticalScroll() or 0) - delta * SCROLL_STEP)
    end)
    scroll:SetScript("OnVerticalScroll", updateScrollbar)
    scroll:SetScript("OnSizeChanged", updateScrollbar)
end

--- Builds the scroll area and the item counter inside the window frame.
function ItemList.create(parent)
    frame = parent
    scroll = CreateFrame("ScrollFrame", "ForeverBiSScroll", parent)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, SCROLL_TOP)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -COLUMN_RIGHT, SCROLL_BOTTOM)
    content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(500)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    createScrollbar()
    countText = Skin.label(parent, 12, "regular", "dim")
    countText:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -COLUMN_RIGHT, -105)
    countText:SetWidth(96)
    countText:SetJustifyH("RIGHT")
end

local function clearContent()
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in ipairs({ content:GetRegions() }) do
        region:Hide()
        region:SetParent(nil)
    end
end

local function layoutScroll()
    scroll:ClearAllPoints()
    scroll:SetPoint(
        "TOPLEFT",
        frame,
        "TOPLEFT",
        20,
        Filters.state.sources.dungeon == true and SCROLL_TOP_WITH_DUNGEONS or SCROLL_TOP
    )
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -COLUMN_RIGHT, SCROLL_BOTTOM)
end

local function addMessage(text, y)
    local message = Skin.label(content, 13, "regular", "dim")
    message:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    message:SetWidth(content:GetWidth())
    message:SetJustifyH("LEFT")
    message:SetText(text)
end

--- A ghost button with the chevron: right when collapsed, down when expanded.
local function addCollapseButton(header, collapseKey, collapsed)
    local collapseButton = CreateFrame("Button", nil, content)
    collapseButton:SetSize(18, 18)
    collapseButton:SetPoint("LEFT", header, "LEFT", -23, 0)
    Skin.button(collapseButton, "ghost")
    local chevron = Skin.buttonIcon(collapseButton, "chevron", 12)
    chevron:SetRotation(collapsed and 0 or -math.pi / 2)
    collapseButton:SetScript("OnClick", function()
        Settings.toggleCollapsed(collapseKey)
        ns.requestRender()
    end)
end

--- The slot heading with its collapse button and rule. Returns the y below it.
local function addSlotHeading(y, slotName, collapseKey, collapsed)
    local header = Skin.sectionLabel(Skin.label(content, 11, "semibold", "muted"), slotName)
    header:SetPoint("TOPLEFT", content, "TOPLEFT", HEADING_X, y - 6)
    addCollapseButton(header, collapseKey, collapsed)
    y = y - 28
    local rule = content:CreateTexture(nil, "ARTWORK")
    rule:SetColorTexture(Theme.Color("border"))
    rule:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    rule:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y)
    rule:SetHeight(1)
    return y - 6
end

--- The "nothing matches" card: icon, title, a hint and the button that clears the filters. Returns the y below it.
local function addEmptyState(y)
    local card = CreateFrame("Frame", nil, content)
    card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y - 6)
    card:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, y - 6)
    Skin.card(card)
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(28, 28)
    icon:SetPoint("TOP", card, "TOP", 0, -20)
    Skin.icon(icon, "search", "muted")
    local width = content:GetWidth() - 32
    local title = Skin.label(card, 13, "medium", "text")
    title:SetPoint("TOP", card, "TOP", 0, -58)
    title:SetWidth(width)
    title:SetText(L["No items match the current search and filters."])
    local hint = Skin.label(card, 12, "regular", "muted")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -6)
    hint:SetWidth(width)
    hint:SetText(L["Try a different search, or clear the filters."])
    local clearAll = CreateFrame("Button", nil, card)
    clearAll:SetSize(120, Theme.metrics.button)
    clearAll:SetPoint("TOP", hint, "BOTTOM", 0, -14)
    Skin.button(clearAll, "secondary")
    clearAll:SetText(L["Clear filters"])
    clearAll:SetScript("OnClick", function()
        Filters.reset()
        ns.requestRender()
    end)
    local height = 58 + title:GetStringHeight() + hint:GetStringHeight() + 6 + 14 + Theme.metrics.button + 18
    card:SetHeight(height)
    return y - 6 - height - 8
end

--- Draws one slot section when any of its items pass the filters. Returns the new y and how many items it drew.
local function addSlot(view, slot, y, faction)
    local slotKey = ns.Sources.normalizeSlotName(slot[1])
    local visibleItems = {}
    for rank, item in ipairs(slot[2]) do
        if Filters.matches(item, faction) then
            table.insert(visibleItems, { rank, item })
        end
    end
    if #visibleItems == 0 then
        return y, 0
    end

    y = y - 4
    local collapseKey = view.route .. ":" .. slot[1]
    local collapsed = Settings.isCollapsed(collapseKey)
    slotTops[slotKey] = y
    ItemRows.addEquipped(content, y, slotKey, slot[2])
    y = addSlotHeading(y, slot[1], collapseKey, collapsed)
    if collapsed then
        return y, #visibleItems
    end
    for index, rankedItem in ipairs(visibleItems) do
        y = ItemRows.addItem(content, y, rankedItem[1], rankedItem[2], slotKey, index % 2 == 0)
    end
    local enchants = slot[3]
    if enchants and #enchants > 0 then
        y = ItemRows.addEnchants(content, y, enchants)
    end
    return y, #visibleItems
end

local function updateCounter(shown, total)
    if shown == total then
        countText:SetText(L["%d items"]:format(total))
    else
        countText:SetText(Theme.Code("accent") .. shown .. "|r/" .. total)
    end
end

local function settleScroll(previousScroll)
    if scroll.UpdateScrollChildRect then
        scroll:UpdateScrollChildRect()
    end
    local maxScroll = math.max(0, content:GetHeight() - scroll:GetHeight())
    scroll:SetVerticalScroll(math.min(previousScroll, maxScroll))
    updateScrollbar()
end

--- Scrolls so the slot's heading is at the top, when the slot is drawn.
function ItemList.jumpTo(slotKey)
    local top = slotTops[slotKey]
    if top then
        scroll:SetVerticalScroll(math.max(0, -top - 4))
    end
end

--- Redraws the list for the view (see Lists.view). Options: scrollTop starts again from the top; jumpTo is a
--- slot key to scroll to once drawn.
function ItemList.refresh(view, options)
    options = options or {}
    if options.scrollTop then
        scroll:SetVerticalScroll(0)
    end
    local previousScroll = scroll:GetVerticalScroll() or 0
    slotTops = {}
    layoutScroll()
    clearContent()
    content:SetWidth(view.width - 20 - COLUMN_RIGHT - BAR_ROOM)

    local y = -5
    if not view.data then
        addMessage(L["This installed version does not include the selected BiS list yet."], y)
        countText:SetText("")
        content:SetHeight(45)
        scroll:SetVerticalScroll(0)
        updateScrollbar()
        return
    end

    local faction = Player.faction()
    local totalItems, shownItems = 0, 0
    for _, slot in ipairs(view.data.slots) do
        local drawn
        y, drawn = addSlot(view, slot, y, faction)
        totalItems = totalItems + #slot[2]
        shownItems = shownItems + drawn
    end
    if shownItems == 0 then
        y = addEmptyState(y)
    end
    updateCounter(shownItems, totalItems)

    content:SetHeight(-y + 8)
    settleScroll(previousScroll)
    if options.jumpTo then
        ItemList.jumpTo(options.jumpTo)
    end
end
