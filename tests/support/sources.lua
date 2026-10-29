-- Small synthetic schema 3 data with two sources, so specs do not depend on the shipped data files.
--   alpha (order 1): druid, druid/balance, rogue and rogue/pvp, all with the "lvl30" phase.
--   beta  (order 2): rogue and rogue/pvp with a "raid1" phase that has no level; no druid at all.

local Sources = {}

local function phase(title, itemId, itemName)
    return {
        title = title,
        slots = {
            {
                slot = "Head",
                items = { { id = itemId, name = itemName, source = { kind = "world", text = "World drop" } } },
            },
        },
    }
end

--- A fresh copy of the two-source ForeverBiSData.
function Sources.twoSources()
    return {
        schema = 3,
        sources = {
            alpha = {
                label = "Alpha",
                order = 1,
                url = "https://alpha.test",
                phases = { { id = "lvl30", label = "Level 30", level = 30 } },
                lists = {
                    ["druid"] = { label = "Feral PvE", phases = { lvl30 = phase("Feral", 11, "Alpha Hood") } },
                    ["druid/balance"] = {
                        label = "Balance PvE",
                        phases = { lvl30 = phase("Balance", 12, "Alpha Cowl") },
                    },
                    ["rogue"] = { label = "Rogue PvE", phases = { lvl30 = phase("Rogue", 13, "Alpha Mask") } },
                    ["rogue/pvp"] = { label = "Rogue PvP", phases = { lvl30 = phase("Rogue PvP", 14, "Alpha Cap") } },
                },
            },
            beta = {
                label = "Beta",
                order = 2,
                url = "https://beta.test",
                phases = { { id = "raid1", label = "Raid 1" } },
                lists = {
                    ["rogue"] = { label = "Beta Rogue", phases = { raid1 = phase("Beta Rogue", 21, "Beta Mask") } },
                    ["rogue/pvp"] = { label = "Beta Rogue PvP", phases = { raid1 = phase("Beta PvP", 22, "Beta Cap") } },
                },
            },
        },
    }
end

return Sources
