local function click(button)
    WowStub.fire(button, "OnClick")
end

local function helpButton()
    return WowStub.find("Button", function(button)
        return button.text == "?"
    end)[1]
end

local function helpPopover()
    return WowStub.find("Frame", function(frame)
        return frame.scripts.OnHide ~= nil and frame.skinFill ~= nil and frame.width == 460
    end)[1]
end

--- True when some edge of the frame's border is the accent color.
local function hasAccentEdge(frame)
    for _, region in ipairs(frame.regions) do
        local color = region.colorTexture
        if color and math.abs(color[1] - 0x3F / 255) < 0.001 and color[3] == 1 then
            return true
        end
    end
    return false
end

describe("Help popover", function()
    before_each(function()
        WowStub.load({ class = "druid", build = "" })
    end)

    it("lists the sections and starts hidden", function()
        assert.is_false(helpPopover():IsShown())
        assert.is_true(WowStub.hasText("CLASS & BUILD"))
        assert.is_true(WowStub.hasText("BiS Forever Help"))
    end)

    it("shows on hover and hides when the mouse leaves", function()
        WowStub.fire(helpButton(), "OnEnter")
        assert.is_true(helpPopover():IsShown())
        WowStub.fire(helpButton(), "OnLeave")
        assert.is_false(helpPopover():IsShown())
    end)

    it("stays open after a click until it is clicked again", function()
        WowStub.fire(helpButton(), "OnEnter")
        click(helpButton())
        WowStub.fire(helpButton(), "OnLeave")
        assert.is_true(helpPopover():IsShown())
        click(helpButton())
        assert.is_false(helpPopover():IsShown())
    end)

    it("unpins when it hides, so the next hover behaves normally", function()
        click(helpButton())
        helpPopover():Hide()
        WowStub.fire(helpButton(), "OnEnter")
        WowStub.fire(helpButton(), "OnLeave")
        assert.is_false(helpPopover():IsShown())
    end)
end)

describe("Gear panel look", function()
    before_each(function()
        WowStub.load({ class = "druid", build = "" })
    end)

    it("shows Equipped Only as a toggle with the selected state", function()
        local toggle = WowStub.find("Button", function(button)
            return button.text == "Equipped Only: Off"
        end)[1]
        assert.is_false(toggle.skin.active)
        click(toggle)
        assert.are.equal("Equipped Only: On", toggle.text)
        assert.is_true(toggle.skin.active)
    end)

    it("turns a slot border accent while hovered and restores it after", function()
        local icon = WowStub.find("Button", function(button)
            return button.width == 32 and button.height == 32 and button.scripts.OnClick and not button.skin
        end)[1]
        assert.is_false(hasAccentEdge(icon))
        WowStub.fireHooks(icon, "OnEnter")
        assert.is_true(hasAccentEdge(icon))
        WowStub.fireHooks(icon, "OnLeave")
        assert.is_false(hasAccentEdge(icon))
    end)
end)

describe("Dungeon notice look", function()
    it("turns its border accent under the mouse", function()
        WowStub.load({ class = "rogue", build = "" })
        local notice = _G.ForeverBiSDungeonNotice
        local edge = notice.skinBorder.textures[1]
        assert.is_near(1, edge.colorTexture[1], 0.001)
        WowStub.fireHooks(notice, "OnEnter")
        assert.is_near(0x3F / 255, edge.colorTexture[1], 0.001)
        WowStub.fireHooks(notice, "OnLeave")
        assert.is_near(1, edge.colorTexture[1], 0.001)
    end)
end)
