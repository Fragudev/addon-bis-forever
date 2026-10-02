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

    describe("phaseForLevel", function()
        local function routeWith(phases)
            local data = { schema = 2, phases = {}, lists = { druid = { phases = {} } } }
            for _, phase in ipairs(phases) do
                table.insert(data.phases, phase)
                data.lists.druid.phases[phase.id] = { title = phase.id, slots = {} }
            end
            load(data)
        end

        local threeLevels = {
            { id = "lvl30", label = "Level 30", level = 30 },
            { id = "lvl40", label = "Level 40", level = 40 },
            { id = "lvl50", label = "Level 50", level = 50 },
        }

        it("picks the smallest numeric phase at or above the level", function()
            routeWith(threeLevels)
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", 1))
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", 30))
            assert.are.equal("lvl40", ForeverBiSModel.phaseForLevel("druid", 31))
            assert.are.equal("lvl40", ForeverBiSModel.phaseForLevel("druid", 40))
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", 41))
        end)

        it("returns the last phase above every numeric phase", function()
            routeWith(threeLevels)
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", 60))
        end)

        it("returns the last phase for a nil or invalid level", function()
            routeWith(threeLevels)
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", nil))
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", "30"))
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", 0))
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", 0 / 0))
        end)

        it("treats phases without a level as endgame and sorts them last", function()
            routeWith({
                { id = "current", label = "Current" },
                { id = "lvl30", label = "Level 30", level = 30 },
                { id = "lvl50", label = "Level 50", level = 50 },
            })
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", 12))
            assert.are.equal("lvl50", ForeverBiSModel.phaseForLevel("druid", 50))
            assert.are.equal("current", ForeverBiSModel.phaseForLevel("druid", 51))
            assert.are.equal("current", ForeverBiSModel.phaseForLevel("druid", nil))
        end)

        it("orders numeric phases by level whatever their declaration order", function()
            routeWith({
                { id = "lvl50", label = "Level 50", level = 50 },
                { id = "lvl30", label = "Level 30", level = 30 },
            })
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", 20))
        end)

        it("returns the only phase of a single-phase route", function()
            routeWith({ { id = "lvl30", label = "Level 30", level = 30 } })
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", 10))
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", 70))
            assert.are.equal("lvl30", ForeverBiSModel.phaseForLevel("druid", nil))
        end)

        it("only considers phases the route has data for", function()
            local data = fixture()
            data.lists.druid.phases.lvl30 = nil -- the global list still declares lvl30
            load(data)
            assert.are.equal("lvl60", ForeverBiSModel.phaseForLevel("druid", 10))
        end)

        it("returns nil for an unknown route", function()
            load(fixture())
            assert.is_nil(ForeverBiSModel.phaseForLevel("nope", 30))
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

        it("falls back to the level-based phase when the saved one is unavailable", function()
            load(fixture())
            assert.are.equal("lvl60", ForeverBiSModel.effectivePhase("druid", "lvl60", 10))
            assert.are.equal("lvl30", ForeverBiSModel.effectivePhase("druid", "gone", 10))
            assert.are.equal("lvl60", ForeverBiSModel.effectivePhase("druid", nil, 45))
            assert.is_nil(ForeverBiSModel.effectivePhase("nope", "lvl30", 10))
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
                },
            }, ForeverBiSModel.bisEntries(11))
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
            _G.ForeverBiSData.lists.druid.phases.lvl30.slots[1].items[1].id = 77
            ForeverBiSModel.buildLegacy()
            assert.are.same({}, ForeverBiSModel.bisEntries(11))
            assert.are.equal(1, #ForeverBiSModel.bisEntries(77))
        end)
    end)

    describe("progress", function()
        local IDS =
            { Hood = 1, Cap = 2, Helm = 3, RingA = 11, RingB = 12, RingC = 13, Axe = 21, Maul = 22, Shield = 23 }

        local function items(...)
            local rows = {}
            for _, name in ipairs({ ... }) do
                table.insert(rows, { name, "Source of " .. name })
            end
            return rows
        end

        local function list(slots)
            return { title = "Test", slots = slots }
        end

        local function owned(equipped, bags)
            return {
                equipped = equipped or {},
                bags = function(id)
                    return (bags or {})[id] or 0
                end,
                itemId = function(name)
                    return IDS[name]
                end,
            }
        end

        local headList = list({ { "Head", items("Hood", "Cap", "Helm") } })

        before_each(function()
            load(fixture())
        end)

        it("reports nothing owned: no BiS, nothing listed, the top item as target", function()
            local result = ForeverBiSModel.progress(headList, owned())
            assert.are.equal(1, result.total)
            assert.are.equal(0, result.bis)
            assert.are.equal(0, result.listed)
            local slot = result.slots[1]
            assert.are.equal("Head", slot.slot)
            assert.is_nil(slot.rank)
            assert.is_false(slot.done)
            assert.are.equal("Hood", slot.target.name)
            assert.are.equal(1, slot.target.rank)
            assert.are.equal("Source of Hood", slot.target.source)
            assert.is_falsy(slot.target.inBags)
        end)

        it("counts a rank 1 item as BiS with no target", function()
            local result = ForeverBiSModel.progress(headList, owned({ Head = { 1 } }))
            assert.are.equal(1, result.bis)
            assert.are.equal(1, result.listed)
            assert.are.equal(1, result.slots[1].rank)
            assert.is_true(result.slots[1].done)
            assert.is_nil(result.slots[1].target)
        end)

        it("counts a lower rank as listed but not BiS and targets the best missing item", function()
            local result = ForeverBiSModel.progress(headList, owned({ Head = { 3 } }))
            assert.are.equal(0, result.bis)
            assert.are.equal(1, result.listed)
            assert.are.equal(3, result.slots[1].rank)
            assert.are.equal("Hood", result.slots[1].target.name)
        end)

        it("targets an upgrade that sits in the bags and flags it", function()
            local result = ForeverBiSModel.progress(headList, owned({ Head = { 3 } }, { [2] = 1 }))
            local target = result.slots[1].target
            assert.are.equal("Cap", target.name)
            assert.are.equal(2, target.rank)
            assert.is_true(target.inBags)
        end)

        it("ignores bag copies that are not an upgrade", function()
            local result = ForeverBiSModel.progress(headList, owned({ Head = { 2 } }, { [3] = 1 }))
            assert.are.equal("Hood", result.slots[1].target.name)
            assert.is_falsy(result.slots[1].target.inBags)
        end)

        it("needs the top two items in either order for rings and trinkets", function()
            local rings = list({ { "Finger", items("RingA", "RingB", "RingC") } })
            local one = ForeverBiSModel.progress(rings, owned({ Finger = { 11 } }))
            assert.are.equal(0, one.bis)
            assert.are.equal(1, one.listed)
            assert.are.equal("RingB", one.slots[1].target.name)

            local split = ForeverBiSModel.progress(rings, owned({ Finger = { 11, 13 } }))
            assert.are.equal(0, split.bis)
            assert.are.equal("RingB", split.slots[1].target.name)

            local forward = ForeverBiSModel.progress(rings, owned({ Finger = { 11, 12 } }))
            local backward = ForeverBiSModel.progress(rings, owned({ Finger = { 12, 11 } }))
            assert.are.equal(1, forward.bis)
            assert.are.equal(1, backward.bis)
            assert.is_nil(backward.slots[1].target)
        end)

        it("counts a slot listing a single ring as done once it is worn", function()
            local result =
                ForeverBiSModel.progress(list({ { "Trinket", items("RingA") } }), owned({ Trinket = { 11 } }))
            assert.are.equal(1, result.bis)
        end)

        it("counts a weapon position once and picks the variant the player is closest to", function()
            local weapons = list({
                { "Main hand", items("Axe") },
                { "Two-hand weapon", items("Maul") },
                { "Off hand: shield", items("Shield") },
                { "Off hand: held item", items("Cap") },
            })
            local none = ForeverBiSModel.progress(weapons, owned())
            assert.are.equal(2, none.total)
            assert.are.equal("Main Hand", none.slots[1].slot)
            assert.are.equal("Axe", none.slots[1].target.name)
            assert.are.equal("Off Hand", none.slots[2].slot)

            local twoHander = ForeverBiSModel.progress(weapons, owned({ ["Main Hand"] = { 22 } }))
            assert.are.equal(1, twoHander.bis)
            assert.are.equal(1, twoHander.listed)
            assert.is_true(twoHander.slots[1].done)

            local both = ForeverBiSModel.progress(weapons, owned({ ["Main Hand"] = { 21 }, ["Off Hand"] = { 23 } }))
            assert.are.equal(2, both.bis)
        end)

        it("folds Relic into the Ranged position", function()
            local result = ForeverBiSModel.progress(list({ { "Relic", items("Axe") } }), owned())
            assert.are.equal("Ranged", result.slots[1].slot)
        end)

        it("never counts an item without a known id as owned", function()
            local unknown = list({ { "Head", items("Mystery Hat", "Hood") } })
            local result = ForeverBiSModel.progress(unknown, owned({ Head = { 1 } }))
            assert.are.equal(0, result.bis)
            assert.are.equal(2, result.slots[1].rank)
            assert.are.equal("Mystery Hat", result.slots[1].target.name)
            -- Even a bag count cannot make an id-less item count as held.
            local bagged = ForeverBiSModel.progress(unknown, owned({}, { [0] = 5 }))
            assert.is_falsy(bagged.slots[1].target.inBags)
        end)

        it("falls back to ForeverBiSItemIDs when no resolver is injected", function()
            _G.ForeverBiSItemIDs = { Hood = 1 }
            local result = ForeverBiSModel.progress(headList, { equipped = { Head = { 1 } } })
            assert.are.equal(1, result.bis)
        end)

        it("totals every tracked slot and skips untracked or empty ones", function()
            local result = ForeverBiSModel.progress(
                list({
                    { "Head", items("Hood") },
                    { "Neck", items("Cap") },
                    { "Tabard", items("Helm") },
                    { "Chest", {} },
                }),
                owned({ Head = { 1 } })
            )
            assert.are.equal(2, result.total)
            assert.are.equal(1, result.bis)
            assert.are.equal(1, result.listed)
            assert.are.equal(2, #result.slots)
        end)

        it("returns total 0 for missing, empty or malformed lists", function()
            for _, bad in ipairs({ {}, { slots = {} }, { slots = "x" }, { slots = { 1, "a", { 5 }, { "Head" } } } }) do
                assert.are.equal(0, ForeverBiSModel.progress(bad, owned()).total)
            end
            assert.are.equal(0, ForeverBiSModel.progress(nil, nil).total)
            assert.are.equal(0, ForeverBiSModel.progress("nope", owned()).total)
        end)

        it("tolerates malformed items and owned data", function()
            local messy = list({ { "Head", { 5, { 7 }, { "Hood" } } } })
            local result = ForeverBiSModel.progress(messy, { equipped = { Head = { "x", 11 } }, bags = "no" })
            assert.are.equal(1, result.total)
            assert.are.equal(1, result.bis)
        end)

        it("normalizes slot names the way the gear panel does", function()
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
end)
