-- The help button and its popover. Hovering the button shows the popover; clicking it pins it open.
local _, ns = ...

local Help = {}
ns.Help = Help

local Theme, Skin, L = ns.Theme, ns.Skin, ns.L

-- Sections of { heading, lines }; a line is plain text or { text, color token } for a colored one.
local SECTIONS = {
    {
        "CLASS & BUILD",
        { "Choose a class and specialization/build to load its BiS list." },
    },
    {
        "SEARCH & FILTERS",
        {
            "Search by item, boss or zone. The icon buttons filter by source and can be combined; the dungeon list appears with the dungeon button.",
            "The faction button hides items exclusive to the other faction. The maker button cycles between all items, only items their maker alone can wear, and hiding those items.",
            "Faction-exclusive items show a faction emblem and colored faction name.",
        },
    },
    {
        "ITEM LIST",
        {
            "Numbers show rank. Item names use their rarity color; source colors distinguish the source from its location.",
            "Hover an item icon for its in-game tooltip. Yellow exclamation = quest; finder eye = dungeon/raid; map = world; profession icon = profession.",
            "Green check = equipped in that slot; gold xN = copies in your bags.",
            "Click + or - beside a slot heading to collapse or expand its list.",
        },
    },
    {
        "BEST IN SLOT",
        {
            "Click a gear icon to jump to its slot in the list; hover for item and source details.",
            "Equipped Only filters this panel to BiS items already worn. A BiS ring or trinket counts in either of its two equipment slots.",
        },
    },
    {
        "WINDOW & MINIMAP",
        {
            "Drag the title area to move the window; drag its bottom handle to resize vertically. Click the minimap icon to toggle the addon and drag it to reposition.",
            { "Click this help icon to keep the help open or close it.", "warning" },
        },
    },
}

local WIDTH, PADDING = 460, 18

local button, popover
local pinned = false

--- Builds the popover once: a title, then each section's label and lines stacked top to bottom.
local function createPopover(parent)
    popover = CreateFrame("Frame", nil, parent)
    popover:SetFrameStrata("FULLSCREEN_DIALOG")
    popover:SetClampedToScreen(true)
    popover:SetWidth(WIDTH)
    popover:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -6)
    Skin.card(popover, "panel")
    local textWidth = WIDTH - PADDING * 2
    local y = -PADDING
    local title = Skin.label(popover, 15, "semibold", "text")
    title:SetPoint("TOPLEFT", popover, "TOPLEFT", PADDING, y)
    title:SetText(L["BiS Forever Help"])
    y = y - title:GetStringHeight() - 14
    for _, section in ipairs(SECTIONS) do
        local header = Skin.sectionLabel(Skin.label(popover, 11, "semibold", "muted"), L[section[1]])
        header:SetPoint("TOPLEFT", popover, "TOPLEFT", PADDING, y)
        y = y - header:GetStringHeight() - 6
        for _, line in ipairs(section[2]) do
            local text, token = line, "dim"
            if type(line) == "table" then
                text, token = line[1], line[2]
            end
            local label = Skin.label(popover, 13, "regular", token)
            label:SetPoint("TOPLEFT", popover, "TOPLEFT", PADDING, y)
            label:SetWidth(textWidth)
            label:SetJustifyH("LEFT")
            label:SetWordWrap(true)
            label:SetText(L[text])
            y = y - label:GetStringHeight() - 6
        end
        y = y - 8
    end
    popover:SetHeight(-y + PADDING - 8)
    popover:SetScript("OnHide", function()
        pinned = false
    end)
    popover:Hide()
end

function Help.create(parent)
    button = CreateFrame("Button", nil, parent)
    button:SetSize(Theme.metrics.button, Theme.metrics.button)
    button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, -64)
    Skin.button(button, "ghost")
    Skin.text(button.skin.label, 15, "semibold", "dim")
    button:SetText("?")
    createPopover(parent)
    button:SetScript("OnEnter", function()
        popover:Show()
    end)
    button:SetScript("OnLeave", function()
        if not pinned then
            popover:Hide()
        end
    end)
    button:SetScript("OnClick", function()
        pinned = not pinned
        if pinned then
            popover:Show()
        else
            popover:Hide()
        end
    end)
end
