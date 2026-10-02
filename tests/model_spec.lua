-- ForeverBiSModel against a tiny inline fixture (the bundled data is covered by data_spec).
local function fixture()
    return {
        schema = 2,
        phases = {
            { id = "lvl30", label = "Level 30", level = 30 },
            { id = "lvl60", label = "Level 60", level = 60 },
        },
        lists = {
            ["druid"] = {
                label = "Feral PvE",
                phases = {
                    lvl30 = {
                        title = "Feral at 30",
                        slots = {
                            {
                                slot = "Head",
                                items = {
                                    {
                                        id = 11,
                                        name = "Hood",
                                        source = { kind = "profession", text = "Leatherworking (100)" },
                                    },
                                    { name = "Cap", source = { kind = "unknown", text = "Where it comes from" } },
                                },
                            },
                            {
                                slot = "Neck",
                                items = { { id = 12, name = "Amulet", source = { kind = "quest", text = "Quest: A" } } },
                                enchants = {
                                    {
                                        effect = "Agility +5",
                                        spell = "Enchant Necklace",
                                        source = "Trainer",
                                        formulaId = 99,
                                    },
                                    { effect = "Stamina +1", spell = "Enchant Minor", source = "Trainer" },
                                },
                            },
                        },
                    },
                    lvl60 = {
                        title = "Feral at 60",
                        slots = {
                            { slot = "Head", items = { { id = 21, name = "Crown", source = { text = "Raid" } } } },
                        },
                    },
                },
            },
            ["mage"] = {
                phases = { current = { title = "Mage", slots = {} } },
            },
        },
    }
end

-- Chunks from loadfile run in the real _G, while busted sandboxes the spec's own globals: write through _G.
local function load(data)
    _G.ForeverBiSData = data
    assert(loadfile("ForeverBiS/ForeverBiS_Model.lua"))()
end

