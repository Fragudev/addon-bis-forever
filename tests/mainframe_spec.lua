describe("Main window header", function()
    after_each(function()
        _G.C_AddOns, _G.GetAddOnMetadata = nil, nil
    end)

    it("shows the title and the version from the .toc", function()
        _G.C_AddOns = {
            GetAddOnMetadata = function(addon, field)
                assert.are.equal("ForeverBiS", addon)
                assert.are.equal("Version", field)
                return "beta-9.9.9"
            end,
        }
        WowStub.load(nil)
        assert.is_true(WowStub.hasText("BiS Forever"))
        assert.is_true(WowStub.hasText("beta-9.9.9"))
    end)

    it("falls back to the older metadata function", function()
        _G.GetAddOnMetadata = function()
            return "beta-1.2.3"
        end
        WowStub.load(nil)
        assert.is_true(WowStub.hasText("beta-1.2.3"))
    end)

    it("leaves the badge out when the client has no metadata API or it fails", function()
        WowStub.load(nil)
        assert.is_false(WowStub.hasText("beta-"))
        _G.GetAddOnMetadata = function()
            error("unavailable")
        end
        assert.has_no.errors(function()
            WowStub.load(nil)
        end)
        assert.is_false(WowStub.hasText("beta-"))
    end)

    it("closes the window with the close button", function()
        WowStub.load(nil)
        ForeverBiSFrame:Show()
        local close = WowStub.find("Button", function(button)
            return button.skin and button.skin.hoverToken == "danger"
        end)[1]
        WowStub.fire(close, "OnClick")
        assert.is_false(ForeverBiSFrame:IsShown())
    end)

    it("moves the window from the header and closes an open dropdown when it hides", function()
        WowStub.load(nil)
        ForeverBiSFrame:Show()
        local moved = {}
        local window = _G.ForeverBiSFrame
        window.StartMoving = function()
            table.insert(moved, "start")
        end
        window.StopMovingOrSizing = function()
            table.insert(moved, "stop")
        end
        local header = window.children[1]
        WowStub.fire(header, "OnMouseDown")
        WowStub.fire(header, "OnMouseUp")
        assert.are.same({ "start", "stop" }, moved)

        WowStub.fire(ForeverBiSClassDropDown, "OnClick")
        assert.is_true(ForeverBiSDropdownList:IsShown())
        ForeverBiSFrame:Hide()
        assert.is_false(ForeverBiSDropdownList:IsShown())
    end)
end)
