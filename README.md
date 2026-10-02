# Forever BiS

Copyright (c) 2026 Fragudev. Licensed under the [MIT License](LICENSE.md). Third-party materials, game assets, and external Best in Slot list information are not claimed by this license.

WoW Forever addon (Interface 16001). Use `/bis` or `/foreverbis` in-game to open the window.

## Installation

### Install with the CurseForge app

1. Open the [CurseForge app](https://www.curseforge.com/download/app) and select your World of Warcraft: Forever game profile.
2. Find **ForeverBiS** in the app and click **Install**. The app installs the addon directly; no manual download or extraction is needed.
3. Make sure `ForeverBiS` is enabled in the AddOns list on the character selection screen.
4. Open the window with `/bis` or `/foreverbis`, or click the minimap button.

### Install manually

1. Download the addon from [CurseForge](https://www.curseforge.com/wow/addons/foreverbis-helper) or from the [GitHub Releases](https://github.com/Fragudev/addon-bis-forever/releases) section.
2. Extract the `ForeverBiS` folder into:

   ```
   World of Warcraft\_classic_beta_\Interface\AddOns
   ```

3. Make sure `ForeverBiS` is enabled in the AddOns list on the character selection screen.
4. Open the window with `/bis` or `/foreverbis`, or click the minimap button.

## Using the addon

Choose a class and build from the dropdowns. Your selection is saved between sessions. On login the addon selects your character's class automatically until you pick a class yourself; builds are never detected, so choose yours from the Build dropdown. When a build has lists for more than one phase, a phase dropdown appears beside the build selector: `Auto` shows the list for your character's level (the lowest phase at or above your level, or the latest phase once you pass them all), and you can pin any other phase instead. The selector stays hidden while a build has a single phase. The filter bar above the list is always visible. Search matches the item name, boss, or zone, and the `x` clears it. The four icon buttons (quest, dungeon or raid, world, profession) filter by source and can be combined; the dungeon picker appears while the dungeon button is active. The faction button shows your faction only (click it for both) and is hidden when the client does not report a faction. The maker button cycles on each click through `Maker: all` (everything), `Maker: only` (just the profession items only their maker can wear), and `Maker: hide` (everything except those); tradeable crafted items count as regular items. A counter shows `shown/total` while a filter hides items, and the empty state offers `Clear filters`. Highlighted buttons are active filters.

Faction-exclusive items show a faction emblem and a red Horde or blue Alliance label. Use the plus/minus button beside a slot heading to collapse or expand its list. Each item row shows its rank, icon with a rarity-colored border, item name in its rarity color, and source. Boss or source names and their locations use separate colors. Drop rates omit the redundant Classic label. A green check marks items equipped in that slot, and a gold `xN` marks copies in your bags.

## Sharing in chat

`/bis link head` posts the ranked BiS items for a slot (any slot name or its first letters, such as `main hand` or `off`) with clickable item links. `/bis link` posts the top item of every slot, split into several messages under the chat limit. Messages go to the raid or party chat, or to say when you are alone. Shift-click an item icon in the list to put its link in the chat box. An unknown slot name prints the valid slots.

## Loot alerts

When you or anyone in your group receives an item that is BiS for your selected build and phase, a highlighted chat message (worded like the tooltip: rank, slot, build and phase) is printed and a short sound plays. Each drop alerts once, and items that are not on your build stay silent. `/bis alerts` turns the alerts on or off (on by default; the choice is account-wide).

## Tooltips

Any item tooltip in the game (bags, equipped gear, links, vendors, the auction house, comparison tooltips) gets a gold `Forever BiS` block listing where the item is BiS for your class, such as `BiS #2 Head - Feral PvE (Level 30)`. Each build shows the phase that matches your character's level, independent of the phase picked in the window; an item that is BiS only in another phase still appears, with that phase named. At most four lines are shown, followed by `+N more`. The addon's own window keeps its source and ownership tooltips without this block.

- `/bis tooltip` turns the block on or off (on by default).
- `/bis tooltip all` toggles showing every class instead of only your own.

Hover over an item icon to see its tooltip. The help icon on the selector row explains the addon features; hover to read it or click to keep it open.

The right-side paper-doll panel has a brown character-panel frame, with item icons arranged around a static render of your character. Each item icon has a border matching its rarity. `Equipped Only` filters the panel to BiS-ranked items already equipped in their matching slots, including the correct first or second ring and trinket slots. The three weapon slots are grouped together in the center below the character. Click a BiS icon to jump to its slot in the list.

The progress line beside `Equipped Only` (for example `BiS 3/17` with a thin gold bar) shows how many tracked slots of the selected build and phase already hold their BiS item; a slot counts as BiS when its top-ranked item is equipped, and rings and trinkets need the top two items in either order. Hover it for the build and phase, the BiS and `Listed` (at least one listed item equipped) totals, and up to eight slots with the next item to get and where it comes from; items already in your bags are prefixed with `Equip:`, and `+N more` marks a truncated list. Weapon variants (one-hand, two-hand, shield, held item) share one position each, and enchants are not part of the count. The line hides when the list has no trackable slots.

The window opens at its minimum size and can be enlarged vertically from its bottom edge; the minimum size keeps the BiS panel visible. Drag the minimap button around the minimap to reposition it. The minimap icon (a gold "FB" monogram inside the gold ring) is `ForeverBiSMinimapIcon.tga`; regenerate its artwork with `python3 tools/generate_minimap_icon.py`.

## Current scope

The selector includes the class and build variants discovered on ForeverChanges. The addon reads its bundled `ForeverBiS_Data.lua` (schema 2: lists per phase with structured item sources, see [docs/data-schema-v2.md](docs/data-schema-v2.md)); the UI shows the phase matching your level (or the one you pick); the included updater can refresh that file from the current public lists. The window sizes itself to the content, can be resized from its bottom-right corner, and allows scrolling when a list is taller than the window.

## Code layout

The addon is split into layers. Every file starts with `local _, ns = ...` and shares the private namespace `ns`; the only globals are the saved variables, the data and the legacy `ForeverBiSModel` kept for compatibility.

```
ForeverBiS/
  ForeverBiS_Data.lua, ForeverBiS_Model.lua, ForeverBiS_Tooltip.lua
  Core/      Settings, Catalog, Sources, Filters, Lists
  Adapters/  Items, Inventory, Player
  UI/        MainFrame, ItemWidgets, Selectors, Help, FilterBar, ItemRows, ItemList, PaperDoll, Progress, Minimap
  App/       Events, Commands
  ForeverBiS.lua  (composition root)
```

**Layering rule: Core never touches frames or the WoW API; Adapters are the only callers of the item, inventory and unit APIs; UI only draws; App wires everything.**

- **Core** is pure logic (class and build catalog, source parsing, filters, saved variables). `Core/Settings.lua` is the only file that reads or writes `ForeverBiSDB`.
- **UI** panels never call each other. They share state through Core (for example `Filters.state`) and ask for a redraw with `ns.requestRender()`; its options are `scrollTop` and `jumpTo`.
- **App** owns the client events and the slash commands. A new slash command is one entry in `Commands.handlers`.
- `ForeverBiS.lua` only creates the panels and defines `ns.requestRender()`.

`.luacheckrc` enforces the rule: a file that uses an API outside its layer fails `luacheck` as an undefined variable. To add a file, list it in `ForeverBiS.toc` (specs load files from the `.toc`, so the test stubs need no change).

## List updates

The released addon package must include `ForeverBiS_Data.lua` with the current lists. Players only need to install or update the addon normally, then select a class and build in-game. WoW addons cannot make web requests, so ForeverChanges updates must be collected and bundled by the addon maintainer before publishing a new addon version. `UpdateForeverBiS.py` is a maintainer tool and is not part of the player's installation steps.

The updater derives each list's phase from its title (for example "at level 30") and writes schema 2. The updater leaves the previous data file untouched if it cannot download or parse every discovered page.
