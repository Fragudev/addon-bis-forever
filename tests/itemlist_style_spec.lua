local function click(button)
    WowStub.fire(button, "OnClick")
end

--- Gives the list's scroll frame a real scroll position, which the stub does not keep.
local function trackScroll()
    local scroll = _G.ForeverBiSScroll
    scroll.position = 0
    scroll.GetVerticalScroll = function(self)
        return self.position
    end
    scroll.SetVerticalScroll = function(self, value)
        self.position = value
    end
    return scroll
end

describe("Item list look", function()
    it("marks an active source filter with the selected state", function()
        WowStub.load(nil)
        click(ForeverBiSFilterquest)
        assert.is_true(ForeverBiSFilterquest.skin.active)
        assert.is_true(ForeverBiSFilterquest.skin.underline.shown)
        click(ForeverBiSFilterquest)
        assert.is_false(ForeverBiSFilterquest.skin.active)
    end)

    it("shows a hint under the title when nothing matches", function()
        WowStub.load({ class = "druid", build = "" })
        local searchBox
        for _, candidate in ipairs(WowStub.frames) do
            if candidate.scripts.OnTextChanged then
                searchBox = candidate
            end
        end
        searchBox:SetText("zzzz-no-such-item")
        WowStub.fire(searchBox, "OnTextChanged")
        assert.is_true(WowStub.hasText("No items match the current search and filters."))
        assert.is_true(WowStub.hasText("Try a different search, or clear the filters."))
    end)

    it("washes a row on hover and keeps the wash while the mouse is on its icon", function()
        WowStub.load({ class = "druid", build = "" })
        local row = WowStub.find("Frame", function(frame)
            return frame.setHover ~= nil
        end)[1]
        local wash = row.regions[1]
        WowStub.fire(row, "OnEnter")
        assert.are.equal(0.06, wash.colorTexture[4])
        WowStub.fire(row, "OnLeave")
        assert.are.equal(0, wash.colorTexture[4])
        local icon = WowStub.find("Button", function(button)
            return button.width == 38 and button.height == 38
        end)[1]
        WowStub.fireHooks(icon, "OnEnter")
        assert.are.equal(0.06, wash.colorTexture[4])
        WowStub.fireHooks(icon, "OnLeave")
        assert.are.equal(0, wash.colorTexture[4])
    end)

    it("scrolls with the wheel without leaving the list", function()
        WowStub.load({ class = "druid", build = "" })
        local scroll = trackScroll()
        scroll:SetHeight(100)
        WowStub.find("Frame", function(frame)
            return frame.parent == scroll
        end)[1]
            :SetHeight(1000)
        WowStub.fire(scroll, "OnMouseWheel", -1)
        assert.are.equal(48, scroll.position)
        WowStub.fire(scroll, "OnMouseWheel", 5)
        assert.are.equal(0, scroll.position)
        WowStub.fire(scroll, "OnMouseWheel", -100)
        assert.are.equal(900, scroll.position)
    end)

    it("hides the scrollbar when everything fits and drags the thumb otherwise", function()
        WowStub.load({ class = "druid", build = "" })
        local scroll = trackScroll()
        local content = WowStub.find("Frame", function(frame)
            return frame.parent == scroll
        end)[1]
        local track = WowStub.find("Frame", function(frame)
            return frame.parent == ForeverBiSFrame and frame.skinFill ~= nil and frame.width == 4
        end)[1]
        scroll:SetHeight(100)
        content:SetHeight(50)
        WowStub.fire(scroll, "OnVerticalScroll")
        assert.is_false(track.shown)

        content:SetHeight(1000)
        WowStub.fire(scroll, "OnVerticalScroll")
        assert.is_true(track.shown)
        local thumb = track.children[1]
        assert.are.equal(24, thumb.height)

        local cursor = 500
        _G.GetCursorPosition = function()
            return 0, cursor
        end
        WowStub.fire(thumb, "OnMouseDown")
        cursor = 450
        thumb.scripts.OnUpdate(thumb)
        -- 50 units down the 76 of travel is 50 / 76 of the 900 that can scroll.
        assert.is_near(50 / 76 * 900, scroll.position, 0.001)
        WowStub.fire(thumb, "OnMouseUp")
        assert.is_nil(thumb.scripts.OnUpdate)
        WowStub.fireHooks(thumb, "OnEnter")
        WowStub.fireHooks(thumb, "OnLeave")
        _G.GetCursorPosition = function()
            return 0, 0
        end
    end)
end)
