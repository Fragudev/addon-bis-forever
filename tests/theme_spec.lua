local function load()
    WowStub.reset()
    return WowStub.loadFiles({ "UI/Theme.lua", "UI/Pixel.lua", "UI/Skin.lua" })
end

describe("Theme", function()
    local Theme

    before_each(function()
        Theme = load().Theme
    end)

    describe("Hex", function()
        it("reads RRGGBB with or without the hash", function()
            assert.are.same({ 1, 0, 0, 1 }, Theme.Hex("#FF0000"))
            assert.are.same({ 0, 1, 0, 1 }, Theme.Hex("00ff00"))
        end)

        it("keeps the alpha it is given", function()
            assert.are.equal(0.5, Theme.Hex("FFFFFF", 0.5)[4])
        end)

        it("returns nil for text that is not a color", function()
            assert.is_nil(Theme.Hex("red"))
            assert.is_nil(Theme.Hex("#12345"))
        end)
    end)

    describe("Color", function()
        it("returns the channels of a token", function()
            local red, green, blue, alpha = Theme.Color("accent")
            assert.is_near(0x3F / 255, red, 0.001)
            assert.is_near(0xA7 / 255, green, 0.001)
            assert.is_near(1, blue, 0.001)
            assert.are.equal(1, alpha)
        end)

        it("replaces the alpha when one is given", function()
            local _, _, _, alpha = Theme.Color("danger", 0.14)
            assert.are.equal(0.14, alpha)
        end)

        it("reads an unknown token as the text color", function()
            assert.are.same({ Theme.Color("text") }, { Theme.Color("nonsense") })
        end)
    end)

    describe("Code", function()
        it("writes an inline color escape", function()
            assert.are.equal("|cff3fa7ff", Theme.Code("accent"))
        end)
    end)

    describe("StatusColor", function()
        it("maps status words to tokens and unknown words to muted", function()
            assert.are.equal("success", Theme.StatusColor("owned"))
            assert.are.equal("danger", Theme.StatusColor("missing"))
            assert.are.equal("muted", Theme.StatusColor("whatever"))
        end)
    end)

    describe("Icon", function()
        it("returns the media path of a known icon only", function()
            assert.is_truthy(Theme.Icon("close"):find("Media\\Icons\\close", 1, true))
            assert.is_nil(Theme.Icon("nope"))
        end)
    end)

    describe("Font", function()
        it("makes one font object per size and weight", function()
            local first = Theme.Font(13, "regular")
            assert.are.equal(first, Theme.Font(13, "regular"))
            assert.are_not.equal(first, Theme.Font(13, "semibold"))
            assert.is_truthy(first.file:find("FiraSans-Regular.ttf", 1, true))
        end)

        it("treats an unknown weight as regular", function()
            assert.is_truthy(Theme.Font(12, "heavy").file:find("FiraSans-Regular.ttf", 1, true))
        end)

        it("falls back to the game font when the file cannot be loaded", function()
            WowStub.fontFailure = true
            assert.are.equal(STANDARD_TEXT_FONT, Theme.Font(17, "medium").file)
        end)
    end)
end)