describe("ForeverBiSModel", function()
    after_each(function()
        _G.ForeverBiSData = nil
        _G.ForeverBiSModel, _G.ForeverBiSLists, _G.ForeverBiSItemIDs, _G.ForeverBiSBuildLabels = nil, nil, nil, nil
    end)

    describe("phases", function()
        it("lists the phases a route has data for, oldest first", function()
            load(fixture())
            local ids = {}
            for _, phase in ipairs(ForeverBiSModel.phases("druid")) do
                ids[#ids + 1] = phase.id
            end
            assert.are.same({ "lvl30", "lvl60" }, ids)
        end)

        it("skips declared phases the route does not have", function()
            local data = fixture()
            data.lists.druid.phases.lvl60 = nil
            load(data)
            assert.are.equal(1, #ForeverBiSModel.phases("druid"))
        end)

        it("appends phases missing from the global list sorted by id", function()
            local data = fixture()
            data.lists.druid.phases.zeta = { title = "z", slots = {} }
            data.lists.druid.phases.alpha = { title = "a", slots = {} }
            load(data)
            local ids = {}
            for _, phase in ipairs(ForeverBiSModel.phases("druid")) do
                ids[#ids + 1] = phase.id
            end
            assert.are.same({ "lvl30", "lvl60", "alpha", "zeta" }, ids)
        end)

        it("ignores malformed phase declarations and duplicates", function()
            local data = fixture()
            table.insert(data.phases, "junk")
            table.insert(data.phases, { id = "lvl30", label = "again" })
            table.insert(data.phases, { label = "no id" })
            load(data)
            assert.are.equal(2, #ForeverBiSModel.phases("druid"))
        end)

        it("returns an empty list for an unknown route", function()
            load(fixture())
            assert.are.same({}, ForeverBiSModel.phases("nope"))
        end)
    end)

    describe("defaultPhase", function()
        it("picks the latest available phase", function()
            load(fixture())
            assert.are.equal("lvl60", ForeverBiSModel.defaultPhase("druid"))
            assert.are.equal("current", ForeverBiSModel.defaultPhase("mage"))
        end)

        it("is nil for an unknown route", function()
            load(fixture())
            assert.is_nil(ForeverBiSModel.defaultPhase("nope"))
        end)
    end)

    describe("list", function()
        it("returns the legacy shape with enchants as the third slot element", function()
            load(fixture())
            local list = ForeverBiSModel.list("druid", "lvl30")
            assert.are.equal("Feral at 30", list.title)
            assert.are.same({
                { "Head", { { "Hood", "Leatherworking (100)" }, { "Cap", "Where it comes from" } } },
                {
                    "Neck",
                    { { "Amulet", "Quest: A" } },
                    {
                        { "Agility +5", "Enchant Necklace", "Trainer", 99 },
                        { "Stamina +1", "Enchant Minor", "Trainer" },
                    },
                },
            }, list.slots)
        end)

        it("uses the latest phase when none is given", function()
            load(fixture())
            assert.are.equal("Feral at 60", ForeverBiSModel.list("druid").title)
        end)

        it("is nil for a missing route or phase", function()
            load(fixture())
            assert.is_nil(ForeverBiSModel.list("nope"))
            assert.is_nil(ForeverBiSModel.list("druid", "lvl99"))
        end)

        it("skips malformed slots, items and enchants", function()
            local data = fixture()
            local slots = data.lists.druid.phases.lvl30.slots
            table.insert(slots, "junk")
            table.insert(slots, { items = {} })
            table.insert(
                slots,
                { slot = "Back", items = { "junk", { id = 1 }, { name = "Cloak" } }, enchants = { "x", {} } }
            )
            load(data)
            local back = ForeverBiSModel.list("druid", "lvl30").slots[3]
            assert.are.same({ "Back", { { "Cloak", "" } } }, back)
        end)

        it("tolerates a slot without an items table", function()
            local data = fixture()
            table.insert(data.lists.druid.phases.lvl30.slots, { slot = "Back" })
            load(data)
            assert.are.same({ "Back", {} }, ForeverBiSModel.list("druid", "lvl30").slots[3])
        end)
    end)

    describe("legacy globals", function()
        it("builds the lists from the default phase", function()
            load(fixture())
            assert.are.equal("Feral at 60", ForeverBiSLists.druid.title)
            assert.are.equal("Mage", ForeverBiSLists.mage.title)
        end)

        it("collects item ids from every phase", function()
            load(fixture())
            assert.are.same({ Hood = 11, Amulet = 12, Crown = 21 }, ForeverBiSItemIDs)
        end)

        it("collects build labels only for routes that have one", function()
            load(fixture())
            assert.are.same({ druid = "Feral PvE" }, ForeverBiSBuildLabels)
            assert.is_nil(ForeverBiSModel.label("mage"))
        end)

        it("rebuilds on demand", function()
            load(fixture())
            _G.ForeverBiSData.lists.druid.label = "Changed"
            ForeverBiSModel.buildLegacy()
            assert.are.equal("Changed", ForeverBiSBuildLabels.druid)
        end)
    end)

    describe("defensive loading", function()
        it("produces empty tables without data", function()
            load(nil)
            assert.are.same({}, ForeverBiSLists)
            assert.are.same({}, ForeverBiSItemIDs)
            assert.are.same({}, ForeverBiSBuildLabels)
            assert.are.same({}, ForeverBiSModel.phases("druid"))
            assert.is_nil(ForeverBiSModel.list("druid"))
        end)

        it("ignores data of another schema or of the wrong type", function()
            load("garbage")
            assert.are.same({}, ForeverBiSLists)
            local data = fixture()
            data.schema = 1
            load(data)
            assert.are.same({}, ForeverBiSLists)
        end)

        it("survives malformed lists, phases and routes", function()
            load({ schema = 2, phases = "x", lists = { druid = "x", [5] = {}, mage = { phases = "y", label = 7 } } })
            assert.are.same({}, ForeverBiSLists)
            assert.are.same({}, ForeverBiSBuildLabels)
        end)
    end)

    it("does not read the saved variables", function()
        _G.ForeverBiSDB = setmetatable({}, {
            __index = function()
                error("ForeverBiSDB was read")
            end,
        })
        load(fixture())
        _G.ForeverBiSDB = nil
        assert.is_table(ForeverBiSLists)
    end)
end)
