-- The BiS window: class, spec and bracket dropdowns over one row per slot with the top 6 items as icons.

local savedTalents

--- Talent points per tree for the player ({ 0, 31, 0 }); `inspect` gives the inspected unit's points.
local function talents(points, inspect)
    _G.GetTalentTabInfo = function(tab, isInspect)
        local spent = (isInspect and inspect or points)[tab]
        return tab, "Tree " .. tab, "", "icon" .. tab, spent or 0
    end
end

local function ns()
    return WowStub.ns
end

local function open()
    ns().openWindow()
end

local function entries(dropdown)
    return dropdown.getItems()
end

local function entryTexts(dropdown)
    local texts = {}
    for _, entry in ipairs(entries(dropdown)) do
        texts[#texts + 1] = entry.text
    end
    return texts
end

local function pick(dropdown, text)
    for _, entry in ipairs(entries(dropdown)) do
        if entry.text == text then
            entry.func()
            return
        end
    end
    error("no entry " .. text)
end

--- The drawn item buttons grouped by row, each row in rank order: { { slot = name, ids = { ... }, buttons = { ... } } }.
local function rows()
    local bySlot, order = {}, {}
    for _, button in
        ipairs(WowStub.find("Button", function(frame)
            return frame.bisItemId ~= nil and frame.shown
        end))
    do
        local row = bySlot[button.bisRow]
        if not row then
            row = { slot = button.bisSlot, buttons = {} }
            bySlot[button.bisRow] = row
            order[#order + 1] = button.bisRow
        end
        row.buttons[button.bisRank] = button
    end
    table.sort(order)
    local result = {}
    for _, index in ipairs(order) do
        local row = bySlot[index]
        row.ids = {}
        for rank, button in ipairs(row.buttons) do
            row.ids[rank] = button.bisItemId
        end
        result[#result + 1] = row
    end
    return result
end

local function dataSlots(route, phase)
    return ForeverBiSData.sources.leveling.lists[route].phases[phase].slots
end

local function buttonFor(itemId)
    for _, row in ipairs(rows()) do
        for _, button in ipairs(row.buttons) do
            if button.bisItemId == itemId then
                return button
            end
        end
    end
end

describe("BiS window", function()
    before_each(function()
        savedTalents = _G.GetTalentTabInfo
    end)
    after_each(function()
        _G.GetTalentTabInfo = savedTalents
    end)

    describe("class and spec", function()
        it("detects the spec from the talents on first open", function()
            WowStub.load(nil, nil, { class = "Druid", token = "DRUID", level = 30 })
            talents({ 0, 0, 31 })
            open()
            assert.are.equal("druid", ForeverBiSCharDB.class)
            assert.are.equal("/restoration", ForeverBiSCharDB.build)
            assert.are.equal("Druid", ForeverBiSClassDropDown:GetText())
            assert.are.equal("Restoration", ForeverBiSSpecDropDown:GetText())
        end)

        it("falls back to the class's first spec when no talent point is spent", function()
            WowStub.load(nil, nil, { class = "Mage", token = "MAGE", level = 30 })
            talents({ 0, 0, 0 })
            open()
            assert.are.equal("mage", ForeverBiSCharDB.class)
            assert.are.equal("/arcane", ForeverBiSCharDB.build)
        end)

        it("remembers a class and spec chosen by hand and stops detecting", function()
            WowStub.load(nil, nil, { class = "Rogue", token = "ROGUE", level = 30 })
            talents({ 0, 31, 0 })
            open()
            assert.are.equal("Combat", ForeverBiSSpecDropDown:GetText())
            pick(ForeverBiSSpecDropDown, "Subtlety")
            assert.are.equal("/subtlety", ForeverBiSCharDB.build)
            ForeverBiSFrame:Hide()
            talents({ 31, 0, 0 })
            open()
            assert.are.equal("Subtlety", ForeverBiSSpecDropDown:GetText())
            pick(ForeverBiSClassDropDown, "Priest")
            ForeverBiSFrame:Hide()
            open()
            assert.are.equal("priest", ForeverBiSCharDB.class)
            assert.are.equal("Priest", ForeverBiSClassDropDown:GetText())
        end)

        it("lists every class and the specs of the selected class", function()
            WowStub.load(nil)
            open()
            assert.are.same(
                { "Warrior", "Hunter", "Mage", "Rogue", "Priest", "Warlock", "Paladin", "Druid", "Shaman" },
                entryTexts(ForeverBiSClassDropDown)
            )
            assert.are.same({ "Assassination", "Combat", "Subtlety" }, entryTexts(ForeverBiSSpecDropDown))
        end)

        it("switches to the first spec of a class picked by hand", function()
            WowStub.load(nil)
            open()
            pick(ForeverBiSClassDropDown, "Warlock")
            assert.are.equal("warlock", ForeverBiSCharDB.class)
            assert.are.equal("/dps", ForeverBiSCharDB.build)
        end)
    end)

    describe("bracket", function()
        local function bracketFor(level)
            WowStub.load(nil, nil, { class = "Rogue", token = "ROGUE", level = level })
            open()
            return ForeverBiSBracketDropDown:GetText()
        end

        it("defaults to the highest bracket at or below the player's level", function()
            assert.are.equal("Auto (Level 30)", bracketFor(35))
            assert.are.equal("Auto (Level 30)", bracketFor(30))
            assert.are.equal("Auto (Level 20)", bracketFor(12))
            assert.are.equal("Auto (Level 50)", bracketFor(59))
            assert.are.equal("Auto (Level 60 (pre-raid))", bracketFor(60))
        end)

        it("offers Auto, then every bracket of the route", function()
            WowStub.load(nil)
            open()
            assert.are.same({
                "Auto (Level 30)",
                "Level 20",
                "Level 30",
                "Level 40",
                "Level 50",
                "Level 60 (pre-raid)",
            }, entryTexts(ForeverBiSBracketDropDown))
        end)

        it("remembers a bracket chosen by hand per character, and Auto clears it", function()
            WowStub.load(nil)
            open()
            pick(ForeverBiSBracketDropDown, "Level 50")
            assert.are.equal("lvl50", ForeverBiSCharDB.phase)
            assert.is_nil(ForeverBiSDB.phase)
            assert.are.equal("Level 50", ForeverBiSBracketDropDown:GetText())
            assert.are.same(dataSlots("rogue/assassination", "lvl50")[1].items[1].id, rows()[1].ids[1])
            pick(ForeverBiSBracketDropDown, "Auto (Level 30)")
            assert.is_nil(ForeverBiSCharDB.phase)
        end)
    end)

    describe("grid", function()
        it("draws one row per slot with up to 6 items ranked Top 1 to Top 6", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true })
            open()
            local slots = dataSlots("rogue/combat", "lvl30")
            local drawn = rows()
            assert.are.equal(#slots, #drawn)
            for index, slot in ipairs(slots) do
                local expected = {}
                for rank = 1, math.min(6, #slot.items) do
                    expected[rank] = slot.items[rank].id
                end
                assert.are.equal(slot.slot, drawn[index].slot)
                assert.are.same(expected, drawn[index].ids)
            end
            for rank = 1, 6 do
                assert.is_true(WowStub.hasText("Top " .. rank))
            end
            assert.is_true(WowStub.hasText(slots[1].slot))
        end)

        it("never draws more than 6 icons in a row", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true }, function(data)
                local items = data.sources.leveling.lists["rogue/combat"].phases.lvl30.slots[1].items
                for extra = 1, 3 do
                    items[#items + 1] = { id = 900000 + extra, name = "Extra " .. extra, source = { text = "" } }
                end
            end)
            open()
            assert.are.equal(6, #rows()[1].ids)
        end)

        it("redraws the same rows without creating new widgets", function()
            WowStub.load(nil)
            open()
            local before = #WowStub.frames
            ns().requestRender()
            assert.are.equal(before, #WowStub.frames)
        end)

        it("borders an equipped item in green and leaves the others with the neutral border", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true })
            local head = dataSlots("rogue/combat", "lvl30")[1]
            assert.are.equal("Head", head.slot)
            WowStub.equipped[1] = head.items[2].id
            open()
            local function color(button)
                return { unpack(button.bisBorder.textures[1].colorTexture, 1, 3) }
            end
            local function token(name)
                local channels = { ns().Theme.Color(name) }
                return { channels[1], channels[2], channels[3] }
            end
            local worn = buttonFor(head.items[2].id)
            assert.are.equal("equipped", worn.bisMark)
            assert.are.same(token("success"), color(worn))
            local other = buttonFor(head.items[1].id)
            assert.is_nil(other.bisMark)
            assert.are.same(token("border"), color(other))
        end)

        it("updates the green border when the equipment changes", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true })
            local head = dataSlots("rogue/combat", "lvl30")[1]
            open()
            assert.is_nil(buttonFor(head.items[1].id).bisMark)
            WowStub.equipped[1] = head.items[1].id
            for _, frame in ipairs(WowStub.frames) do
                if frame.events.PLAYER_EQUIPMENT_CHANGED then
                    WowStub.fire(frame, "OnEvent", "PLAYER_EQUIPMENT_CHANGED")
                end
            end
            assert.are.equal("equipped", buttonFor(head.items[1].id).bisMark)
        end)

        it("shows the item tooltip on hover and hides it on leave", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true })
            open()
            local first = rows()[1].buttons[1]
            WowStub.fire(first, "OnEnter")
            assert.are.equal(first, WowStub.tooltip.owner)
            assert.are.equal("item:" .. first.bisItemId, WowStub.tooltip.hyperlink)
            local hidden = false
            _G.GameTooltip.Hide = function()
                hidden = true
            end
            WowStub.fire(first, "OnLeave")
            assert.is_true(hidden)
        end)

        it("links the item in chat on shift-click and does nothing on a plain click", function()
            WowStub.load({ class = "rogue", build = "/combat", routeChosen = true })
            open()
            local first = rows()[1].buttons[1]
            WowStub.fire(first, "OnClick")
            assert.are.same({}, WowStub.insertedLinks)
            WowStub.shift = true
            WowStub.fire(first, "OnClick")
            assert.are.equal(1, #WowStub.insertedLinks)
            assert.truthy(WowStub.insertedLinks[1]:find("item:" .. first.bisItemId, 1, true))
        end)

        it("shows an empty state when no list is loaded", function()
            WowStub.load(nil, function(data)
                data.sources = {}
            end)
            open()
            assert.are.same({}, rows())
            assert.is_true(WowStub.hasText("No BiS list is loaded for this build."))
        end)
    end)
end)
