local function loadLists(withoutData)
    WowStub.reset()
    WowStub.loadFiles({
        "ForeverBiS_Data_ForeverChanges.lua",
        "ForeverBiS_Data_Wowsims.lua",
        "ForeverBiS_Model.lua",
        "Core/Sources.lua",
        "Core/Lists.lua",
    })
    if withoutData then
        _G.ForeverBiSData, _G.ForeverBiSLists = nil, nil
    end
    return WowStub.ns.Lists
end

describe("Lists", function()
    it("resolves the selected phase's data for a route", function()
        local Lists = loadLists()
        local phaseId = ForeverBiSModel.effectivePhase("rogue", nil, 30)
        assert.are.same(ForeverBiSModel.list("rogue", phaseId), Lists.resolve("rogue", phaseId))
    end)

    it("falls back to the legacy list when no phase is given", function()
        local Lists = loadLists()
        assert.are.equal(ForeverBiSLists["rogue"], Lists.resolve("rogue", nil))
    end)

    it("resolves nothing without a route or for an unknown one", function()
        local Lists = loadLists()
        assert.is_nil(Lists.resolve(nil, nil))
        assert.is_nil(Lists.resolve("not-a-route", nil))
    end)

    it("indexes the slots of a view by slot key", function()
        local Lists = loadLists()
        local phaseId = ForeverBiSModel.effectivePhase("rogue", nil, 30)
        local view = Lists.view("rogue", phaseId)
        local slot = view.data.slots[1]
        local key = WowStub.ns.Sources.normalizeSlotName(slot[1])
        assert.are.equal(slot[2], view.ranked[key])
        assert.are.equal(slot[2][1], view.best[key])
        assert.are.equal(slot[1], view.headings[key])
        assert.are.equal("rogue", view.route)
    end)

    it("builds an empty view without data", function()
        local Lists = loadLists(true)
        local view = Lists.view("rogue", nil)
        assert.is_nil(view.data)
        assert.are.same({}, view.ranked)
    end)

    describe("rankOf", function()
        local ids = { ["A"] = 1, ["B"] = 2, ["C"] = 3 }
        local function idOf(name)
            return ids[name]
        end
        local items = { { "A", "x" }, { "B", "y" }, { "C", "z" } }

        it("returns the position of the item in the slot's list", function()
            local Lists = loadLists()
            assert.are.equal(1, Lists.rankOf(items, 1, idOf))
            assert.are.equal(3, Lists.rankOf(items, 3, idOf))
        end)

        it("returns nil when the slot does not list the item", function()
            local Lists = loadLists()
            assert.is_nil(Lists.rankOf(items, 99, idOf))
            assert.is_nil(Lists.rankOf({}, 1, idOf))
        end)
    end)

    describe("view", function()
        local TwoSources = dofile("tests/support/sources.lua")

        local function loadTwoSources()
            WowStub.reset()
            _G.ForeverBiSData = TwoSources.twoSources()
            WowStub.loadFiles({ "ForeverBiS_Model.lua", "Core/Sources.lua", "Core/Lists.lua" })
            return WowStub.ns.Lists
        end

        it("indexes the slots of a route the active source has", function()
            local Lists = loadTwoSources()
            local view = Lists.view("druid", "lvl30")
            assert.is_false(view.missing)
            assert.are.equal("Alpha Hood", view.best["Head"][1])
        end)

        it("returns an empty view flagged as missing when the active source lacks the route", function()
            local Lists = loadTwoSources()
            ForeverBiSModel.select("beta")
            local view
            assert.has_no.errors(function()
                view = Lists.view("druid", "lvl30")
            end)
            assert.is_true(view.missing)
            assert.is_nil(view.data)
            assert.are.same({}, view.ranked)
            assert.are.same({}, view.best)
            assert.are.equal("druid", view.route)
        end)

        it("does not flag a missing view when there is no route at all", function()
            local Lists = loadTwoSources()
            assert.is_false(Lists.view(nil).missing)
        end)
    end)
end)
