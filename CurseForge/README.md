# CurseForge Page Content

## Project Name
ForeverBiS

## Category
World of Warcraft Addon

## Description (Short - 160 chars max)
Complete Best in Slot (BiS) gear guide for WoW Forever. Browse gear by class, specialization, and slot.

## Full Description

Source: [DESCRIPTION.md](DESCRIPTION.md)

````markdown
# Forever BiS — Best in Slot Helper for WoW Forever

**Know exactly what to farm next.** Forever BiS brings the ForeverChanges and wowsims Best in Slot lists into the game: ranked gear for every class, spec and phase, where each item drops, and how close you are to completing your set.

Open it with `/bis`, `/foreverbis` or the minimap button.

---

## ✨ Highlights

- **Every class, PvE and PvP** — Pick your class, then PvE or PvP, then your spec. Your class is selected automatically on login.
- **Choose your source** — Pick the ForeverChanges or wowsims lists once; the addon remembers your choice. The dropdown in the selector row switches it.
- **Phase-aware lists** — `Auto` shows the list for your current level. You can also pin any other phase to plan ahead.
- **Ranked items per slot** — Rank, icon, rarity, and exact source: boss, zone, drop rate, quest, profession or world drop.
- **Know what you already have** — A green check marks equipped BiS items. An amber `xN` shows copies sitting in your bags.
- **BiS progress** — `BiS 3/17` tells you how many slots are done. Hover it to see the next item for each slot and where to get it.
- **Paper doll overview** — Your gear around a character render. Missing BiS slots are highlighted in red. Click any icon to jump to that slot.

## 🔍 Powerful filters

- Search by item name, boss or zone.
- Filter by source: quests, dungeons and raids, world drops, professions. Combine them freely.
- Pick a single dungeon from the dungeon filter.
- Show only your faction's items, or both.
- Show, hide or isolate crafted items that only their maker can wear.

## 🏷️ BiS info in every tooltip

Hover any item anywhere in the game (bags, links, vendors, auction house) and see where it ranks for your class:

> **Forever BiS**
> BiS #2 Head - Feral PvE (Level 30)

- `/bis tooltip` turns it on or off.
- `/bis tooltip all` shows every class, not only yours.

## 👥 Made for group play

- **Loot alerts** — When you or a group member loots a BiS item for your build, you get a highlighted chat message and a sound. Toggle with `/bis alerts`.
- **Dungeon notice** — Entering an instance shows how many of your BiS items drop there (`5 BiS items in The Deadmines`). Click it to open the filtered list. Toggle with `/bis dungeon`.
- **Share in chat** — `/bis link head` posts the ranked items for a slot. `/bis link` posts the top item of every slot. Shift-click an icon to link it.

## ⌨️ Commands

| Command | What it does |
|---|---|
| `/bis` or `/foreverbis` | Open or close the window |
| `/bis link [slot]` | Post BiS items to party, raid or say |
| `/bis tooltip` | Toggle BiS info in item tooltips |
| `/bis tooltip all` | Toggle showing every class in tooltips |
| `/bis alerts` | Toggle loot alerts |
| `/bis dungeon` | Toggle the dungeon notice |

## 📦 Installation

**CurseForge app (recommended):** select your World of Warcraft: Forever profile, search **ForeverBiS** and click **Install**.

**Manual:** extract the `ForeverBiS` folder into:

```
World of Warcraft\_classic_beta_\Interface\AddOns
```

Then enable `ForeverBiS` in the AddOns list on the character selection screen.

## 🔄 About the lists

WoW addons cannot access the internet, so the BiS lists are bundled with each release. They are refreshed from [ForeverChanges](https://foreverchanges.pro) and [wowsims](https://github.com/wowsims/forever) regularly. **Keep the addon updated to get the latest lists.**

## 💬 Feedback

Found a bug or have an idea? Open an issue on [GitHub](https://github.com/Fragudev/addon-bis-forever/issues).

---

Made by [Fragudev](https://github.com/Fragudev) · MIT License · Interface font: Fira Sans (SIL OFL 1.1)
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
