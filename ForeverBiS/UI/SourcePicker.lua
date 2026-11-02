-- The first-open screen: until the player picks a data source the window shows only this prompt and one
-- dropdown, covering every other panel. Once a source is saved the picker never shows again; the player changes
-- source from the dropdown at the start of the selector row.
local _, ns = ...

local SourcePicker = {}
ns.SourcePicker = SourcePicker

local Settings, Dropdown, Skin, Theme, L = ns.Settings, ns.Dropdown, ns.Skin, ns.Theme, ns.L

local cover, drop

local function sourceItems()
    local items = {}
    for _, source in ipairs(ForeverBiSModel and ForeverBiSModel.sources() or {}) do
        items[#items + 1] = {
            text = source.label,
            checked = false,
            func = function()
                if Settings.chooseSource(source.id) then
                    ns.requestRender({ scrollTop = true })
                end
            end,
        }
    end
    return items
end

--- Builds the cover below the window header, hidden until a render finds no source chosen.
function SourcePicker.create(parent)
    cover = CreateFrame("Frame", "ForeverBiSSourcePicker", parent)
    cover:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -Theme.metrics.header)
    cover:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    cover:SetFrameLevel(parent:GetFrameLevel() + 20)
    cover:EnableMouse(true)
    Skin.fill(cover, "bg")
    local prompt = Skin.label(cover, 15, "semibold", "text")
    prompt:SetPoint("CENTER", cover, "CENTER", 0, 40)
    prompt:SetText(L["Choose a data source"])
    local hint = Skin.label(cover, 12, "regular", "muted")
    hint:SetPoint("TOP", prompt, "BOTTOM", 0, -8)
    hint:SetText(L["You can change it later from the first dropdown at the top of the window."])
    drop = Dropdown.create(cover, "ForeverBiSSourcePickerDropDown", { width = 240, items = sourceItems })
    drop:SetPoint("TOP", hint, "BOTTOM", 0, -18)
    Dropdown.setText(drop, L["Select a source"])
    cover:Hide()
end

--- Shows the picker while sources exist but none is chosen yet; hides it otherwise. Returns true when it shows.
function SourcePicker.refresh()
    local needed = ForeverBiSModel ~= nil and #ForeverBiSModel.sources() > 0 and not Settings.sourceChosen()
    if needed then
        cover:Show()
    else
        Dropdown.close()
        cover:Hide()
    end
    return needed
end
