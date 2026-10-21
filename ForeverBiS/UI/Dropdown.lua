-- The themed dropdown: a button that shows the current choice and opens one shared dark list under it. It replaces
-- the client's dropdown template. The list closes on Escape, on a click outside and when the window hides.
local _, ns = ...

local Dropdown = {}
ns.Dropdown = Dropdown

local Theme, Skin = ns.Theme, ns.Skin

local ROW_HEIGHT, MAX_ROWS, PADDING = 28, 12, 4
-- Room the button keeps around its text: 10 px on the left, the chevron and its margins on the right.
local TEXT_CHROME = 38
local POPOVER_NAME = "ForeverBiSDropdownList"

-- The one list every dropdown shares, built on first use; only one can be open at a time.
local popover, catcher
local rows = {}
local open, items, offset = nil, {}, 0

--- Which entries a list of `count` shows when it holds at most `maxRows` rows and starts at `skip` (0-based).
--- Returns the first and last entry numbers and the offset clamped to what can be scrolled.
function Dropdown.window(count, skip, maxRows)
    local visible = math.min(count, maxRows)
    local clamped = math.max(0, math.min(skip, count - visible))
    return clamped + 1, clamped + visible, clamped
end

local function setChevron(button, isOpen)
    button.skin.icon:SetRotation(isOpen and math.pi / 2 or -math.pi / 2)
end

--- Closes the list if one is open.
function Dropdown.close()
    if popover then
        popover:Hide()
    end
end

function Dropdown.isOpen()
    return open ~= nil
end

local function selectRow(row)
    local entry = items[row.entry]
    Dropdown.close()
    if entry and entry.func then
        entry.func()
    end
end

local function createRow(index)
    local row = CreateFrame("Button", nil, popover)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", popover, "TOPLEFT", PADDING, -PADDING - (index - 1) * ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", popover, "TOPRIGHT", -PADDING, -PADDING - (index - 1) * ROW_HEIGHT)
    row.wash = row:CreateTexture(nil, "BACKGROUND")
    row.wash:SetAllPoints(row)
    row.wash:SetColorTexture(Theme.Color("transparent"))
    row.check = row:CreateTexture(nil, "ARTWORK")
    row.check:SetSize(12, 12)
    row.check:SetPoint("LEFT", row, "LEFT", 8, 0)
    Skin.icon(row.check, "check", "accent")
    row.label = Skin.label(row, 13, "regular", "text")
    row.label:SetPoint("LEFT", row, "LEFT", 28, 0)
    row.label:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.label:SetJustifyH("LEFT")
    row.label:SetWordWrap(false)
    row:SetScript("OnEnter", function()
        row.wash:SetColorTexture(Theme.Color("hover"))
    end)
    row:SetScript("OnLeave", function()
        row.wash:SetColorTexture(Theme.Color("transparent"))
    end)
    row:SetScript("OnClick", selectRow)
    return row
end