describe("Pixel", function()
    local Pixel

    before_each(function()
        Pixel = load().Pixel
    end)

    describe("Snap", function()
        it("rounds to a whole multiple of the pixel", function()
            assert.are.equal(1.5, Pixel.Snap(1.4, 0.5))
            assert.are.equal(2, Pixel.Snap(2.2, 1))
        end)

        it("never rounds a positive line to nothing", function()
            assert.are.equal(1, Pixel.Snap(0.2, 1))
        end)

        it("returns the value when the pixel is unusable", function()
            assert.are.equal(3.3, Pixel.Snap(3.3, 0))
            assert.are.equal(3.3, Pixel.Snap(3.3, nil))
        end)
    end)

    describe("Size", function()
        after_each(function()
            WowStub.screenHeight = 1080
        end)

        it("is 768 over the screen height at scale 1", function()
            WowStub.screenHeight = 768
            assert.are.equal(1, Pixel.Size(CreateFrame("Frame")))
            WowStub.screenHeight = 1536
            assert.are.equal(0.5, Pixel.Size(CreateFrame("Frame")))
        end)

        it("divides by the effective scale of the frame", function()
            WowStub.screenHeight = 768
            local frame = CreateFrame("Frame")
            frame.GetEffectiveScale = function()
                return 2
            end
            assert.are.equal(0.5, Pixel.Size(frame))
        end)

        it("is 1 when the client cannot report the screen", function()
            local original = _G.GetPhysicalScreenSize
            _G.GetPhysicalScreenSize = nil
            assert.are.equal(1, Pixel.Size(CreateFrame("Frame")))
            _G.GetPhysicalScreenSize = function()
                error("no screen")
            end
            assert.are.equal(1, Pixel.Size(CreateFrame("Frame")))
            _G.GetPhysicalScreenSize = original
        end)
    end)

    describe("Border", function()
        it("draws four edges in the token color and recolors them", function()
            local border = Pixel.Border(CreateFrame("Frame"), "accent")
            assert.are.equal(4, #border.textures)
            assert.is_near(0x3F / 255, border.textures[1].colorTexture[1], 0.001)
            border:SetColor(1, 0, 0, 0.5)
            assert.are.same({ 1, 0, 0, 0.5 }, border.textures[4].colorTexture)
            border:SetColor({ 0, 1, 0 })
            assert.are.same({ 0, 1, 0, 1 }, border.textures[2].colorTexture)
        end)

        it("hides and shows every edge", function()
            local border = Pixel.Border(CreateFrame("Frame"))
            border:SetShown(false)
            assert.is_false(border.textures[3].shown)
            border:SetShown(true)
            assert.is_true(border.textures[3].shown)
        end)
    end)
end)

describe("Skin", function()
    local Skin

    before_each(function()
        Skin = load().Skin
    end)

    describe("buttonStyle", function()
        it("is a bordered control fill at rest", function()
            local style = Skin.buttonStyle("secondary", {})
            assert.are.equal("control", style.fill)
            assert.is_true(style.border)
            assert.are.equal("text", style.text)
            assert.is_nil(style.wash)
        end)

        it("washes on hover", function()
            assert.are.same({ "hover" }, Skin.buttonStyle("secondary", { hover = true }).wash)
        end)

        it("shows the selected wash, accent text and underline when active", function()
            local style = Skin.buttonStyle("secondary", { active = true })
            assert.are.same({ "selected" }, style.wash)
            assert.are.equal("accent", style.text)
            assert.is_true(style.underline)
        end)

        it("dims a disabled button and ignores hover", function()
            local style = Skin.buttonStyle("secondary", { disabled = true, hover = true })
            assert.are.equal("muted", style.text)
            assert.is_nil(style.wash)
        end)

        it("fills a primary button with the accent and drops its border", function()
            local style = Skin.buttonStyle("primary", {})
            assert.are.equal("accent", style.fill)
            assert.is_false(style.border)
            assert.are.equal("onAccent", style.text)
            assert.are.equal("control", Skin.buttonStyle("primary", { disabled = true }).fill)
        end)

        it("has no fill on a ghost button and tints its hover", function()
            local style = Skin.buttonStyle("ghost", { hover = true, hoverToken = "danger" })
            assert.is_nil(style.fill)
            assert.are.same({ "danger", 0.14 }, style.wash)
            assert.are.equal("danger", style.text)
        end)
    end)

    describe("button", function()
        it("repaints on hover, active and disabled", function()
            local button = CreateFrame("Button")
            Skin.button(button, "secondary")
            local state = button.skin
            WowStub.fireHooks(button, "OnEnter")
            assert.is_true(state.hover)
            assert.are.equal(0.06, state.wash.colorTexture[4])
            WowStub.fireHooks(button, "OnLeave")
            assert.are.equal(0, state.wash.colorTexture[4])
            Skin.setActive(button, true)
            assert.is_true(state.underline.shown)
            Skin.setActive(button, false)
            assert.is_false(state.underline.shown)
            Skin.setEnabled(button, false)
            assert.is_false(button.enabled)
            assert.is_near(0.5, state.label.textColor[4], 0.001)
            Skin.setEnabled(button, true)
            assert.is_true(button.enabled)
        end)

        it("adds a centered icon that follows the text color", function()
            local button = CreateFrame("Button")
            Skin.button(button, "ghost")
            local icon = Skin.buttonIcon(button, "close", 12)
            assert.is_truthy(icon.texture:find("close", 1, true))
            WowStub.fireHooks(button, "OnEnter")
            assert.is_near(0xF3 / 255, icon.vertexColor[1], 0.001)
        end)
    end)

    describe("fill and card", function()
        it("reuses one background texture and borders a card", function()
            local frame = CreateFrame("Frame")
            local fill = Skin.fill(frame, "panel")
            assert.are.equal(fill, Skin.fill(frame, "bg"))
            local border = Skin.card(CreateFrame("Frame"))
            assert.are.equal(4, #border.textures)
        end)
    end)

    describe("icon", function()
        it("tints a known icon and hides the texture for an unknown one", function()
            local texture = CreateFrame("Frame"):CreateTexture()
            assert.is_true(Skin.icon(texture, "check", "success"))
            assert.is_truthy(texture.texture:find("check", 1, true))
            assert.is_false(Skin.icon(texture, "nope"))
            assert.is_false(texture.shown)
        end)
    end)

    describe("sectionLabel", function()
        it("uppercases the text", function()
            local label = Skin.label(CreateFrame("Frame"), 12, "regular", "dim")
            Skin.sectionLabel(label, "Class")
            assert.are.equal("CLASS", label.text)
        end)
    end)
end)
