# Forever BiS — beta-0.0.33

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

Choose a class and build from the dropdowns. Your selection is saved between sessions. Filters start hidden; use `Show Filters` and `Hide Filters` beside the class and build selectors to reveal or collapse item search, faction, source, and dungeon filters, along with the source legend. `Clear Filters` resets all filters.

Faction-exclusive items show a faction emblem and a red Horde or blue Alliance label. Use the plus/minus button beside a slot heading to collapse or expand its list. Each item row shows its rank, icon with a rarity-colored border, item name in its rarity color, and source. Boss or source names and their locations use separate colors. Drop rates omit the redundant Classic label. A green check marks items equipped in that slot, and a gold `xN` marks copies in your bags.

Hover over an item icon to see its tooltip. The help icon on the selector row explains the addon features; hover to read it or click to keep it open.

The right-side paper-doll panel has a brown character-panel frame, with item icons arranged around a static render of your character. Each item icon has a border matching its rarity. `Equipped Only` filters the panel to BiS-ranked items already equipped in their matching slots, including the correct first or second ring and trinket slots. The three weapon slots are grouped together in the center below the character. Click a BiS icon to jump to its slot in the list.

The window opens at its minimum size and can be enlarged vertically from its bottom edge; the minimum size keeps the BiS panel visible. Drag the minimap button around the minimap to reposition it. The minimap portrait with its blue-and-gold circular frame is `ForeverBiSMinimapIcon.tga`.

## Current scope

The selector includes the class and build variants discovered on ForeverChanges. The addon reads its bundled `ForeverBiS_Data.lua`; the included updater can refresh that file from the current public lists. The window sizes itself to the content, can be resized from its bottom-right corner, and allows scrolling when a list is taller than the window.

## List updates

The released addon package must include `ForeverBiS_Data.lua` with the current lists. Players only need to install or update the addon normally, then select a class and build in-game. WoW addons cannot make web requests, so ForeverChanges updates must be collected and bundled by the addon maintainer before publishing a new addon version. `UpdateForeverBiS.py` is a maintainer tool and is not part of the player's installation steps.

The updater leaves the previous data file untouched if it cannot download or parse every discovered page.
