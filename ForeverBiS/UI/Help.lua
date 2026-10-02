-- The help icon and its tooltip. Clicking the icon pins the tooltip open.
local _, ns = ...

local Help = {}
ns.Help = Help

local L = ns.L

-- Sections of { heading, lines }; a line is plain text or { text, red, green, blue } for a colored one.
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
            { "Click this help icon to keep the help open or close it.", 1, 0.82, 0.2 },
        },
    },
}

local button
local pinned = false

local function addHeader(text)
    GameTooltip:AddLine("|cffffe35b" .. L[text] .. "|r", 1, 1, 1, true)
    local line = _G["GameTooltipTextLeft" .. GameTooltip:NumLines()]
    if line then
        line:SetFont(STANDARD_TEXT_FONT, 12, "THICKOUTLINE")
        line:SetTextColor(1, 0.89, 0.35)
    end
end

local function addLine(line)
    if type(line) == "table" then
        GameTooltip:AddLine(L[line[1]], line[2], line[3], line[4], true)
    else
        GameTooltip:AddLine(L[line], 0.9, 0.9, 0.9, true)
    end
end

local function showHelp()
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    GameTooltip:SetText(L["BiS Forever Help"], 1, 0.89, 0.35)
    for index, section in ipairs(SECTIONS) do
        addHeader(section[1])
        for _, line in ipairs(section[2]) do
            addLine(line)
        end
        if index < #SECTIONS then
            GameTooltip:AddLine(" ")
        end
    end
    GameTooltip:Show()
end

function Help.create(parent)
    button = CreateFrame("Button", nil, parent)
    button:SetSize(20, 20)
    button:SetPoint("CENTER", parent, "TOPRIGHT", -32, -62)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(button)
    icon:SetTexture("Interface\\Common\\help-i")
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    button:SetScript("OnEnter", showHelp)
    button:SetScript("OnLeave", function()
        if not pinned then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnClick", function()
        pinned = not pinned
        if pinned then
            showHelp()
        else
            GameTooltip:Hide()
        end
    end)
end
