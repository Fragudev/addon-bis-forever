local function load(items)
    WowStub.reset()
    _G.ForeverBiSItemIDs = items or {}
    return WowStub.loadFiles({ "Adapters/Items.lua", "Adapters/Inventory.lua", "Adapters/Player.lua" })
end

describe("Adapters", function()
    local qualityColors, requestLoad = _G.ITEM_QUALITY_COLORS, _G.C_Item.RequestLoadItemDataByID

    after_each(function()
        _G.ForeverBiSItemIDs = nil
        _G.ITEM_QUALITY_COLORS = qualityColors
        _G.C_Item.RequestLoadItemDataByID = requestLoad
        _G.C_Item.GetItemInfoInstant = function() end
        _G.C_Item.GetItemIconByID = function() end
        _G.C_Item.GetItemQualityByID = function() end
        _G.GetItemInfo = function() end
        _G.GetItemIcon = function() end
    end)

    describe("Items", function()
        it("prefers the bundled id over the client", function()
            local ns = load({ ["Cape"] = 5193 })
            _G.C_Item.GetItemInfoInstant = function()
                return 1
            end
            assert.are.equal(5193, ns.Items.id("Cape"))
        end)

        it("asks the client for an unknown name and tracks the answer", function()
            local ns = load()
            _G.C_Item.GetItemInfoInstant = function(name)
                return name == "Mystery" and 777 or nil
            end
            assert.are.equal(777, ns.Items.id("Mystery"))
            assert.is_true(ns.Items.isTracked(777))
            assert.is_nil(ns.Items.id("Nothing"))
        end)

        it("tracks the bundled ids from the start", function()
            local ns = load({ ["Cape"] = 5193 })
            assert.is_true(ns.Items.isTracked(5193))
            assert.is_false(ns.Items.isTracked(1))
        end)

        it("requests item data once per id", function()
            local ns = load({ ["Cape"] = 5193 })
            local requests = 0
            _G.C_Item.RequestLoadItemDataByID = function()
                requests = requests + 1
            end
            ns.Items.icon("Cape")
            ns.Items.icon("Cape")
            assert.are.equal(1, requests)
        end)

        it("falls back through the icon sources to the question mark", function()
            local ns = load({ ["Cape"] = 5193 })
            assert.are.equal("Interface\\Icons\\INV_Misc_QuestionMark", ns.Items.icon("Cape"))
            _G.GetItemInfo = function()
                return nil, nil, nil, nil, nil, nil, nil, nil, nil, "from-info"
            end
            assert.are.equal("from-info", ns.Items.icon("Cape"))
            _G.GetItemIcon = function()
                return "from-icon"
            end
            assert.are.equal("from-icon", ns.Items.icon("Cape"))
            _G.C_Item.GetItemIconByID = function()
                return "from-c-item"
            end
            assert.are.equal("from-c-item", ns.Items.icon("Cape"))
        end)

        it("reads the quality color from the item link", function()
            local ns = load({ ["Cape"] = 5193 })
            _G.GetItemInfo = function()
                return "Cape", "|cff0070dd|Hitem:5193|h[Cape]|h|r", 3
            end
            local red, green, blue = ns.Items.qualityColor("Cape")
            assert.are.near(0, red, 0.001)
            assert.are.near(0x70 / 255, green, 0.001)
            assert.are.near(0xdd / 255, blue, 0.001)
        end)

        it("falls back to the rarity table, then to white", function()
            local ns = load({ ["Cape"] = 5193 })
            assert.are.same({ 1, 1, 1 }, { ns.Items.qualityColor("Cape") })
            _G.C_Item.GetItemQualityByID = function()
                return 4
            end
            _G.ITEM_QUALITY_COLORS = { [4] = { r = 0.6, g = 0.2, b = 0.9 } }
            assert.are.same({ 0.6, 0.2, 0.9 }, { ns.Items.qualityColor("Cape") })
        end)
    end)

    describe("Inventory", function()
        it("matches an item in either ring slot for the generic finger slot", function()
            local ns = load()
            WowStub.equipped[12] = 500
            assert.is_true(ns.Inventory.isEquippedInSlot(500, "Finger"))
            assert.is_true(ns.Inventory.isEquippedInSlot(500, "Finger 2"))
            assert.is_false(ns.Inventory.isEquippedInSlot(500, "Finger 1"))
        end)

        it("matches an item in either trinket slot for the generic trinket slot", function()
            local ns = load()
            WowStub.equipped[13] = 600
            assert.is_true(ns.Inventory.isEquippedInSlot(600, "trinket"))
            assert.is_true(ns.Inventory.isEquippedInSlot(600, "Trinket 1"))
            assert.is_false(ns.Inventory.isEquippedInSlot(600, "Trinket 2"))
        end)

        it("is false for unknown slots and missing ids", function()
            local ns = load()
            WowStub.equipped[1] = 700
            assert.is_false(ns.Inventory.isEquippedInSlot(700, "Tabard"))
            assert.is_false(ns.Inventory.isEquippedInSlot(nil, "Head"))
            assert.is_false(ns.Inventory.isEquippedInSlot(700, nil))
        end)

        it("counts copies in the bags", function()
            local ns = load()
            WowStub.bagCounts[800] = 3
            assert.are.equal(3, ns.Inventory.bagCount(800))
            assert.are.equal(0, ns.Inventory.bagCount(801))
            assert.are.equal(0, ns.Inventory.bagCount(nil))
        end)

        it("reads what is worn per slot key, including both rings", function()
            local ns = load()
            WowStub.equipped[1], WowStub.equipped[11], WowStub.equipped[12] = 10, 20, 21
            local owned = ns.Inventory.buildOwned({ "Head", "Finger", "Neck" })
            assert.are.same({ 10 }, owned.equipped["Head"])
            assert.are.same({ 20, 21 }, owned.equipped["Finger"])
            assert.are.same({}, owned.equipped["Neck"])
            assert.are.equal(ns.Inventory.bagCount, owned.bags)
            assert.are.equal(ns.Items.id, owned.itemId)
        end)
    end)

    describe("Player", function()
        it("reads level, faction and class token", function()
            local ns = load()
            WowStub.player = { class = "Druid", token = "DRUID", level = 12, faction = "Horde" }
            assert.are.equal(12, ns.Player.level())
            assert.are.equal("Horde", ns.Player.faction())
            assert.are.equal("DRUID", ns.Player.classToken())
        end)

        it("describes the character for the panel", function()
            local ns = load()
            WowStub.player = { class = "Druid", token = "DRUID", level = 12 }
            assert.are.same(
                { name = "Tester", realm = "Realm", className = "Druid", classToken = "DRUID", level = 12 },
                ns.Player.identity()
            )
        end)

        it("falls back when the client gives no name or realm", function()
            local ns = load()
            local fullName, name, realm = _G.UnitFullName, _G.UnitName, _G.GetRealmName
            _G.UnitFullName = function() end
            _G.UnitName = function() end
            _G.GetRealmName = function()
                return "Fallback"
            end
            local identity = ns.Player.identity()
            _G.UnitFullName, _G.UnitName, _G.GetRealmName = fullName, name, realm
            assert.are.equal("Player", identity.name)
            assert.are.equal("Fallback", identity.realm)
        end)
    end)
end)
