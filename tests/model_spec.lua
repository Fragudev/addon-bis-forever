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
    _G.ForeverBiSData = WowStub.wrapSource(data)
    WowStub.loadFiles({ "ForeverBiS_Model.lua" })
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

        it("builds a list only when it is first read and keeps its routes enumerable", function()
            load(fixture())
            local model = _G.ForeverBiSModel
            local realList, calls = model.list, 0
            model.list = function(...)
                calls = calls + 1
                return realList(...)
            end
            ForeverBiSModel.buildLegacy()
            assert.are.equal(0, calls)
            local routes = {}
            for route in pairs(ForeverBiSLists) do
                routes[#routes + 1] = route
            end
            table.sort(routes)
            assert.are.same({ "druid", "mage" }, routes)
            assert.are.equal("Feral at 60", ForeverBiSLists.druid.title)
            assert.are.equal("Feral at 60", ForeverBiSLists.druid.title)
            assert.are.equal(1, calls)
            model.list = realList
        end)

        it("lists the routes of the active source that have a list", function()
            load(fixture())
            assert.are.same({ "druid", "mage" }, ForeverBiSModel.routes())
        end)

        it("rebuilds on demand", function()
            load(fixture())
            _G.ForeverBiSData.sources.leveling.lists.druid.label = "Changed"
            ForeverBiSModel.buildLegacy()
            assert.are.equal("Changed", ForeverBiSBuildLabels.druid)
        end)
    end)

    describe("bracketForLevel", function()
        local function routeWith(phases)
            local data = { schema = 2, phases = {}, lists = { druid = { phases = {} } } }
            for _, phase in ipairs(phases) do
                table.insert(data.phases, phase)
                data.lists.druid.phases[phase.id] = { title = phase.id, slots = {} }
            end
            load(data)
        end

        local brackets = {
            { id = "lvl20", label = "Level 20", level = 20 },
            { id = "lvl40", label = "Level 40", level = 40 },
            { id = "lvl60", label = "Level 60", level = 60 },
        }

        it("picks the highest numeric phase at or below the level", function()
            routeWith(brackets)
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", 20))
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", 39))
            assert.are.equal("lvl40", ForeverBiSModel.bracketForLevel("druid", 40))
            assert.are.equal("lvl60", ForeverBiSModel.bracketForLevel("druid", 60))
        end)

        it("uses the lowest numeric phase below every bracket", function()
            routeWith(brackets)
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", 12))
        end)

        it("uses the lowest bracket for an invalid level and the default phase without numeric phases", function()
            routeWith(brackets)
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", nil))
            routeWith({ { id = "current", label = "Current" } })
            assert.are.equal("current", ForeverBiSModel.bracketForLevel("druid", 30))
            assert.is_nil(ForeverBiSModel.bracketForLevel("nobody", 30))
        end)
    end)

    describe("saved phase resolution", function()
        it("keeps a saved phase the route has and drops any other", function()
            load(fixture())
            assert.are.equal("lvl60", ForeverBiSModel.availablePhase("druid", "lvl60"))
            assert.is_nil(ForeverBiSModel.availablePhase("druid", "lvl99"))
            assert.is_nil(ForeverBiSModel.availablePhase("druid", nil))
            assert.is_nil(ForeverBiSModel.availablePhase("druid", 30))
            assert.is_nil(ForeverBiSModel.availablePhase("nope", "lvl30"))
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

    describe("bisEntries", function()
        local function slotOf(data, route, phase, index)
            return data.lists[route].phases[phase].slots[index]
        end

        it("matches by item id with route, class, phase, slot, rank and build label", function()
            load(fixture())
            assert.are.same({
                {
                    route = "druid",
                    class = "druid",
                    phase = "lvl30",
                    phaseLabel = "Level 30",
                    slot = "Head",
                    rank = 1,
                    label = "Feral PvE",
                    source = { kind = "profession", text = "Leatherworking (100)" },
                },
            }, ForeverBiSModel.bisEntries(11))
        end)

        it("leaves the source out for rows without a source table", function()
            local data = fixture()
            data.lists.druid.phases.lvl30.slots[1].items[1].source = "Leatherworking"
            load(data)
            assert.is_nil(ForeverBiSModel.bisEntries(11)[1].source)
        end)

        it("derives the class key from the first route segment", function()
            local data = fixture()
            data.lists["druid/tank"] = { label = "Bear Tank", phases = { lvl30 = data.lists.druid.phases.lvl30 } }
            load(data)
            local entries = ForeverBiSModel.bisEntries(11)
            assert.are.equal(2, #entries)
            assert.are.equal("druid", entries[1].class)
            assert.are.equal("druid/tank", entries[2].route)
            assert.are.equal("druid", entries[2].class)
            assert.are.equal("Bear Tank", entries[2].label)
        end)

        it("falls back to the exact name only for rows without an id", function()
            load(fixture())
            assert.are.equal(2, ForeverBiSModel.bisEntries(nil, "Cap")[1].rank)
            assert.are.equal(2, ForeverBiSModel.bisEntries(99999, "Cap")[1].rank)
            assert.are.same({}, ForeverBiSModel.bisEntries(nil, "cap"))
            assert.are.same({}, ForeverBiSModel.bisEntries(nil, "Hood")) -- Hood has an id in the data
            assert.are.same({}, ForeverBiSModel.bisEntries(99999, "Hood"))
        end)

        it("reports an item once per slot list even when it is repeated", function()
            local data = fixture()
            local items = slotOf(data, "druid", "lvl30", 1).items
            items[#items + 1] = { id = 11, name = "Hood", source = { text = "Again" } }
            items[#items + 1] = { name = "Cap", source = { text = "Again" } }
            load(data)
            assert.are.equal(1, #ForeverBiSModel.bisEntries(11))
            assert.are.equal(1, #ForeverBiSModel.bisEntries(nil, "Cap"))
        end)

        it("lists every phase, slot and build that carries the item", function()
            local data = fixture()
            data.lists.druid.phases.lvl60.slots[2] = {
                slot = "Neck",
                items = { { id = 5, name = "Other" }, { id = 11, name = "Hood" } },
            }
            data.lists.mage.phases.current.slots[1] = { slot = "Head", items = { { id = 11, name = "Hood" } } }
            load(data)
            local entries = ForeverBiSModel.bisEntries(11)
            assert.are.equal(3, #entries)
            assert.are.same(
                { "druid", "lvl30", "Head", 1 },
                { entries[1].route, entries[1].phase, entries[1].slot, entries[1].rank }
            )
            assert.are.same(
                { "druid", "lvl60", "Neck", 2 },
                { entries[2].route, entries[2].phase, entries[2].slot, entries[2].rank }
            )
            assert.are.same(
                { "mage", "current", "Head", 1 },
                { entries[3].route, entries[3].phase, entries[3].slot, entries[3].rank }
            )
            assert.are.equal("mage", entries[3].label) -- no label falls back to the route
        end)

        it("returns an empty list for unknown items, nil arguments and bad types", function()
            load(fixture())
            assert.are.same({}, ForeverBiSModel.bisEntries(424242))
            assert.are.same({}, ForeverBiSModel.bisEntries())
            assert.are.same({}, ForeverBiSModel.bisEntries(nil, nil))
            assert.are.same({}, ForeverBiSModel.bisEntries("11", {}))
        end)

        it("returns an empty list when the data is missing or of another schema", function()
            load(nil)
            assert.are.same({}, ForeverBiSModel.bisEntries(11, "Hood"))
            load("garbage")
            assert.are.same({}, ForeverBiSModel.bisEntries(11))
        end)

        it("never errors on malformed rows", function()
            load({
                schema = 2,
                phases = {},
                lists = {
                    druid = {
                        phases = {
                            a = {
                                slots = {
                                    "x",
                                    { slot = 5 },
                                    { slot = "Head", items = { "x", {}, { id = "7" }, { id = 7 } } },
                                },
                            },
                            b = "x",
                        },
                    },
                },
            })
            local entries = ForeverBiSModel.bisEntries(7)
            assert.are.equal(1, #entries)
            assert.are.equal(4, entries[1].rank)
            assert.are.same({}, ForeverBiSModel.bisEntries(nil, "7"))
        end)

        it("returns copies so callers cannot corrupt the cached index", function()
            load(fixture())
            ForeverBiSModel.bisEntries(11)[1].rank = 99
            assert.are.equal(1, ForeverBiSModel.bisEntries(11)[1].rank)
        end)

        it("rebuilds the index when the legacy data is rebuilt", function()
            load(fixture())
            assert.are.equal(1, #ForeverBiSModel.bisEntries(11))
            _G.ForeverBiSData.sources.leveling.lists.druid.phases.lvl30.slots[1].items[1].id = 77
            ForeverBiSModel.buildLegacy()
            assert.are.same({}, ForeverBiSModel.bisEntries(11))
            assert.are.equal(1, #ForeverBiSModel.bisEntries(77))
        end)
    end)

    describe("bracketForLevel", function()
        local function brackets()
            local data = fixture()
            data.phases = {
                { id = "lvl20", label = "Level 20", level = 20 },
                { id = "lvl30", label = "Level 30", level = 30 },
                { id = "lvl60", label = "Level 60", level = 60 },
            }
            data.lists.druid.phases.lvl20 = { title = "Feral at 20", slots = {} }
            return data
        end

        it("picks the highest bracket at or below the level", function()
            load(brackets())
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", 20))
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", 29))
            assert.are.equal("lvl30", ForeverBiSModel.bracketForLevel("druid", 30))
            assert.are.equal("lvl30", ForeverBiSModel.bracketForLevel("druid", 59))
            assert.are.equal("lvl60", ForeverBiSModel.bracketForLevel("druid", 60))
        end)

        it("uses the lowest bracket below every bracket or without a level", function()
            load(brackets())
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", 1))
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", nil))
            assert.are.equal("lvl20", ForeverBiSModel.bracketForLevel("druid", "x"))
        end)

        it("falls back to the default phase without numeric brackets, and nil for an unknown route", function()
            load(fixture())
            assert.are.equal("current", ForeverBiSModel.bracketForLevel("mage", 30))
            assert.is_nil(ForeverBiSModel.bracketForLevel("nobody", 30))
        end)
    end)

    describe("gridSlots", function()
        it("gives each slot of a phase its key and ranked items with id, name and source", function()
            load(fixture())
            assert.are.same({
                {
                    slot = "Head",
                    key = "Head",
                    items = {
                        { id = 11, name = "Hood", source = "Leatherworking (100)" },
                        { name = "Cap", source = "Where it comes from" },
                    },
                },
                { slot = "Neck", key = "Neck", items = { { id = 12, name = "Amulet", source = "Quest: A" } } },
            }, ForeverBiSModel.gridSlots("druid", "lvl30"))
        end)

        it("keeps at most the limit of items per slot, 6 by default", function()
            local data = fixture()
            local items = {}
            for index = 1, 8 do
                items[index] = { id = 100 + index, name = "Item " .. index, source = { text = "" } }
            end
            data.lists.druid.phases.lvl30.slots[1].items = items
            load(data)
            assert.are.equal(6, #ForeverBiSModel.gridSlots("druid", "lvl30")[1].items)
            assert.are.equal(2, #ForeverBiSModel.gridSlots("druid", "lvl30", 2)[1].items)
        end)

        it("canonicalizes weapon slot keys and uses the default phase without one", function()
            local data = fixture()
            data.lists.druid.phases.lvl60.slots[1].slot = "Two-hand weapon"
            load(data)
            local rows = ForeverBiSModel.gridSlots("druid")
            assert.are.equal("Two-hand weapon", rows[1].slot)
            assert.are.equal("Main Hand", rows[1].key)
        end)

        it("is empty for an unknown route or phase and skips malformed rows", function()
            local data = fixture()
            data.lists.druid.phases.lvl30.slots[3] = { slot = 5 }
            data.lists.druid.phases.lvl30.slots[1].items[3] = { id = 7 }
            load(data)
            assert.are.same({}, ForeverBiSModel.gridSlots("nobody", "lvl30"))
            assert.are.same({}, ForeverBiSModel.gridSlots("druid", "lvl99"))
            local rows = ForeverBiSModel.gridSlots("druid", "lvl30")
            assert.are.equal(2, #rows)
            assert.are.equal(2, #rows[1].items)
        end)

        it("normalizes slot names to the equipment position they fill", function()
            load(fixture())
            assert.are.equal("Main Hand", ForeverBiSModel.slotKey("Two-hand weapon"))
            assert.are.equal("Off Hand", ForeverBiSModel.slotKey("Off hand: shield"))
            assert.are.equal("Tabard", ForeverBiSModel.slotKey("Tabard"))
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

    describe("sources", function()
        local TwoSources = dofile("tests/support/sources.lua")

        local function loadSources(data)
            _G.ForeverBiSData = data or TwoSources.twoSources()
            WowStub.loadFiles({ "ForeverBiS_Model.lua" })
        end

        it("exposes the default source id", function()
            loadSources()
            assert.are.equal("leveling", ForeverBiSModel.DEFAULT_SOURCE)
        end)

        it("lists the sources ordered by `order`, then by id", function()
            local data = TwoSources.twoSources()
            data.sources.aaa = { label = "Tie", order = 2, phases = {}, lists = {} }
            data.sources.zzz = { phases = {}, lists = {} }
            loadSources(data)
            assert.are.same({
                { id = "alpha", label = "Alpha", url = "https://alpha.test" },
                { id = "aaa", label = "Tie" },
                { id = "beta", label = "Beta", url = "https://beta.test" },
                { id = "zzz", label = "zzz" },
            }, ForeverBiSModel.sources())
        end)

        it("returns no sources without data or with another schema", function()
            load(nil)
            assert.are.same({}, ForeverBiSModel.sources())
            assert.is_nil(ForeverBiSModel.activeSource())
        end)

        it("starts on the first available source when the default one is absent", function()
            loadSources()
            assert.are.equal("alpha", ForeverBiSModel.activeSource())
            assert.are.equal("Feral PvE", ForeverBiSBuildLabels.druid)
        end)

        it("starts on the default source when it exists", function()
            local data = TwoSources.twoSources()
            data.sources.leveling = data.sources.beta
            data.sources.beta = nil
            loadSources(data)
            assert.are.equal("leveling", ForeverBiSModel.activeSource())
        end)

        it("tolerates an empty source", function()
            local data = TwoSources.twoSources()
            data.sources.empty = { label = "Empty", order = 3, phases = {}, lists = {} }
            loadSources(data)
            assert.is_true(ForeverBiSModel.select("empty"))
            assert.are.same({}, ForeverBiSLists)
            assert.are.same({}, ForeverBiSModel.phases("rogue"))
            assert.are.same({}, ForeverBiSModel.bisEntries(11))
        end)

        describe("select", function()
            it("makes the source active and rebuilds the legacy globals", function()
                loadSources()
                assert.is_table(ForeverBiSLists.druid)
                assert.is_true(ForeverBiSModel.select("beta"))
                assert.are.equal("beta", ForeverBiSModel.activeSource())
                assert.is_nil(ForeverBiSLists.druid)
                assert.are.equal("Beta Rogue", ForeverBiSBuildLabels.rogue)
                assert.are.equal(21, ForeverBiSItemIDs["Beta Mask"])
                assert.is_nil(ForeverBiSItemIDs["Alpha Mask"])
                assert.are.same({ { id = "raid1", label = "Raid 1" } }, ForeverBiSModel.phases("rogue"))
            end)

            it("resets the reverse index", function()
                loadSources()
                assert.are.equal(1, #ForeverBiSModel.bisEntries(13))
                ForeverBiSModel.select("beta")
                assert.are.same({}, ForeverBiSModel.bisEntries(13))
                assert.are.equal("raid1", ForeverBiSModel.bisEntries(21)[1].phase)
                ForeverBiSModel.select("alpha")
                assert.are.same({}, ForeverBiSModel.bisEntries(21))
            end)

            it("returns false and changes nothing for an unknown source", function()
                loadSources()
                local lists = ForeverBiSLists
                assert.is_false(ForeverBiSModel.select("nope"))
                assert.is_false(ForeverBiSModel.select(nil))
                assert.is_false(ForeverBiSModel.select(5))
                assert.are.equal("alpha", ForeverBiSModel.activeSource())
                assert.are.equal(lists, ForeverBiSLists)
            end)
        end)
    end)
end)