--- Fills the visible rows from the scroll offset.
local function renderRows()
    local first, last
    first, last, offset = Dropdown.window(#items, offset, MAX_ROWS)
    for slot = 1, MAX_ROWS do
        rows[slot] = rows[slot] or createRow(slot)
        local entry = first + slot - 1
        if entry <= last then
            rows[slot].entry = entry
            rows[slot].label:SetText(items[entry].text)
            if items[entry].checked then
                rows[slot].check:Show()
            else
                rows[slot].check:Hide()
            end
            rows[slot]:Show()
        else
            rows[slot]:Hide()
        end
    end
end

local function createPopover()
    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN_DIALOG")
    catcher:SetFrameLevel(1)
    catcher:RegisterForClicks("AnyUp")
    catcher:SetScript("OnClick", Dropdown.close)
    catcher:Hide()

    popover = CreateFrame("Frame", POPOVER_NAME, UIParent)
    popover:SetFrameStrata("FULLSCREEN_DIALOG")
    popover:SetFrameLevel(5)
    popover:SetClampedToScreen(true)
    popover:EnableMouse(true)
    popover:EnableMouseWheel(true)
    Skin.card(popover, "panel")
    popover:SetScript("OnMouseWheel", function(_, delta)
        offset = offset - delta
        renderRows()
    end)
    popover:SetScript("OnHide", function()
        catcher:Hide()
        if open then
            setChevron(open, false)
            Skin.setActive(open, false)
            open = nil
        end
    end)
    popover:Hide()
    if UISpecialFrames then
        table.insert(UISpecialFrames, POPOVER_NAME)
    end
end

--- Opens the list under the dropdown, or closes it when this dropdown already has it open.
function Dropdown.toggle(button)
    local wasOpen = open == button
    Dropdown.close()
    if wasOpen then
        return
    end
    if not popover then
        createPopover()
    end
    items = button.getItems()
    offset = 0
    for index, entry in ipairs(items) do
        if entry.checked then
            offset = index - 1
            break
        end
    end
    open = button
    renderRows()
    local shown = math.min(#items, MAX_ROWS)
    popover:SetWidth(math.max(button:GetWidth(), 140))
    popover:SetHeight(shown * ROW_HEIGHT + PADDING * 2)
    popover:ClearAllPoints()
    popover:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
    catcher:Show()
    popover:Show()
    setChevron(button, true)
    Skin.setActive(button, true)
end

--- Sets the text the dropdown shows.
function Dropdown.setText(button, text)
    button:SetText(text)
    button.menuText = text
end

--- The button width that shows the widest of `textWidths` in full, kept between `minWidth` and `maxWidth`.
function Dropdown.fitWidth(textWidths, minWidth, maxWidth)
    local widest = 0
    for _, width in ipairs(textWidths) do
        widest = math.max(widest, width)
    end
    return math.max(minWidth, math.min(maxWidth or math.huge, math.ceil(widest) + TEXT_CHROME))
end

local function measure(label, text)
    label:SetText(text)
    if label.GetUnboundedStringWidth then
        return label:GetUnboundedStringWidth()
    end
    return label:GetStringWidth()
end

--- Widens the button so every entry it can show fits without being cut, up to config.maxWidth.
function Dropdown.fit(button)
    local label, widths = button.skin.label, {}
    for index, entry in ipairs(button.getItems()) do
        widths[index] = measure(label, entry.text)
    end
    if button.menuText then
        widths[#widths + 1] = measure(label, button.menuText)
    end
    label:SetText(button.menuText)
    button:SetWidth(Dropdown.fitWidth(widths, button.minWidth, button.maxWidth))
end

--- Builds a dropdown button named `name`. config.width is its width and config.items returns the entries when
--- the list opens: an array of { text, checked, func }, where func runs when the entry is chosen. With
--- config.maxWidth, Dropdown.fit can widen the button up to that width.
function Dropdown.create(parent, name, config)
    local button = CreateFrame("Button", name, parent)
    button:SetSize(config.width, Theme.metrics.input)
    button.minWidth, button.maxWidth = config.width, config.maxWidth
    button.getItems = config.items
    Skin.button(button, "secondary")
    local label = button.skin.label
    Skin.text(label, 13, "regular", "text")
    label:ClearAllPoints()
    label:SetPoint("LEFT", button, "LEFT", 10, 0)
    label:SetPoint("RIGHT", button, "RIGHT", -28, 0)
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    local chevron = Skin.buttonIcon(button, "chevron", 12)
    chevron:ClearAllPoints()
    chevron:SetPoint("RIGHT", button, "RIGHT", -10, 0)
    setChevron(button, false)
    button:SetScript("OnClick", Dropdown.toggle)
    -- A dropdown that hides (the dungeon picker) takes its open list with it.
    button:HookScript("OnHide", function()
        if open == button then
            Dropdown.close()
        end
    end)
    return button
end
