-- Minimal WoW API stubs so the addon can load and render under busted outside the client.
-- Extend only with the APIs a spec actually needs.

local Toc = dofile("tests/support/toc.lua")

local Stub = {}
_G.WowStub = Stub

local frameMethods = {}

-- WoW widget methods are CamelCase; lowercase keys are plain fields and must stay nil.
local frameMeta = {
    __index = function(_, key)
        if frameMethods[key] then
            return frameMethods[key]
        end
        if type(key) == "string" and key:match("^%u") then
            return function() end
        end
        return nil
    end,
}

local function newFrame(kind, name, parent)
    local frame = setmetatable({
        kind = kind,
        frameName = name,
        parent = parent,
        shown = true,
        scripts = {},
        events = {},
        points = {},
        width = 100,
        height = 100,
        children = {},
        regions = {},
    }, frameMeta)
    if parent and parent.children then
        local isRegion = kind == "FontString" or kind == "Texture"
        table.insert(isRegion and parent.regions or parent.children, frame)
    end
    table.insert(Stub.frames, frame)
    if name then
        _G[name] = frame
    end
    return frame
end

function frameMethods.GetChildren(self)
    return unpack(self.children)
end
function frameMethods.GetRegions(self)
    return unpack(self.regions)
end
function frameMethods.SetParent(self, parent)
    local old = self.parent
    if old then
        for _, list in ipairs({ old.children, old.regions }) do
            for index, item in ipairs(list) do
                if item == self then
                    table.remove(list, index)
                    break
                end
            end
        end
    end
    self.parent = parent
end
function frameMethods.CreateFontString(self)
    local fontString = newFrame("FontString", nil, self)
    table.insert(Stub.fontStrings, fontString)
    return fontString
end
function frameMethods.CreateTexture(self)
    return newFrame("Texture", nil, self)
end
function frameMethods.SetScript(self, name, handler)
    self.scripts[name] = handler
end
function frameMethods.HookScript(self, name, handler)
    self.hooks = self.hooks or {}
    self.hooks[name] = self.hooks[name] or {}
    table.insert(self.hooks[name], handler)
end
function frameMethods.GetParent(self)
    return self.parent
end
function frameMethods.GetScript(self, name)
    return self.scripts[name]
end
function frameMethods.RegisterEvent(self, event)
    self.events[event] = true
end
function frameMethods.Show(self)
    self.shown = true
end
function frameMethods.Hide(self)
    self.shown = false
end
function frameMethods.IsShown(self)
    return self.shown
end
function frameMethods.SetText(self, text)
    self.text = text
end
function frameMethods.GetText(self)
    return self.text
end
function frameMethods.SetSize(self, width, height)
    self.width, self.height = width, height
end
function frameMethods.SetWidth(self, width)
    self.width = width
end
function frameMethods.SetHeight(self, height)
    self.height = height
end
function frameMethods.GetWidth(self)
    return self.width
end
function frameMethods.GetHeight(self)
    return self.height
end
function frameMethods.GetStringHeight()
    return 12
end
function frameMethods.GetStringWidth()
    return 60
end
function frameMethods.SetTexture(self, texture)
    self.texture = texture
end
function frameMethods.GetFrameLevel()
    return 1
end
function frameMethods.GetEffectiveScale()
    return 1
end
function frameMethods.SetPoint(self, ...)
    table.insert(self.points, { ... })
end
function frameMethods.SetScrollChild(self, child)
    self.scrollChild = child
end

--- Fire a script handler the way the client would, e.g. Stub.fire(button, "OnClick").
function Stub.fire(frame, script, ...)
    local handler = assert(frame.scripts[script], "no " .. script .. " handler")
    return handler(frame, ...)
end

--- Run the HookScript handlers a frame registered for a script, e.g. Stub.fireHooks(GameTooltip, "OnTooltipSetItem").
function Stub.fireHooks(frame, script, ...)
    for _, handler in ipairs(frame.hooks and frame.hooks[script] or {}) do
        handler(frame, ...)
    end
end

--- Loads the tooltip decorator (after the model, like the .toc) with whatever tooltip API globals are currently set.
function Stub.loadTooltip()
    Stub.ns = Toc.load({ only = { "ForeverBiS_Locale.lua", "Core/Settings.lua", "ForeverBiS_Tooltip.lua" } })
end

--- A frame is live while its parent chain still reaches UIParent (cleared content is detached).
function Stub.attached(frame)
    while frame.parent do
        frame = frame.parent
    end
    return frame == _G.UIParent
end

--- Live frames of one kind matching an optional predicate, in creation order.
function Stub.find(kind, predicate)
    local found = {}
    for _, frame in ipairs(Stub.frames) do
        if frame.kind == kind and Stub.attached(frame) and (not predicate or predicate(frame)) then
            table.insert(found, frame)
        end
    end
    return found
end

--- Texts of the FontStrings still attached to a frame, in creation order.
function Stub.texts()
    local texts = {}
    for _, fontString in ipairs(Stub.fontStrings) do
        if fontString.text and Stub.attached(fontString) then
            table.insert(texts, fontString.text)
        end
    end
    return texts
end

--- True when some rendered FontString text contains the plain-text fragment.
function Stub.hasText(fragment)
    for _, text in ipairs(Stub.texts()) do
        if text:find(fragment, 1, true) then
            return true
        end
    end
    return false
end

