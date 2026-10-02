-- The minimap button: click toggles the window, drag moves it around the minimap.
local _, ns = ...

-- Not named Minimap: that is the client's minimap frame.
local MinimapButton = {}
ns.MinimapButton = MinimapButton

local Settings, L = ns.Settings, ns.L

local button

local function updatePosition()
    local angle = math.rad(Settings.minimapAngle())
    local radius = Minimap:GetWidth() / 2 + 2
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function onDragUpdate(self)
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    local startX, startY = self.startCursorX / scale, self.startCursorY / scale
    if math.abs(cursorX - startX) + math.abs(cursorY - startY) > 4 then
        self.dragMoved = true
    end
    local centerX, centerY = Minimap:GetCenter()
    if centerX and centerY then
        Settings.setMinimapAngle(math.deg(math.atan2(cursorY - centerY, cursorX - centerX)))
        updatePosition()
    end
end

function MinimapButton.create()
    button = CreateFrame("Button", "ForeverBiSMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\ForeverBiS\\ForeverBiSMinimapIcon.tga")
    icon:SetSize(28, 28)
    icon:SetPoint("CENTER")

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L["Forever BiS"], 1, 0.89, 0.35)
        GameTooltip:AddLine(L["Click to open or close"], 1, 1, 1)
        GameTooltip:AddLine(L["Drag to move the button"], 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnDragStart", function(self)
        self.dragMoved = false
        self.startCursorX, self.startCursorY = GetCursorPosition()
        self:SetScript("OnUpdate", onDragUpdate)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self.suppressNextClick = self.dragMoved
    end)
    button:SetScript("OnClick", function(self)
        if self.suppressNextClick then
            self.suppressNextClick = false
            return
        end
        ns.toggleWindow()
    end)
    MinimapButton.refresh()
end

--- Places the button from the saved angle and hides it when the saved settings say so.
function MinimapButton.refresh()
    updatePosition()
    if Settings.minimapHidden() then
        button:Hide()
    end
end
