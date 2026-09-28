# Forever BiS — beta-0.0.33

The original ForeverBiS addon code and project-created artwork are copyright Fragudev (fragudev@gmail.com) and distributed under the proprietary personal-use terms in [LICENSE.md](LICENSE.md). You may install and use it for personal play; redistribution, modification, and reuse require the copyright holder's written permission. Third-party materials, game assets, and external BiS list information are not claimed by this license.

WoW Forever addon (Interface 16001). Use `/bis` or `/foreverbis` in-game to open the window.

## Instalación

1. Descarga el archivo `.zip` desde la sección [Releases](https://github.com/Fragudev/addon-bis-forever/releases).
2. Extraé la carpeta `ForeverBiS` dentro de:

```
World of Warcraft\_classic_beta_\Interface\AddOns
```

3. Asegurate de que `ForeverBiS` esté habilitado en la lista de AddOns de la pantalla de selección de personaje.
4. Abrí la ventana con `/bis` o haciendo clic en el botón del minimap.

Open the window with `/bis` or click the minimap button, then choose a class and build from the dropdowns. Your selection is saved between sessions. Filters start hidden; use `Show Filters` and `Hide Filters` beside the class/build selectors to reveal or collapse item search, faction/source/dungeon filters, and the source legend. `Clear Filters` resets them all. Faction-exclusive items show a faction emblem and a red Horde or blue Alliance label. Use the plus/minus icon beside a slot heading to collapse or expand its list. Each item row shows its rank, icon with a rarity-colored border, item name in its rarity color, and source; boss or source names and their locations use separate colors. Drop rates omit the redundant Classic label. A green check marks items equipped in that slot, and a gold `xN` marks copies in your bags. Hover over an item icon for its tooltip. The help icon on the selector row explains all addon features; hover to read it or click to keep it open. The right-side paper-doll panel has a brown character-panel frame with item icons arranged around a static render of your character; each item icon has a border matching its rarity. `Equipped Only` filters the panel to BiS-ranked items already equipped in their matching slots, including the correct first/second ring and trinket slots. The three weapon slots are grouped together in the center below the character. Click a BiS icon to jump to its slot in the list. The window opens at its minimum size and can be enlarged vertically from its bottom edge; the minimum keeps the BiS panel visible. Drag the minimap button around the minimap to reposition it. The minimap portrait with its blue-and-gold circular frame is `ForeverBiSMinimapIcon.tga`.

## Current scope

The selector includes the class/build variants discovered from ForeverChanges. The addon reads its bundled `ForeverBiS_Data.lua`; the included updater can refresh that file from the current public lists. The window sizes itself to the content, can be resized from its bottom-right corner, and allows scrolling when a list is taller than the window.

## List updates

The released addon package must include `ForeverBiS_Data.lua` with the current lists. Players only install or update the addon normally, then select a class and build in game. WoW addons cannot make web requests, so current ForeverChanges changes must be collected and bundled by the addon maintainer before publishing a new addon version. `UpdateForeverBiS.py` is a maintainer tool and is not part of the player's installation steps.

The updater leaves the previous data file untouched if it cannot download or parse every discovered page.
