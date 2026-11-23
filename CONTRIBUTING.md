# Contributing to Forever BiS

Thanks for helping. Bug reports and ideas are welcome from everyone as
[issues](https://github.com/Fragudev/addon-bis-forever/issues). Code changes come from maintainers.

## Reporting a bug

Search the open and closed issues first; if the bug is already there, add what you saw to it. Otherwise open a **Bug
report** and include:

- the addon version (shown in the AddOns list and in the name of the zip you installed);
- what you did, what you expected and what happened instead;
- the class, spec, level bracket and item involved;
- the game client language, when the problem is about a text.

The lists are generated here from the wowsims item database and stat weights, so a ranking that looks wrong is a bug
here too: say which item you expected and why. A wrong item stat or source in the wowsims data itself belongs to
[wowsims/forever](https://github.com/wowsims/forever). A wrong drop chance comes from the EG Link loot data
([JIVESCORP/eg-link-output-wowf](https://github.com/JIVESCORP/eg-link-output-wowf)); say which item, NPC and chance
you saw.

## Suggesting an idea

Open an **Idea**. Start with the problem you want solved, not the solution: it is easier to find a design that fits
the rest of the addon.

## Pull requests

Pull requests are open to maintainers only; GitHub does not let other accounts open them. If you want to help with
code, open an issue first and say so.

## For maintainers

- Work on `develop`, directly or through a short-lived branch merged into it. Never force-push.
- `main` only takes pull requests from `develop`, and each one needs the owner's approval.
- Commit messages and pull request titles follow [Conventional Commits](https://www.conventionalcommits.org/); CI
  checks the titles.
- Run the checks in [Building from source](README.md#building-from-source) before pushing.
- The lists come from two updater modules: `bis_sources/leveling.py` builds them from the wowsims item database and
  weights, and `bis_sources/eglink.py` adds the drop chances. Their tests live in `tests/python` (run them with
  `python3 -m unittest discover -s tests/python`), with recorded fixtures in `tests/python/fixtures`; the Lua specs
  in `tests` check the shipped data file and the addon.
- Each spec is one `Spec(...)` entry in `ROUTES` in `bis_sources/leveling.py`. Its `weights` is either a
  `(file, constant)` pair naming a wowsims EP preset, or a `{stat: weight}` table written for Forever BiS where
  wowsims ships no weights (the `CASTER` and `HEALER` bases, Holy and Protection Paladin, Restoration Shaman and Druid,
  Mage and Warlock). To adjust a written weight, change its value on the wowsims scale (spell damage or healing power
  is 1, ratings are per rating point; weapon DPS uses `MainHandDps`, `OffHandDps` or `RangedDps`), run
  `python3 UpdateForeverBiS.py ForeverBiS` and check the diff of `ForeverBiS/ForeverBiS_Data_Leveling.lua`. Never
  edit the data file by hand.
- Betas are published automatically from `develop` when the lists change; see
  [How the lists stay current](README.md#how-the-lists-stay-current). Only the owner merges into `main`.

## Licence

Forever BiS is proprietary; see [LICENSE](LICENSE). By submitting a contribution you agree that the copyright holder
may use, modify and distribute it as part of the project.
