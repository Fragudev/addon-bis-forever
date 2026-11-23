# CurseForge Page Content

## Project Name
ForeverBiS

## Category
World of Warcraft Addon

## Description (Short - 160 chars max)
Leveling Best in Slot lists for every class and spec in WoW Forever: a gear grid, BiS tooltips and stars on bag items.

## Full Description

Source: [DESCRIPTION.md](DESCRIPTION.md)

````markdown
# Forever BiS — Best in Slot Helper for WoW Forever

**Know exactly what to farm next.** Forever BiS brings leveling Best in Slot lists into the game for every class and spec, from level 20 to 60: in a gear grid, on every item tooltip and as a star on the items in your bags.

Open it with `/bis`, `/foreverbis` or the minimap button.

---

## ✨ Highlights

- **Every class and spec** — 26 PvE specs, with lists for levels 20, 30, 40, 50 and 60 (pre-raid).
- **Ready on first open** — Your class, the spec your talents point to and the bracket for your level are already selected. Pick any other class, spec or bracket to plan ahead.
- **Top 1 to Top 6 per slot** — One row per gear slot with its six best items. Equipped items get a green border.
- **Where it drops** — Hover an item for its source: boss and dungeon, quest, vendor, profession or reputation, with the drop chance when it is known.
- **Inspect other players** — Click **BiS** on the inspect window to see their spec's list, with the items they wear in a blue border.

## 🏷️ BiS info in every tooltip

Hover any item (bags, links, vendors, auction house) to see:

- its rank for **your spec** in your level's bracket, with its source and drop chance;
- **your other specs** that want it;
- **other classes** that want it, one row per class with its icon.

Compact mode keeps the class rows short; hold **Shift** to see them all. Each part toggles with `/bis tooltip spec`, `specs`, `classes` or `compact`.

## ⭐ BiS stars

Items in your bags, the loot window and quest rewards get a gold star when they are Top 1 for your spec and bracket, and a silver star for Top 2 to Top 6. Toggle with `/bis stars`.

## 👥 Made for group play

- **Loot alerts** — When you or a group member loots a BiS item for your spec, you get a highlighted chat message and a sound. Toggle with `/bis alerts`.
- **Dungeon notice** — Entering an instance shows how many of your BiS items drop there (`5 BiS items in The Deadmines`). Click it to open the window. Toggle with `/bis dungeon`.
- **Share in chat** — `/bis link head` posts the ranked items for a slot. `/bis link` posts the top item of every slot. Shift-click an icon to link it.

## ⌨️ Commands

| Command | What it does |
|---|---|
| `/bis` or `/foreverbis` | Open or close the window |
| `/bis link [slot]` | Post BiS items to party, raid or say |
| `/bis tooltip` | Toggle BiS info in item tooltips |
| `/bis tooltip spec\|specs\|classes\|compact` | Toggle one part of the tooltip, or compact mode |
| `/bis stars` | Toggle the BiS stars |
| `/bis alerts` | Toggle loot alerts |
| `/bis dungeon` | Toggle the dungeon notice |
| `/bis minimap` | Toggle the minimap button |

## 📦 Installation

**CurseForge app (recommended):** select your World of Warcraft: Forever profile, search **ForeverBiS** and click **Install**.

**Manual:** extract the `ForeverBiS` folder into:

```
World of Warcraft\_classic_beta_\Interface\AddOns
```

Then enable `ForeverBiS` in the AddOns list on the character selection screen.

## 🔄 About the lists

WoW addons cannot access the internet, so the BiS lists are bundled with each release. They are generated from the item database and stat weights of [wowsims](https://github.com/wowsims/forever) (MIT License) and regenerated regularly; they rank items by their stats and are PvE only. Drop chances come from EG Link. Data from Efficient Games (https://efficient.games), licensed under CC BY 4.0. **Keep the addon updated to get the latest lists.**

## 💬 Feedback

Found a bug or have an idea? Open an issue on [GitHub](https://github.com/Fragudev/addon-bis-forever/issues).

---

Made by [Fragudev](https://github.com/Fragudev) · Proprietary, all rights reserved ([LICENSE](https://github.com/Fragudev/addon-bis-forever/blob/main/LICENSE)) · Interface font: Fira Sans (SIL OFL 1.1)
````

## Images

| Image | File | Size |
|-------|------|------|
| Logo | `logo.png` | 256×256 |
| Banner | `banner.png` | 724×180 |

## Release Notes Template

```
## beta_X.X.X

- Updated BiS lists with latest changes
- New item sources added
- Bug fixes and improvements

Full changelog: https://github.com/Fragudev/addon-bis-forever/releases
```
