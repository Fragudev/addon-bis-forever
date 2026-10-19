local function makeItems(count, chosen)
    local items, picked = {}, {}
    for index = 1, count do
        items[index] = {
            text = "Option " .. index,
            checked = index == chosen,
            func = function()
                table.insert(picked, index)
            end,
        }
    end
    return items, picked
end

local Dropdown, parent

local function create(name, items)
    return Dropdown.create(parent, name, {
        width = 150,
        items = function()
            return items
        end,
    })
end

local function popover()
    return _G.ForeverBiSDropdownList
end

local function visibleRows()
    local rows = {}
    for _, row in ipairs(popover().children) do
        if row.shown then
            table.insert(rows, row)
        end
    end
    return rows
end

describe("Dropdown", function()
    before_each(function()
        WowStub.reset()
        local ns = WowStub.loadFiles({ "UI/Theme.lua", "UI/Pixel.lua", "UI/Skin.lua", "UI/Dropdown.lua" })
        Dropdown = ns.Dropdown
        parent = CreateFrame("Frame", nil, UIParent)
    end)

    describe("window", function()
        it("shows everything when the list fits", function()
            assert.are.same({ 1, 5, 0 }, { Dropdown.window(5, 0, 12) })
        end)

        it("starts at the offset when the list is longer than the window", function()
            assert.are.same({ 4, 15, 3 }, { Dropdown.window(30, 3, 12) })
        end)

        it("clamps the offset to what can be scrolled", function()
            assert.are.same({ 19, 30, 18 }, { Dropdown.window(30, 99, 12) })
            assert.are.same({ 1, 12, 0 }, { Dropdown.window(30, -4, 12) })
        end)
    end)

    describe("text", function()
        it("shows and remembers the chosen text", function()
            local drop = create("TestDrop", makeItems(2))
            Dropdown.setText(drop, "Option 2")
            assert.are.equal("Option 2", drop.text)
            assert.are.equal("Option 2", drop.menuText)
        end)
    end)

    describe("opening", function()
        it("opens a list with one row per entry and the checked one marked", function()
            local drop = create("TestDrop", makeItems(3, 2))
            WowStub.fire(drop, "OnClick")
            assert.is_true(Dropdown.isOpen())
            assert.is_true(popover():IsShown())
            local rows = visibleRows()
            assert.are.equal(3, #rows)
            assert.are.equal("Option 1", rows[1].label.text)
            assert.is_false(rows[1].check.shown)
            assert.is_true(rows[2].check.shown)
        end)

        it("runs the entry and closes when a row is chosen", function()
            local items, picked = makeItems(3)
            local drop = create("TestDrop", items)
            WowStub.fire(drop, "OnClick")
            WowStub.fire(visibleRows()[3], "OnClick")
            assert.are.same({ 3 }, picked)
            assert.is_false(popover():IsShown())
            assert.is_false(Dropdown.isOpen())
        end)

        it("closes when the same dropdown is clicked again", function()
            local drop = create("TestDrop", makeItems(2))
            WowStub.fire(drop, "OnClick")
            WowStub.fire(drop, "OnClick")
            assert.is_false(Dropdown.isOpen())
            assert.is_false(popover():IsShown())
        end)

        it("moves the list to another dropdown that is clicked", function()
            local first = create("TestDropOne", makeItems(2))
            local second = create("TestDropTwo", makeItems(4))
            WowStub.fire(first, "OnClick")
            WowStub.fire(second, "OnClick")
            assert.is_true(Dropdown.isOpen())
            assert.are.equal(4, #visibleRows())
            assert.is_false(first.skin.active)
            assert.is_true(second.skin.active)
        end)

        it("closes on a click outside, on Escape and when its dropdown hides", function()
            local drop = create("TestDrop", makeItems(2))
            WowStub.fire(drop, "OnClick")
            local catcher
            for _, frame in ipairs(WowStub.frames) do
                if frame.kind == "Button" and frame.scripts.OnClick == Dropdown.close then
                    catcher = frame
                end
            end
            WowStub.fire(catcher, "OnClick")
            assert.is_false(Dropdown.isOpen())

            assert.are.equal("ForeverBiSDropdownList", UISpecialFrames[1])
            WowStub.fire(drop, "OnClick")
            popover():Hide()
            assert.is_false(Dropdown.isOpen())

            WowStub.fire(drop, "OnClick")
            drop:Hide()
            assert.is_false(popover():IsShown())
        end)

        it("does nothing when closed with no list built", function()
            assert.has_no.errors(Dropdown.close)
            assert.is_false(Dropdown.isOpen())
        end)
    end)

    describe("long lists", function()
        it("shows twelve rows, scrolls with the wheel and starts at the checked entry", function()
            local items = makeItems(30, 20)
            local drop = create("TestDrop", items)
            WowStub.fire(drop, "OnClick")
            local rows = visibleRows()
            assert.are.equal(12, #rows)
            assert.are.equal("Option 19", rows[1].label.text)
            WowStub.fire(popover(), "OnMouseWheel", 1)
            assert.are.equal("Option 18", visibleRows()[1].label.text)
            WowStub.fire(popover(), "OnMouseWheel", -5)
            assert.are.equal("Option 19", visibleRows()[1].label.text)
        end)
    end)
end)