function Stub.reset()
    Stub.frames = {}
    Stub.fontStrings = {}
    Stub.menus = {}
    Stub.equipped = {}
    Stub.bagCounts = {}
    Stub.player = { class = "Rogue", token = "ROGUE", level = 30 }

    _G.UIParent = newFrame("Frame", nil)
    _G.Minimap = newFrame("Frame", nil)
    Stub.tooltip = { lines = {} }
    local tooltip = newFrame("GameTooltip", nil)
    tooltip.SetOwner = function(_, owner)
        Stub.tooltip.owner, Stub.tooltip.hyperlink, Stub.tooltip.title = owner, nil, nil
        Stub.tooltip.lines = {}
    end
    tooltip.SetHyperlink = function(_, link)
        Stub.tooltip.hyperlink = link
    end
    tooltip.SetText = function(_, text)
        Stub.tooltip.title = text
    end
    tooltip.AddLine = function(_, text)
        table.insert(Stub.tooltip.lines, text)
    end
    _G.GameTooltip = tooltip
    _G.SlashCmdList = {}
    _G.TooltipDataProcessor, _G.Enum, _G.ItemRefTooltip, _G.ForeverBiSTooltip = nil, nil, nil, nil
    _G.ForeverBiSDB, _G.ForeverBiSCharDB = nil, nil
    _G.SLASH_FOREVERBIS1, _G.SLASH_FOREVERBIS2 = nil, nil
end

-- Saved values that live account-wide; everything else a spec seeds belongs to the character.
local ACCOUNT_KEYS = { minimap = true, tooltip = true, tooltipAllClasses = true }

--- Splits a seed table the way the saved variables are split: account-wide keys and per-character keys.
local function seedSavedVariables(db)
    if db == nil then
        return
    end
    _G.ForeverBiSDB, _G.ForeverBiSCharDB = {}, { migrated = true }
    for key, value in pairs(db) do
        local target = ACCOUNT_KEYS[key] and _G.ForeverBiSDB or _G.ForeverBiSCharDB
        target[key] = value
    end
end

--- Loads every file listed in the .toc into a fresh namespace. An optional hook runs right after the data file,
--- to reshape ForeverBiSData before the model derives the legacy globals from it.
function Stub.load(db, dataHook, player)
    Stub.reset()
    Stub.player = player or Stub.player
    seedSavedVariables(db)
    Stub.ns = Toc.load({
        after = {
            ["ForeverBiS_Data.lua"] = dataHook and function()
                dataHook(_G.ForeverBiSData)
            end,
        },
    })
end

--- Loads only the listed .toc files (paths as written in the .toc), in .toc order, into a fresh namespace.
function Stub.loadFiles(only)
    Stub.ns = Toc.load({ only = only })
    return Stub.ns
end

--- Loads only the data file and the model (the legacy globals), without building the UI.
function Stub.loadData(hook)
    Stub.ns = Toc.load({
        only = { "ForeverBiS_Data.lua", "ForeverBiS_Model.lua" },
        after = {
            ["ForeverBiS_Data.lua"] = hook and function()
                hook(_G.ForeverBiSData)
            end,
        },
    })
end

_G.CreateFrame = function(kind, name, parent)
    return newFrame(kind, name, parent)
end

-- Specs switch the client locale through Stub.locale before loading the addon.
Stub.locale = "enUS"
_G.GetLocale = function()
    return Stub.locale
end

_G.STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
_G.ITEM_QUALITY_COLORS = setmetatable({}, {
    __index = function()
        return { r = 1, g = 1, b = 1 }
    end,
})
_G.RAID_CLASS_COLORS = { ROGUE = { r = 1, g = 0.96, b = 0.41 }, DRUID = { r = 1, g = 0.49, b = 0.04 } }

_G.C_Item = {
    RequestLoadItemDataByID = function() end,
    GetItemInfoInstant = function() end,
    GetItemIconByID = function() end,
    GetItemQualityByID = function() end,
}
_G.GetItemInfoInstant = function() end
_G.GetItemInfo = function() end
_G.GetItemIcon = function() end

_G.GetInventoryItemID = function(_, slotID)
    return Stub.equipped[slotID]
end
_G.GetItemCount = function(itemID)
    return Stub.bagCounts[itemID] or 0
end

-- Timers run immediately so debounced renders stay synchronous under test.
_G.C_Timer = {
    After = function(_, callback)
        callback()
    end,
}

_G.GetCursorPosition = function()
    return 0, 0
end
_G.UnitName = function()
    return "Tester"
end
_G.UnitFullName = function()
    return "Tester", "Realm"
end
_G.GetRealmName = function()
    return "Realm"
end
-- Configure per test through Stub.player = { class = "Druid", token = "DRUID", level = 12 }.
_G.UnitClass = function()
    return Stub.player.class, Stub.player.token
end
-- Nil by default so specs see no faction filtering; set Stub.player.faction = "Horde" to opt in.
_G.UnitFactionGroup = function()
    return Stub.player.faction
end
_G.UnitLevel = function()
    return Stub.player.level
end

-- Dropdown helpers record what a menu would show; specs drive them through Stub.menus.
_G.UIDropDownMenu_SetWidth = function() end
_G.UIDropDownMenu_SetText = function(dropdown, text)
    dropdown.menuText = text
end
_G.UIDropDownMenu_Initialize = function(dropdown, initializer)
    dropdown.initializer = initializer
end
_G.UIDropDownMenu_CreateInfo = function()
    return {}
end
_G.UIDropDownMenu_AddButton = function(info)
    table.insert(Stub.menus, info)
end

Stub.reset()
