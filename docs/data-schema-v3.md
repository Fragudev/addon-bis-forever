# Data schema v3

Schema 3 is the current data format. The addon reads several sources, and each source has its own generated file:

| Source id | File | Shipped |
|-----------|------|---------|
| `foreverchanges` | `ForeverBiS/ForeverBiS_Data_ForeverChanges.lua` | yes |
| `wowsims` | `ForeverBiS/ForeverBiS_Data_Wowsims.lua` | yes |
| `kamilabs` | `ForeverBiS/ForeverBiS_Data_KamiLabs.lua` | no: generated only with `--include-unshipped`, pending permission from the site owner |

`UpdateForeverBiS.py` writes these files from the modules in `bis_sources/`. `ForeverBiS_Model.lua` (loaded after the data files, see the `.toc`) reads them and builds the legacy globals the UI uses (`ForeverBiSLists`, `ForeverBiSItemIDs`, `ForeverBiSBuildLabels`) for the active source. The model never reads `ForeverBiSDB`. The old single file `ForeverBiS_Data.lua` no longer exists; [schema 2](data-schema-v2.md) described it.

## Quick path

1. A data file adds one source to the wrapper `ForeverBiSData`.
2. The player chooses a source once. The model and the settings then read that source.
3. To add a source, follow [Extending](#extending).

## Wrapper and source entry

Every data file runs the same wrapper line, then registers its own source under its id:

```lua
ForeverBiSData = ForeverBiSData or { schema = 3, sources = {} }
ForeverBiSData.sources["foreverchanges"] = {
  label = "ForeverChanges",
  order = 1,
  url = "https://foreverchanges.pro",
  phases = {
    { id = "lvl30", label = "Level 30", level = 30 },
  },
  lists = {
    ["druid"] = {
      label = "Feral PvE",
      phases = {
        lvl30 = { title = "...", slots = { ... } },
      },
    },
  },
}
```

| Field | Meaning |
|-------|---------|
| `label` | Name shown in the source picker and the source dropdown |
| `order` | Display order, ascending; ties are broken by id |
| `url` | The site the lists come from |
| `phases` | Ordered, oldest first. Each phase is `{ id, label, level? }`; `level` is optional |
| `lists` | Route to list, same shape as schema 2 (see [Lists](#lists)) |

Because each file only adds its own key to `sources`, the files can load in any order. A file with another schema is ignored by the model.

Phases belong to their source. The phase dropdown only shows the phases of the active source, and two sources may use the same phase id for different data.

Routes also belong to their source. The first segment of a route is the class key (`druid`, `warrior`, ...), and a source only has routes for the classes and specs it covers.

## Per-source specifics

| Source | Order | Phases | Coverage | Item sources |
|--------|-------|--------|----------|--------------|
| ForeverChanges | 1 | `lvl30` (Level 30) | Ranked lists per class and spec, PvE and PvP | Structured (see [Item shape](#item-shape)) |
| wowsims | 3 | `lvl60` "Level 60 (pre-raid)", `raid1` "Raid (phase 1)" | Partial: 18 routes, no Shaman | Not published (see below) |
| Kami Labs | 2 | `lvl30` "Level 30", `lvl60` "Level 60 (pre-raid)" | One item per slot | Structured |

- **ForeverChanges.** Ranked lists, as before schema 3. Titles carry the level ("... at level 30"), and the updater derives the phase from the title.
- **wowsims.** Built from the gear presets in [wowsims/forever](https://github.com/wowsims/forever) (MIT). Each slot has one item. The item source is always `{ kind = "unknown", text = "Source not listed by wowsims" }`, because the presets do not say where an item comes from. `raid1` has no `level`, so it sorts after the numeric phases. Enchants are taken from the presets and may have an empty `source`.

  ```lua
  { slot = "Head",
    items = {
      { id = 10250, name = "Master's Hat", source = { kind = "unknown", text = "Source not listed by wowsims" } },
    },
    enchants = {
      { effect = "Arcanum of Focus", spell = "Arcanum of Focus", source = "" },
    },
  },
  ```
- **Kami Labs.** Level 30 and Level 60 (pre-raid) lists, one item per slot, with structured sources. Its file is only generated with `--include-unshipped` and is not shipped.

## Lists

The `lists` shape is unchanged from schema 2:

```lua
["druid/balance"] = {                                           -- route, same keys as the site
  label = "Balance PvE",
  phases = { lvl30 = { title = "...", slots = {
    { slot = "Head",
      items = { { id = 252504, name = "...", source = { kind = "profession", text = "...", skill = "Leatherworking" } } },
      enchants = { { effect = "Agility +5", spell = "...", source = "...", formulaId = 249504 } } },
  } } },
},
```

### Item shape

- `items` order is the rank. `id` is omitted when unknown. `enchants` is omitted when empty.
- `source.text` is the raw string from the source (lossless). `source.kind` is one of `quest`, `profession`, `dungeon`, `world`, `unknown`. The classification mirrors `Sources.category` in `Core/Sources.lua`. `unknown` is used for "Where it comes from is not known yet" and for wowsims items.
- Optional `source` fields, set only when detected: `faction` ("Horde"/"Alliance", exclusive sources only), `zone`, `boss`, `dropRate` (number, percent), `quest`, `skill`, `skillLevel`, `bindsToMaker`, `reported`.

## Model API

Source functions:

- `ForeverBiSModel.DEFAULT_SOURCE` is `"foreverchanges"`. The model starts on it.
- `ForeverBiSModel.sources()` returns the registered sources as `{ id, label, url }`, ordered by `order`, then id.
- `ForeverBiSModel.activeSource()` returns the id the model reads.
- `ForeverBiSModel.select(id)` makes a source active, rebuilds the legacy globals and resets the `bisIndex`. It returns `false` and changes nothing for an unknown id.

Every other function operates on the active source:

- `phases(route)`, `defaultPhase(route)` (latest available), `label(route)`, `list(route[, phaseId])` (legacy `{title, slots}` shape), `phaseForLevel(route, level)`, `availablePhase(route, phaseId)`, `effectivePhase(route, savedPhase, level)`, and `buildLegacy()`.
- `Lists.view` returns `missing = true` when the active source has no list for the route. The UI shows "<Source> has no list for this class yet."
- `Catalog.refreshBuilds(labels)` restores the built-in builds first, so it can be called again after a source change.

`ForeverBiSModel.bisEntries(itemId, itemName)` answers "where is this item BiS?" from a reverse index built lazily on first use (and reset by `buildLegacy` and `select`). It returns `{ route, class, phase, phaseLabel, slot, rank, label }` entries in route, phase and slot order, where `class` is the first route segment and `rank` the 1-based position in the slot. The id is matched first; the exact name only matches data rows that have no `id`. An item repeated in one slot list yields one entry, and unknown items, nil arguments or missing data yield an empty list. The tooltip decorator (`ForeverBiS_Tooltip.lua`) consumes it, and it reads the active source.

`phaseForLevel` returns the phase the player should see by default: among the phases the route has data for, the numeric-`level` phase with the smallest level that is >= the player's level (a level-25 character gets `lvl30`). Above every numeric phase, or with a nil/invalid level, it returns the final phase; phases without a numeric `level` (e.g. `raid1`) count as endgame and sort after all numeric ones. Unknown routes return nil. `availablePhase` returns a saved phase id only if the route has it (else nil, meaning automatic), and `effectivePhase` combines both.

## Settings API

The chosen source is account-wide: `ForeverBiSDB.source`. It is `nil` until the player chooses one. `Core/Settings.lua` is the only file that reads or writes it.

- `Settings.source()` returns the saved id, or `nil`.
- `Settings.sourceChosen()` is `true` only when the saved source is available in the data.
- `Settings.activeSource()` returns the id the model reads.
- `Settings.chooseSource(id)` saves the id, selects it, refreshes the builds and returns `true`. Unknown ids are ignored (`false`). When the character's route has no list in the new source, its build goes back to the class's first build. A phase the route lacks is dropped.

A saved source that is no longer available falls back to the default without clearing the saved id, so it applies again when the source comes back. Before any choice, tooltips and loot alerts use ForeverChanges.

In the window, the first open shows only a "Choose a data source" picker. After the choice the addon always opens with that source. A dropdown at the start of the selector row changes it.

## Progress

`ForeverBiSModel.progress(list, owned)` measures how close the player is to a legacy-shape list without calling the game. `owned` is injected:

```lua
owned = {
  equipped = { ["Head"] = { 252504 }, ["Finger"] = { 111, 222 }, ["Main Hand"] = { 333 } }, -- canonical slot key -> equipped item ids
  bags = function(itemId) return 1 end,       -- optional: copies in bags (0 or nil when none)
  itemId = function(itemName) return 252504 end, -- optional: name -> id; defaults to ForeverBiSItemIDs
}
```

Slot keys are canonical (`ForeverBiSModel.slotKey(name)`, the gear panel's normalization): `Head`, `Neck`, `Shoulder`, `Back`, `Chest`, `Wrist`, `Hands`, `Waist`, `Legs`, `Feet`, `Finger`, `Trinket`, `Main Hand`, `Off Hand`, `Ranged`. `Finger` and `Trinket` carry up to two ids, one per inventory slot. The UI builds `equipped` from the same `equippedSlotIDs` + `GetInventoryItemID`, and `GetItemCount` reads the row marks use, so both agree.

It returns `{ total, bis, listed, slots = { { slot, rank, target, done }, ... } }`:

- `total` counts tracked positions that have at least one listed item; `bis` counts the `done` ones; `listed` counts those with at least one listed item equipped. `rank` is the best equipped rank (nil when none is listed).
- A slot is BiS (`done`) when nothing listed would be an upgrade: for single slots the rank 1 item is equipped; for rings and trinkets the top two listed items are equipped, in any order (a list with one item needs just that one).
- `target` is the next item to get: `{ name, rank, source, inBags }`. Candidates are listed items ranked above the weakest equipped item (an empty inventory slot counts as weakest) that are not already equipped. A candidate held in bags wins and sets `inBags = true` ("equip this"); otherwise the best-ranked candidate is used.
- Items match by id only; an item whose id is unknown never counts as owned, so a rank 1 item without an id keeps its slot from ever being BiS.
- Weapons: list slots that normalize to the same key (`Main hand` and `Two-hand weapon`; `Off hand: shield` and `Off hand: held item`; `Relic` and `Ranged`) are mutually exclusive variants of one position, matching the three paper-doll weapon positions, and count once. Each variant is evaluated on its own ranks and the one holding the best equipped item wins (the first listed when tied). A two-hander therefore leaves `Off Hand` open.
- Enchants are ignored. A missing, empty or malformed list returns `total = 0`.

## Updater

`UpdateForeverBiS.py` is a CLI over the `bis_sources/` package:

- `bis_sources/__init__.py` is the registry. Each `Source` has an `id`, a `file_name`, a `label`, an `order`, a `url`, a `ship` flag and a `fetch()` function.
- `bis_sources/common.py` holds the shared HTTP helpers, the validation and the schema 3 Lua emitter.
- `bis_sources/foreverchanges.py`, `bis_sources/wowsims.py` and `bis_sources/kamilabs.py` are the source modules. Each `fetch()` returns `(data, labels, phases)`.

Flags:

- `python3 UpdateForeverBiS.py ForeverBiS` updates every shipped source.
- `--include-unshipped` also updates sources with `ship = False`.
- `--only <id>` (repeatable) updates just the named sources, shipped or not.

Failure guard: each source is fetched, validated and written atomically. A failing source keeps its previous file and prints a `::warning::`. The other sources are still written. The run exits with status 1 only when every attempted source fails.

The workflow `.github/workflows/update-lists.yml` stages `ForeverBiS/ForeverBiS_Data_*.lua`, and when any of them changed it bumps the version in `ForeverBiS.toc`, tags and releases.

## Extending

- **New phase.** For ForeverChanges, `phase_from_title()` in `bis_sources/foreverchanges.py` derives it from the list title ("... at level 60" gives `lvl60`); no code change is needed once the page title carries the level. Other sources declare their phases in their module (`PHASES` in `wowsims.py`, `TIERS` in `kamilabs.py`). The phase list of a source is its sorted union of phases, by level.
- **New source kind.** Add the check in `structure_source()` in `bis_sources/foreverchanges.py`, add the kind to `SOURCE_KINDS` in `bis_sources/common.py`, keep `Sources.category` in `Core/Sources.lua` in sync if the UI should filter on it, and add the kind to `VALID_KINDS` in `tests/data_spec.lua`.
- **New dungeon or raid.** Add a `(lowercase match, display name)` row to `DUNGEON_SOURCES` in `bis_sources/foreverchanges.py`, which also makes it a `dungeon` kind. Add it to `EXTRA_ZONES` to fill only `zone` and `boss`.
- **New source.**
  1. Add `bis_sources/<name>.py` with a `fetch()` that returns `(data, labels, phases)`, with `data` mapping route to phase to `(title, slots)`, as `common.validate` and `common.emit_lua` expect.
  2. Add a `Source(...)` entry to `SOURCES` in `bis_sources/__init__.py`. Set `ship = False` until it may ship.
  3. Add a line `ForeverBiS_Data_<file_name>.lua` to `ForeverBiS/ForeverBiS.toc`, before `ForeverBiS_Model.lua`.
  4. Add tests under `tests/python` (the fixtures are in `tests/python/fixtures`).
