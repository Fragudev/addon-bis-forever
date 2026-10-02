local function firstSlotWithEnchants(listKey)
    for _, slot in ipairs(ForeverBiSLists[listKey].slots) do
        if slot[3] and #slot[3] > 0 then
            return slot
        end
    end
end

local function menuLabels()
    local labels = {}
    for _, info in ipairs(WowStub.menus) do
        table.insert(labels, info.text)
    end
    return labels
end

local function openMenu(dropdown)
    WowStub.menus = {}
    dropdown.initializer(dropdown, 1)
    return WowStub.menus
end

describe("ForeverBiS", function()
    describe("loading", function()
        it("registers the /bis and /foreverbis slash commands", function()
            WowStub.load(nil)
            assert.are.equal("/bis", _G.SLASH_FOREVERBIS1)
            assert.are.equal("/foreverbis", _G.SLASH_FOREVERBIS2)
            assert.is_function(_G.SlashCmdList["FOREVERBIS"])
        end)

        it("starts hidden and defaults to the rogue PvE list", function()
            WowStub.load(nil)
            assert.is_false(ForeverBiSFrame:IsShown())
            assert.are.equal("rogue", ForeverBiSDB.class)
            assert.are.equal("", ForeverBiSDB.build) -- the default build has an empty route suffix
        end)

        it("falls back to a valid class and build when the saved ones are unknown", function()
            WowStub.load({ class = "not-a-class", build = "not-a-build" })
            assert.are.equal("rogue", ForeverBiSDB.class)
            assert.are.equal("", ForeverBiSDB.build)
        end)

        it("keeps a valid saved class and build", function()
            WowStub.load({ class = "druid", build = "/tank" })
            assert.are.equal("druid", ForeverBiSDB.class)
            assert.are.equal("/tank", ForeverBiSDB.build)
        end)
    end)

    describe("slash command", function()
        it("toggles the main window", function()
            WowStub.load(nil)
            _G.SlashCmdList["FOREVERBIS"]()
            assert.is_true(ForeverBiSFrame:IsShown())
            _G.SlashCmdList["FOREVERBIS"]()
            assert.is_false(ForeverBiSFrame:IsShown())
        end)
    end)

    describe("rendering the list", function()
        it("shows the slot headers and the ranked items of the selected list", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local list = ForeverBiSLists["druid"]
            for _, slot in ipairs(list.slots) do
                assert.is_true(WowStub.hasText(string.upper(slot[1])), "missing header " .. slot[1])
                assert.is_true(WowStub.hasText(slot[2][1][1]), "missing top item of " .. slot[1])
            end
        end)

        it("shows an ENCHANTS block with the effect under a slot that has enchants", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local slot = assert(firstSlotWithEnchants("druid"), "druid data has no enchants")
            assert.is_true(WowStub.hasText("ENCHANTS"))
            assert.is_true(WowStub.hasText(slot[3][1][1]), "missing enchant effect " .. slot[3][1][1])
            assert.is_true(WowStub.hasText(slot[3][1][2]), "missing enchant spell " .. slot[3][1][2])
        end)

        it("hides the ENCHANTS block when no slot of the list has enchants", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            for _, list in pairs(ForeverBiSLists) do
                for _, slot in ipairs(list.slots) do
                    slot[3] = nil
                end
            end
            ForeverBiSFrame:Show()
            _G.SlashCmdList["FOREVERBIS"]() -- hide
            _G.SlashCmdList["FOREVERBIS"]() -- show and re-render
            assert.is_false(WowStub.hasText("ENCHANTS"))
        end)

        it("drops the items and enchants of a collapsed slot but keeps its header", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local slot = assert(firstSlotWithEnchants("druid"))
            WowStub.load({
                class = "druid",
                build = "feral-pve",
                collapsed = { ["druid:" .. slot[1]] = true },
            })
            assert.is_true(WowStub.hasText(string.upper(slot[1])))
            assert.is_false(WowStub.hasText(slot[2][1][1]))
            assert.is_false(WowStub.hasText(slot[3][1][1]))
        end)
    end)

    describe("selectors", function()
        it("lists every class in the class dropdown", function()
            WowStub.load(nil)
            local menu = openMenu(ForeverBiSClassDropDown)
            assert.is_true(#menu >= 9)
            local labels = menuLabels()
            for _, expected in ipairs({ "Rogue", "Druid", "Warrior", "Mage" }) do
                assert.is_truthy(table.concat(labels, ","):find(expected, 1, true), expected)
            end
        end)

        it("switches class and resets to its default build", function()
            WowStub.load({ class = "rogue", build = "pvp" })
            local menu = openMenu(ForeverBiSClassDropDown)
            for _, info in ipairs(menu) do
                if info.text == "Druid" then
                    info.func()
                end
            end
            assert.are.equal("druid", ForeverBiSDB.class)
            assert.is_true(WowStub.hasText(string.upper(ForeverBiSLists["druid"].slots[1][1])))
        end)

        it("switches build within the selected class", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local menu = openMenu(ForeverBiSBuildDropDown)
            assert.is_true(#menu > 1)
            for _, info in ipairs(menu) do
                if info.text == "Tank" then
                    info.func()
                end
            end
            assert.are.equal("/tank", ForeverBiSDB.build)
        end)
    end)

    describe("search", function()
        it("filters the items by name", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local slot = ForeverBiSLists["druid"].slots[1]
            local wanted = slot[2][1][1]
            local other = slot[2][#slot[2]][1]
            assert.are_not.equal(wanted, other)

            ForeverBiSFrame:Show()
            local searchBox
            for _, candidate in ipairs(WowStub.frames) do
                if candidate.scripts.OnTextChanged then
                    searchBox = candidate
                end
            end
            searchBox:SetText(string.lower(wanted))
            WowStub.fire(searchBox, "OnTextChanged")

            assert.is_true(WowStub.hasText(wanted))
            assert.is_false(WowStub.hasText(other))
        end)

        it("shows an empty message when nothing matches", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local searchBox
            for _, candidate in ipairs(WowStub.frames) do
                if candidate.scripts.OnTextChanged then
                    searchBox = candidate
                end
            end
            searchBox:SetText("zzzz-no-such-item")
            WowStub.fire(searchBox, "OnTextChanged")
            assert.is_true(WowStub.hasText("No items match"))
        end)
    end)

    describe("item events", function()
        local function itemWatcher()
            for _, candidate in ipairs(WowStub.frames) do
                if candidate.events.BAG_UPDATE then
                    return candidate
                end
            end
        end

        it("re-renders on bag changes only while the window is open", function()
            WowStub.load({ class = "druid", build = "feral-pve" })
            local watcher = assert(itemWatcher())

            local before = #WowStub.fontStrings
            WowStub.fire(watcher, "OnEvent", "BAG_UPDATE")
            assert.are.equal(before, #WowStub.fontStrings, "rendered while hidden")

            ForeverBiSFrame:Show()
            WowStub.fire(watcher, "OnEvent", "BAG_UPDATE")
            assert.is_true(#WowStub.fontStrings > before, "did not re-render while shown")
        end)
    end)

    describe("minimap button", function()
        it("toggles the window on click", function()
            WowStub.load(nil)
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_true(ForeverBiSFrame:IsShown())
        end)

        it("ignores the click that ends a drag", function()
            WowStub.load(nil)
            WowStub.fire(ForeverBiSMinimapButton, "OnDragStart")
            ForeverBiSMinimapButton.dragMoved = true
            WowStub.fire(ForeverBiSMinimapButton, "OnDragStop")
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_false(ForeverBiSFrame:IsShown())
            WowStub.fire(ForeverBiSMinimapButton, "OnClick")
            assert.is_true(ForeverBiSFrame:IsShown())
        end)

        it("is hidden when the saved settings say so", function()
            WowStub.load({ minimap = { hide = true } })
            assert.is_false(ForeverBiSMinimapButton:IsShown())
        end)
    end)
end)
