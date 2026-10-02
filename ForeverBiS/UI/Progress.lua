-- Progress towards the selected list: "BiS 3/17" and a thin bar beside the Equipped Only button, with a tooltip.
local _, ns = ...

local Progress = {}
ns.Progress = Progress

local Catalog, Inventory, L = ns.Catalog, ns.Inventory, ns.L

local TOOLTIP_LINES = 8
local SOURCE_LENGTH = 36
local BAR_WIDTH = 78

local progressFrame, progressText, progressFill
-- The last computed progress and its heading, read by the tooltip.
local current, currentLabel

local function phaseLabelFor(route, phaseId)
    for _, phase in ipairs(ForeverBiSModel.phases(route)) do
        if phase.id == phaseId then
            return phase.label or phase.id
        end
    end
    return phaseId
end

local function pendingSlots()
    local pending = {}
    for _, slot in ipairs(current.slots) do
        if not slot.done and slot.target then
            pending[#pending + 1] = slot
        end
    end
    return pending
end

local function pendingLine(slot)
    local source = slot.target.source or ""
    if #source > SOURCE_LENGTH then
        source = source:sub(1, SOURCE_LENGTH - 3) .. "..."
    end
    local line = slot.slot .. ": " .. (slot.target.inBags and L["Equip: "] or "") .. slot.target.name
    if source ~= "" then
        line = line .. " (" .. source .. ")"
    end
    return line
end

local function showTooltip(owner)
    if not current then
        return
    end
    local total = current.total
    GameTooltip:SetOwner(owner, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText(currentLabel, 1, 0.89, 0.35)
    GameTooltip:AddLine(
        L["BiS: %d/%d slots - Listed: %d/%d"]:format(current.bis, total, current.listed, total),
        1,
        1,
        1
    )
    local pending = pendingSlots()
    for index = 1, math.min(#pending, TOOLTIP_LINES) do
        GameTooltip:AddLine(pendingLine(pending[index]), 0.85, 0.85, 0.85)
    end
    if #pending > TOOLTIP_LINES then
        GameTooltip:AddLine(L["+%d more"]:format(#pending - TOOLTIP_LINES), 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

--- Builds the line and bar on the gear panel.
function Progress.create(parent)
    progressFrame = CreateFrame("Frame", nil, parent)
    progressFrame:SetSize(BAR_WIDTH, 20)
    progressFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, -30)
    progressFrame:EnableMouse(true)
    progressText = progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    progressText:SetPoint("TOPLEFT", progressFrame, "TOPLEFT", 0, 0)
    local track = progressFrame:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface\\Buttons\\WHITE8X8")
    track:SetVertexColor(0.05, 0.03, 0.02, 0.9)
    track:SetSize(BAR_WIDTH, 4)
    track:SetPoint("BOTTOMLEFT", progressFrame, "BOTTOMLEFT", 0, 0)
    progressFill = progressFrame:CreateTexture(nil, "ARTWORK")
    progressFill:SetTexture("Interface\\Buttons\\WHITE8X8")
    progressFill:SetVertexColor(1, 0.82, 0.2, 1)
    progressFill:SetHeight(4)
    progressFill:SetPoint("BOTTOMLEFT", progressFrame, "BOTTOMLEFT", 0, 0)
    progressFrame:SetScript("OnEnter", showTooltip)
    progressFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

--- Recomputes the line from the view (see Lists.view); a view without a list hides it.
function Progress.refresh(view)
    current = view.data and ForeverBiSModel.progress(view.data, Inventory.buildOwned(Catalog.progressKeys()))
    if not current or current.total == 0 then
        current = nil
        view.progress = nil
        progressFrame:Hide()
        return
    end
    view.progress = current -- the paper doll reads the same evaluation to mark the slots still missing
    local route, phaseId = view.route, view.phaseId
    local routeLabel = route and ForeverBiSModel.label(route)
    local phaseLabel = route and phaseId and phaseLabelFor(route, phaseId)
    currentLabel = routeLabel and phaseLabel and (routeLabel .. " - " .. phaseLabel) or routeLabel or L["BiS"]
    progressText:SetText(L["BiS %d/%d"]:format(current.bis, current.total))
    if current.bis > 0 then
        progressFill:SetWidth(BAR_WIDTH * current.bis / current.total)
        progressFill:Show()
    else
        progressFill:Hide()
    end
    progressFrame:Show()
end
