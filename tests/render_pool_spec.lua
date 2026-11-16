local ns

local function load()
    WowStub.load({ class = "druid", build = "" })
    ns = WowStub.ns
    ns.MainFrame.open()
end

local function searchBox()
    for _, candidate in ipairs(WowStub.frames) do
        if candidate.scripts.OnTextChanged then
            return candidate
        end
    end
end

local function type_(box, text)
    box:SetText(text)
    WowStub.fire(box, "OnTextChanged")
end

local function slotButtons()
    return WowStub.find("Button", function(button)
        return button.width == 32 and button.qualityBorder ~= nil
    end)
end

--- Texts and icons the list shows, sorted so draw order does not matter.
local function listContent()
    local texts, textures = {}, {}
    for _, fontString in ipairs(WowStub.fontStrings) do
        if fontString.text and fontString.text ~= "" and WowStub.attached(fontString) and fontString.shown then
            table.insert(texts, fontString.text)
        end
    end
    for _, frame in ipairs(WowStub.frames) do
        if frame.kind == "Texture" and frame.texture and WowStub.attached(frame) and frame.shown then
            table.insert(textures, frame.texture)
        end
    end
    table.sort(texts)
    table.sort(textures, function(a, b)
        return tostring(a) < tostring(b)
    end)
    return texts, textures
end

describe("Render pooling", function()
    before_each(load)

    it("does not create new widgets when the list is rendered again", function()
        ns.requestRender()
        local created = #WowStub.frames
        assert.is_true(created > 0)
        for _ = 1, 5 do
            ns.requestRender()
        end
        assert.are.equal(created, #WowStub.frames)
    end)

    it("does not create new widgets when the paper doll is redrawn", function()
        ns.requestRender()
        local buttons = #slotButtons()
        assert.is_true(buttons > 0)
        local created = #WowStub.frames
        ns.requestRender()
        ns.requestRender()
        assert.are.equal(created, #WowStub.frames)
        assert.are.equal(buttons, #slotButtons())
    end)

    it("reuses widgets after the list shrinks and grows again", function()
        ns.requestRender()
        local box = searchBox()
        type_(box, "zzzz-no-such-item")
        type_(box, "")
        local afterCard = #WowStub.frames
        type_(box, "zzzz-no-such-item")
        type_(box, "")
        assert.are.equal(afterCard, #WowStub.frames)
    end)

    it("draws a reused list with the same texts and icons as a fresh one", function()
        ns.requestRender()
        local freshTexts, freshTextures = listContent()
        local box = searchBox()
        type_(box, "zzzz-no-such-item")
        type_(box, "")
        ns.requestRender()
        local texts, textures = listContent()
        assert.are.same(freshTexts, texts)
        assert.are.same(freshTextures, textures)
    end)

    it("keeps the paper doll slots interactive after reuse", function()
        ns.requestRender()
        ns.requestRender()
        local button = slotButtons()[1]
        assert.is_not_nil(button)
        WowStub.fire(button, "OnEnter")
        assert.is_true(#WowStub.tooltip.lines > 0)
    end)
end)

describe("Render requests", function()
    local realTimer = _G.C_Timer

    before_each(load)

    after_each(function()
        _G.C_Timer = realTimer
    end)

    it("does no work while the window is hidden and renders on the next show", function()
        ns.MainFrame.toggle() -- hide
        local drawn = 0
        local refresh = ns.ItemList.refresh
        ns.ItemList.refresh = function(...)
            drawn = drawn + 1
            return refresh(...)
        end
        ns.requestRender()
        ns.requestRender()
        assert.are.equal(0, drawn)
        ns.MainFrame.toggle() -- show
        assert.are.equal(1, drawn)
    end)

    it("debounces the search box into one render after the timer fires", function()
        local timers = {}
        _G.C_Timer = {
            After = function(_, callback)
                table.insert(timers, callback)
            end,
        }
        local renders = 0
        local request = ns.requestRender
        ns.requestRender = function(...)
            renders = renders + 1
            return request(...)
        end
        local box = searchBox()
        for _, text in ipairs({ "s", "sw", "swo" }) do
            type_(box, text)
        end
        assert.are.equal(0, renders)
        assert.are.equal("swo", ns.Filters.state.search)
        for _, callback in ipairs(timers) do
            callback()
        end
        assert.are.equal(1, renders)
    end)

    it("names the paper doll's missing slots missingSlots and leaves view.missing alone", function()
        local seen
        local refresh = ns.PaperDoll.refresh
        ns.PaperDoll.refresh = function(view)
            refresh(view)
            seen = view
        end
        ns.requestRender()
        assert.is_table(seen.missingSlots)
        assert.is_false(seen.missing)
    end)
end)
