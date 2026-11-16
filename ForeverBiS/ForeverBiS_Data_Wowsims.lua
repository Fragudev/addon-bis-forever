ForeverBiSData = ForeverBiSData or { schema = 3, sources = {} }
ForeverBiSData.sources["wowsims"] = {
  label = "wowsims",
  order = 3,
  url = "https://github.com/wowsims/forever",
  phases = {
    { id = "lvl60", label = "Level 60 (pre-raid)", level = 60 },
    { id = "raid1", label = "Raid (phase 1)" },
  },
  lists = {
    ["druid/balance"] = {
      label = "Balance",
      phases = {
        lvl60 = {
          title = "wowsims Balance Druid preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 10250, name = "Master's Hat", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Focus", spell = "Arcanum of Focus", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22149, name = "Beads of Ogre Mojo", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
              enchants = {
                { effect = "Spell Power", spell = "Enchant Necklace - Spell Power", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 10210, name = "Elegant Mantle", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272413, name = "Drape of Recovery", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 10143, name = "High Councillor's Robe", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 10248, name = "Master's Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Spellpower", spell = "Enchant Bracer - Greater Spellpower", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 10140, name = "High Councillor's Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcane Power", spell = "Enchant Gloves - Arcane Power", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 18405, name = "Belt of the Archmage", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 252486, name = "Ironfeather Leggings", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Arcanum of Focus", spell = "Arcanum of Focus", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 254129, name = "Ghostweave Boots", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272407, name = "Blessed Band of Light", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272438, name = "Weakness Analyzer", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 272439, name = "Serenity Field", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 274420, name = "Wisepaw Totem", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Spellblasting", spell = "Enchant 2H Weapon - Spellblasting", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272430, name = "Swarming Idol", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Balance Druid preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 21353, name = "Genesis Helm", source = { kind = "quest", text = "Quest: Genesis Helm", quest = "Genesis Helm" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18814, name = "Choker of the Fire Lord", source = { kind = "dungeon", text = "Ragnaros, Molten Core", zone = "Molten Core", boss = "Ragnaros" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 21354, name = "Genesis Shoulderpads", source = { kind = "quest", text = "Quest: Genesis Shoulderpads", quest = "Genesis Shoulderpads" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21409, name = "Cloak of Unending Life", source = { kind = "quest", text = "Quest: Cloak of Unending Life", quest = "Cloak of Unending Life" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 21357, name = "Genesis Vest", source = { kind = "quest", text = "Quest: Genesis Vest", quest = "Genesis Vest" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 21594, name = "Bracers of the Fallen Son", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21585, name = "Dark Storm Gauntlets", source = { kind = "world", text = "C'Thun, Ahn'Qiraj" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 19162, name = "Corehound Belt", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 21356, name = "Genesis Trousers", source = { kind = "quest", text = "Quest: Genesis Trousers", quest = "Genesis Trousers" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21355, name = "Genesis Boots", source = { kind = "quest", text = "Quest: Genesis Boots", quest = "Genesis Boots" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21709, name = "Ring of the Fallen God", source = { kind = "quest", text = "Quest: The Savior of Kalimdor", quest = "The Savior of Kalimdor" } },
                { id = 23031, name = "Band of the Inevitable", source = { kind = "dungeon", text = "Noth the Plaguebringer, Naxxramas", zone = "Naxxramas", boss = "Noth the Plaguebringer" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19379, name = "Neltharion's Tear", source = { kind = "dungeon", text = "Nefarian, Blackwing Lair", zone = "Blackwing Lair", boss = "Nefarian" } },
                { id = 23046, name = "The Restrained Essence of Sapphiron", source = { kind = "dungeon", text = "Sapphiron, Naxxramas", zone = "Naxxramas", boss = "Sapphiron" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 21407, name = "Mace of Unending Life", source = { kind = "quest", text = "Quest: Mace of Unending Life", quest = "Mace of Unending Life" } },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 19366, name = "Master Dragonslayer's Orb", source = { kind = "quest", text = "Quest: The Lord of Blackrock (Alliance)", faction = "Alliance", quest = "The Lord of Blackrock" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 23197, name = "Idol of the Moon", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
      },
    },
    ["druid/feral"] = {
      label = "Feral",
      phases = {
        lvl60 = {
          title = "wowsims Feral Druid preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 8345, name = "Wolfshead Helm", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19491, name = "Amulet of the Darkmoon", source = { kind = "quest", text = "Quest: 1200 Tickets - Amulet of the Darkmoon", quest = "1200 Tickets - Amulet of the Darkmoon" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 271955, name = "Theramore Pauldrons", source = { kind = "world", text = "Reputation: Theramore Expeditionary Force" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252484, name = "Timbermaw Tunic", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 19587, name = "Forest Stalker's Bracers", source = { kind = "world", text = "Sold by Illiyana Moonblaze, Ashenvale" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272396, name = "Shifter's Belt", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15065, name = "Warbear Woolies", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 20715, name = "Dunestalker's Boots", source = { kind = "quest", text = "Quest: Armaments of War", quest = "Armaments of War" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
                { id = 275981, name = "Warden's Signet of Ferocity", source = { kind = "world", text = "Reputation: The Watchers" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
                { id = 270275, name = "Cleansed Vilebranch Medallion", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 19323, name = "The Unstoppable Force", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
              },
              enchants = {
                { effect = "Superior Impact", spell = "Enchant 2H Weapon - Superior Impact", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272427, name = "Howling Idol", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Feral Druid preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 279253, name = "Outlaw's Collar", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "quest", text = "Quest: For All To See (Horde)", faction = "Horde", quest = "For All To See" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "world", text = "Sold by Creeg Bothunk, The Barrens" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 19587, name = "Forest Stalker's Bracers", source = { kind = "world", text = "Sold by Illiyana Moonblaze, Ashenvale" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272396, name = "Shifter's Belt", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15065, name = "Warbear Woolies", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 20715, name = "Dunestalker's Boots", source = { kind = "quest", text = "Quest: Armaments of War", quest = "Armaments of War" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
                { id = 275981, name = "Warden's Signet of Ferocity", source = { kind = "world", text = "Reputation: The Watchers" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 21188, name = "Fist of Cenarius", source = { kind = "quest", text = "Quest: Champion's Battlegear", quest = "Champion's Battlegear" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272427, name = "Howling Idol", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
          },
        },
      },
    },
    ["druid/tank"] = {
      label = "Guardian",
      phases = {
        raid1 = {
          title = "wowsims Guardian Druid preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 252485, name = "Warbear Helm", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19491, name = "Amulet of the Darkmoon", source = { kind = "quest", text = "Quest: 1200 Tickets - Amulet of the Darkmoon", quest = "1200 Tickets - Amulet of the Darkmoon" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 271955, name = "Theramore Pauldrons", source = { kind = "world", text = "Reputation: Theramore Expeditionary Force" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 272754, name = "Premier Knight-Captain's Beasthide Bracers", source = { kind = "world", text = "PvP reward" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272396, name = "Shifter's Belt", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22749, name = "Sentinel's Leather Pants", source = { kind = "world", text = "Sold by Illiyana Moonblaze, Ashenvale" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 20715, name = "Dunestalker's Boots", source = { kind = "quest", text = "Quest: Armaments of War", quest = "Armaments of War" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21202, name = "Signet Ring of the Bronze Dragonflight", source = { kind = "quest", text = "Quest: The Path of the Conqueror", quest = "The Path of the Conqueror" } },
                { id = 18879, name = "Heavy Dark Iron Ring", source = { kind = "dungeon", text = "Lucifron, Molten Core", zone = "Molten Core", boss = "Lucifron" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 17904, name = "Stormpike Insignia Rank 6", source = { kind = "quest", text = "Quest: The Eye of Command (Alliance)", faction = "Alliance", quest = "The Eye of Command" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 272848, name = "Premier Grand Marshal's Battle Hammer", source = { kind = "world", text = "PvP reward" } },
              },
            },
          },
        },
      },
    },
    ["hunter/melee"] = {
      label = "Melee",
      phases = {
        lvl60 = {
          title = "wowsims Melee Hunter preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 252605, name = "Black Dragonscale Helm", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15411, name = "Mark of Fordring", source = { kind = "quest", text = "Quest: In Dreams", quest = "In Dreams" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272106, name = "Darkspear Epaulets", source = { kind = "world", text = "Sold by Creeg Bothunk, The Barrens" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 13340, name = "Cape of the Black Baron", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 18375, name = "Bracers of the Eclipse", source = { kind = "dungeon", text = "Prince Tortheldrin, Dire Maul", zone = "Dire Maul", boss = "Prince Tortheldrin" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 15063, name = "Devilsaur Gauntlets", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 22232, name = "Marksman's Girdle", source = { kind = "dungeon", text = "Urok Doomhowl, Blackrock Spire", zone = "Blackrock Spire", boss = "Urok Doomhowl" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15062, name = "Devilsaur Leggings", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 226881, name = "Beastmaster's Treads", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Boots - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 13098, name = "Painweaver Band", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 260205, name = "Highborne Research Tablet", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12798, name = "Annihilator", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 13368, name = "Bonescraper", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Weapon - Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 18680, name = "Ancient Bone Bow", source = { kind = "dungeon", text = "Instructor Malicia, Scholomance", zone = "Scholomance", boss = "Instructor Malicia" } },
              },
              enchants = {
                { effect = "SAF-T Ultra Precision Scope", spell = "SAF-T Ultra Precision Scope", source = "" },
              },
            },
          },
        },
      },
    },
    ["hunter/ranged"] = {
      label = "Ranged",
      phases = {
        lvl60 = {
          title = "wowsims Ranged Hunter preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 252605, name = "Black Dragonscale Helm", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15411, name = "Mark of Fordring", source = { kind = "quest", text = "Quest: In Dreams", quest = "In Dreams" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272106, name = "Darkspear Epaulets", source = { kind = "world", text = "Sold by Creeg Bothunk, The Barrens" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 13340, name = "Cape of the Black Baron", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 226885, name = "Beastmaster's Bindings", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 15063, name = "Devilsaur Gauntlets", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 22232, name = "Marksman's Girdle", source = { kind = "dungeon", text = "Urok Doomhowl, Blackrock Spire", zone = "Blackrock Spire", boss = "Urok Doomhowl" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15062, name = "Devilsaur Leggings", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 13967, name = "Windreaver Greaves", source = { kind = "dungeon", text = "Kirtonos the Herald, Scholomance", zone = "Scholomance", boss = "Kirtonos the Herald" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Boots - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 18500, name = "Tarnished Elven Ring", source = { kind = "dungeon", text = "Tribute, Dire Maul", zone = "Dire Maul", boss = "Tribute" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 13965, name = "Blackhand's Breadth", source = { kind = "quest", text = "Quest: For The Horde! (Horde)", faction = "Horde", quest = "For The Horde!" } },
                { id = 280065, name = "Behemoth Bones", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 250619, name = "Legionite Glaive", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant 2H Weapon - Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 13023, name = "Eaglehorn Long Bow", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "SAF-T Ultra Precision Scope", spell = "SAF-T Ultra Precision Scope", source = "" },
              },
            },
          },
        },
      },
    },
    ["mage/arcane"] = {
      label = "Arcane",
      phases = {
        lvl60 = {
          title = "wowsims Arcane Mage preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 22267, name = "Spellweaver's Turban", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22403, name = "Nacreous Shell Necklace", source = { kind = "dungeon", text = "Cannon Master Willey, Stratholme", zone = "Stratholme", boss = "Cannon Master Willey" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 19050, name = "Mantle of the Timbermaw", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272411, name = "Arcanoweave Cloak", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 14152, name = "Robe of the Archmage", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 226929, name = "Sorcerer's Bindings", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 226930, name = "Sorcerer's Gauntlets", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 18405, name = "Belt of the Archmage", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 226933, name = "Sorcerer's Leggings", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 22231, name = "Kayser's Boots of Precision", source = { kind = "dungeon", text = "War Master Voone, Blackrock Spire", zone = "Blackrock Spire", boss = "War Master Voone" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272406, name = "Channeler's Ring", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 12543, name = "Songstone of Ironforge", source = { kind = "quest", text = "Quest: The Princess's Surprise (Alliance)", faction = "Alliance", quest = "The Princess's Surprise" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 22268, name = "Draconic Infused Emblem", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
                { id = 272438, name = "Weakness Analyzer", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 13964, name = "Witchblade", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 18316, name = "Obsidian Bauble", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 13938, name = "Bonecreeper Stylus", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
            },
          },
        },
      },
    },
    ["paladin/holy"] = {
      label = "Holy",
      phases = {
        raid1 = {
          title = "wowsims Holy Paladin preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12633, name = "Whitesoul Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15856, name = "Archlight Talisman", source = { kind = "quest", text = "Quest: Hidden Treasures", quest = "Hidden Treasures" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272413, name = "Drape of Recovery", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16726, name = "Lightforge Breastplate", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16722, name = "Lightforge Bracers", source = { kind = "dungeon", text = "Lord Alexei Barov, Scholomance", zone = "Scholomance", boss = "Lord Alexei Barov" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 250554, name = "Prefect's Gloves", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 250574, name = "Prefect's Waistguard", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16728, name = "Lightforge Legplates", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16725, name = "Lightforge Boots", source = { kind = "dungeon", text = "Balnazzar, Stratholme", zone = "Stratholme", boss = "Balnazzar" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 22681, name = "Band of Piety", source = { kind = "quest", text = "Quest: Superior Armaments of Battle - Friend of the Dawn", quest = "Superior Armaments of Battle - Friend of the Dawn" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272439, name = "Serenity Field", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 11811, name = "Smoking Heart of the Mountain", source = { kind = "profession", text = "Enchanting", skill = "Enchanting" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 20648, name = "Cold Forged Hammer", source = { kind = "quest", text = "Quest: Hero of the Stormpike (Alliance)", faction = "Alliance", quest = "Hero of the Stormpike" } },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 276754, name = "Sunderbark Vigil", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272436, name = "Libram of Economy", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
          },
        },
      },
    },
    ["paladin/retribution"] = {
      label = "Retribution",
      phases = {
        raid1 = {
          title = "wowsims Retribution Paladin preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12640, name = "Lionheart Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 14503, name = "Death's Clutch", source = { kind = "dungeon", text = "Ras Frostwhisper, Scholomance", zone = "Scholomance", boss = "Ras Frostwhisper" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 279269, name = "Fel Cape", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
              enchants = {
                { effect = "Lesser Agility", spell = "Enchant Cloak - Lesser Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252484, name = "Timbermaw Tunic", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 21184, name = "Deeprock Bracers", source = { kind = "quest", text = "Quest: Stalwart's Battlegear", quest = "Stalwart's Battlegear" } },
              },
              enchants = {
                { effect = "Healing Power", spell = "Enchant Bracer - Healing Power", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 19044, name = "Might of the Timbermaw", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 275618, name = "Scalegut Treaders", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Boots - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21182, name = "Band of Earthen Might", source = { kind = "quest", text = "Quest: Veteran's Battlegear", quest = "Veteran's Battlegear" } },
                { id = 19325, name = "Don Julio's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 274759, name = "Everlook Pathcarver", source = { kind = "world", text = "Sold by Zippie Fizzbolt, Winterspring" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 12784, name = "Arcanite Reaper", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272435, name = "Libram of Law", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
          },
        },
      },
    },
    ["paladin/shockadin"] = {
      label = "Shockadin",
      phases = {
        raid1 = {
          title = "wowsims Shockadin Paladin preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 16686, name = "Magister's Crown", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15856, name = "Archlight Talisman", source = { kind = "quest", text = "Quest: Hidden Treasures", quest = "Hidden Treasures" } },
              },
              enchants = {
                { effect = "Spell Power", spell = "Enchant Necklace - Spell Power", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 16729, name = "Lightforge Spaulders", source = { kind = "dungeon", text = "The Beast, Blackrock Spire", zone = "Blackrock Spire", boss = "The Beast" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18510, name = "Hide of the Wild", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Agility", spell = "Enchant Cloak - Lesser Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16666, name = "Vest of Elements", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16722, name = "Lightforge Bracers", source = { kind = "dungeon", text = "Lord Alexei Barov, Scholomance", zone = "Scholomance", boss = "Lord Alexei Barov" } },
              },
              enchants = {
                { effect = "Healing Power", spell = "Enchant Bracer - Healing Power", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16672, name = "Gauntlets of Elements", source = { kind = "dungeon", text = "Pyroguard Emberseer, Blackrock Spire", zone = "Blackrock Spire", boss = "Pyroguard Emberseer" } },
              },
              enchants = {
                { effect = "Healing Power", spell = "Enchant Gloves - Healing Power", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16723, name = "Lightforge Belt", source = { kind = "dungeon", text = "Trash, Stratholme", zone = "Stratholme", boss = "Trash" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16687, name = "Magister's Leggings", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16682, name = "Magister's Boots", source = { kind = "dungeon", text = "Hearthsinger Forresten, Stratholme", zone = "Stratholme", boss = "Hearthsinger Forresten" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272407, name = "Blessed Band of Light", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 270225, name = "Jewel of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 15257, name = "Shin Blade of Holy Wrath", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Mighty Spell Power", spell = "Enchant 2H Weapon - Mighty Spell Power", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272435, name = "Libram of Law", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
          },
        },
      },
    },
    ["paladin/tank"] = {
      label = "Protection",
      phases = {
        raid1 = {
          title = "wowsims Protection Paladin preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 250599, name = "Stalwart Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 275736, name = "Horn of Ve'han", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272745, name = "Premier Chevalier Shoulders", source = { kind = "world", text = "PvP reward" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18413, name = "Cloak of Warding", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 250595, name = "Enriched Thorium Breastplate", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16722, name = "Lightforge Bracers", source = { kind = "dungeon", text = "Lord Alexei Barov, Scholomance", zone = "Scholomance", boss = "Lord Alexei Barov" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 279264, name = "Heavy Thorium Gauntlets", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 250572, name = "Sentinel's Waistguard", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 279263, name = "Depleted Thorium Sabatons", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 15855, name = "Ring of Protection", source = { kind = "quest", text = "Quest: Hidden Treasures", quest = "Hidden Treasures" } },
                { id = 272409, name = "Ring of Awareness", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19024, name = "Arena Grand Master", source = { kind = "quest", text = "Quest: Arena Grandmaster", quest = "Arena Grandmaster" } },
                { id = 272440, name = "Defender's Grip Stabilizer", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 18168, name = "Force Reactive Disk", source = { kind = "profession", text = "Engineering", skill = "Engineering" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 23203, name = "Libram of Fervor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
      },
    },
    ["priest/holy"] = {
      label = "Holy",
      phases = {
        lvl60 = {
          title = "wowsims Holy Priest preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 14140, name = "Mooncloth Circlet", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22149, name = "Beads of Ogre Mojo", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 14139, name = "Mooncloth Shoulders", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 19527, name = "Battle Healer's Cloak", source = { kind = "world", text = "Sold by Kelm Hargunth, The Barrens" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 10020, name = "Stormcloth Vest", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 254061, name = "Nethergeld Cuffs", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 254095, name = "Gilded Gloves", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 19047, name = "Wisdom of the Timbermaw", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 14137, name = "Mooncloth Leggings", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 275609, name = "Swarmtender's Footpads", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 275740, name = "Ring of Nature's Cycles", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 275738, name = "Jereman's Bauble", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "quest", text = "Quest: Heroes of Old", quest = "Heroes of Old" } },
                { id = 272439, name = "Serenity Field", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 249454, name = "Dreamstaff", source = { kind = "profession", text = "Enchanting", skill = "Enchanting" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 249385, name = "Brilliant Wand", source = { kind = "profession", text = "Enchanting", skill = "Enchanting" } },
              },
            },
          },
        },
      },
    },
    ["rogue/assassination"] = {
      label = "Assassination",
      phases = {
        raid1 = {
          title = "wowsims Assassination Rogue preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 11735, name = "Ragefury Eyepatch", source = { kind = "dungeon", text = "Guzzler, Blackrock Depths", zone = "Blackrock Depths", boss = "Guzzler" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "world", text = "Sold by Creeg Bothunk, The Barrens" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21187, name = "Earthweave Cloak", source = { kind = "quest", text = "Quest: Volunteer's Battlegear", quest = "Volunteer's Battlegear" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 13944, name = "Tombstone Breastplate", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
              enchants = {
                { effect = "Living Stats", spell = "Enchant Chest - Living Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22204, name = "Wristguards of Renown", source = { kind = "dungeon", text = "Emperor Dagran Thaurissan, Blackrock Depths", zone = "Blackrock Depths", boss = "Emperor Dagran Thaurissan" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21278, name = "Stormshroud Gloves", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272395, name = "Assassin's Waistguard", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15062, name = "Devilsaur Leggings", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 18506, name = "Mongoose Boots", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
                { id = 21189, name = "Might of Cenarius", source = { kind = "quest", text = "Quest: Stalwart's Battlegear", quest = "Stalwart's Battlegear" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 19324, name = "The Lobotomizer", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 19166, name = "Black Amnesty", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "quest", text = "Quest: The Perfect Poison", quest = "The Perfect Poison" } },
              },
            },
          },
        },
      },
    },
    ["rogue/combat"] = {
      label = "Combat",
      phases = {
        raid1 = {
          title = "wowsims Combat Rogue preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 11735, name = "Ragefury Eyepatch", source = { kind = "dungeon", text = "Guzzler, Blackrock Depths", zone = "Blackrock Depths", boss = "Guzzler" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "world", text = "Sold by Creeg Bothunk, The Barrens" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21187, name = "Earthweave Cloak", source = { kind = "quest", text = "Quest: Volunteer's Battlegear", quest = "Volunteer's Battlegear" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 13944, name = "Tombstone Breastplate", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
              enchants = {
                { effect = "Living Stats", spell = "Enchant Chest - Living Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22204, name = "Wristguards of Renown", source = { kind = "dungeon", text = "Emperor Dagran Thaurissan, Blackrock Depths", zone = "Blackrock Depths", boss = "Emperor Dagran Thaurissan" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21278, name = "Stormshroud Gloves", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272395, name = "Assassin's Waistguard", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15062, name = "Devilsaur Leggings", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 18506, name = "Mongoose Boots", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
                { id = 21189, name = "Might of Cenarius", source = { kind = "quest", text = "Quest: Stalwart's Battlegear", quest = "Stalwart's Battlegear" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 19324, name = "The Lobotomizer", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "quest", text = "Quest: The Perfect Poison", quest = "The Perfect Poison" } },
              },
            },
          },
        },
      },
    },
    ["rogue/subtlety"] = {
      label = "Subtlety",
      phases = {
        raid1 = {
          title = "wowsims Subtlety Rogue preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 11735, name = "Ragefury Eyepatch", source = { kind = "dungeon", text = "Guzzler, Blackrock Depths", zone = "Blackrock Depths", boss = "Guzzler" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "world", text = "Sold by Creeg Bothunk, The Barrens" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21187, name = "Earthweave Cloak", source = { kind = "quest", text = "Quest: Volunteer's Battlegear", quest = "Volunteer's Battlegear" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 13944, name = "Tombstone Breastplate", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
              enchants = {
                { effect = "Living Stats", spell = "Enchant Chest - Living Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22204, name = "Wristguards of Renown", source = { kind = "dungeon", text = "Emperor Dagran Thaurissan, Blackrock Depths", zone = "Blackrock Depths", boss = "Emperor Dagran Thaurissan" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21278, name = "Stormshroud Gloves", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272395, name = "Assassin's Waistguard", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15062, name = "Devilsaur Leggings", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 18506, name = "Mongoose Boots", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
                { id = 21189, name = "Might of Cenarius", source = { kind = "quest", text = "Quest: Stalwart's Battlegear", quest = "Stalwart's Battlegear" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 19324, name = "The Lobotomizer", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "quest", text = "Quest: The Perfect Poison", quest = "The Perfect Poison" } },
              },
            },
          },
        },
      },
    },
    ["warlock/dps"] = {
      label = "Damage",
      phases = {
        lvl60 = {
          title = "wowsims Damage Warlock preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 16698, name = "Dreadmist Mask", source = { kind = "dungeon", text = "Darkmaster Gandling, Scholomance", zone = "Scholomance", boss = "Darkmaster Gandling" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22149, name = "Beads of Ogre Mojo", source = { kind = "quest", text = "Quest: Falrin's Vendetta", quest = "Falrin's Vendetta" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 16701, name = "Dreadmist Mantle", source = { kind = "dungeon", text = "Jandice Barov, Scholomance", zone = "Scholomance", boss = "Jandice Barov" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272413, name = "Drape of Recovery", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 14153, name = "Robe of the Void", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16703, name = "Dreadmist Bracers", source = { kind = "dungeon", text = "Trash, Blackrock Spire", zone = "Blackrock Spire", boss = "Trash" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16705, name = "Dreadmist Wraps", source = { kind = "dungeon", text = "Lorekeeper Polkelt, Scholomance", zone = "Scholomance", boss = "Lorekeeper Polkelt" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16702, name = "Dreadmist Belt", source = { kind = "dungeon", text = "Trash, Scholomance", zone = "Scholomance", boss = "Trash" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16699, name = "Dreadmist Leggings", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16704, name = "Dreadmist Sandals", source = { kind = "dungeon", text = "Baroness Anastari, Stratholme", zone = "Stratholme", boss = "Baroness Anastari" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 275738, name = "Jereman's Bauble", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19518, name = "Advisor's Ring", source = { kind = "world", text = "Sold by Kelm Hargunth, The Barrens" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272438, name = "Weakness Analyzer", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 270225, name = "Jewel of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 22379, name = "Shivsprocket's Shiv", source = { kind = "quest", text = "Quest: The Perfect Poison", quest = "The Perfect Poison" } },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 249455, name = "Truesilver Conduit", source = { kind = "profession", text = "Enchanting", skill = "Enchanting" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 15283, name = "Lunar Wand", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Damage Warlock preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 23255, name = "Champion's Dreadweave Cowl", source = { kind = "world", text = "Sold by Lady Palanseer" } },
              },
              enchants = {
                { effect = "Arcanum of Focus", spell = "Arcanum of Focus", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 23125, name = "Chains of the Lich", source = { kind = "dungeon", text = "Balzaphon, Stratholme", zone = "Stratholme", boss = "Balzaphon" } },
              },
              enchants = {
                { effect = "Spell Power", spell = "Enchant Necklace - Spell Power", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 23256, name = "Champion's Dreadweave Spaulders", source = { kind = "world", text = "Sold by Lady Palanseer" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21418, name = "Shroud of Unspoken Names", source = { kind = "quest", text = "Quest: Shroud of Unspoken Names", quest = "Shroud of Unspoken Names" } },
              },
              enchants = {
                { effect = "Subtlety", spell = "Enchant Cloak - Subtlety", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 14153, name = "Robe of the Void", source = { kind = "profession", text = "Tailoring", skill = "Tailoring" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 10248, name = "Master's Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Intellect", spell = "Enchant Bracer - Superior Intellect", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 22865, name = "Blood Guard's Dreadweave Handwraps", source = { kind = "world", text = "Sold by Lady Palanseer" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 20047, name = "Highlander's Cloth Girdle", source = { kind = "world", text = "Sold by Samuel Hawke, Arathi Highlands" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22881, name = "Legionnaire's Dreadweave Legguards", source = { kind = "world", text = "Sold by Lady Palanseer" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 17562, name = "Knight-Lieutenant's Dreadweave Boots", source = { kind = "world", text = "PvP reward" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21563, name = "Don Rodrigo's Band", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 249469, name = "Frozen Heart of the Mountain", source = { kind = "profession", text = "Enchanting", skill = "Enchanting" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 22383, name = "Sageblade", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Revelation", spell = "Enchant Weapon - Revelation", source = "" },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 19315, name = "Therazane's Touch", source = { kind = "world", text = "Sold by Gaelden Hammersmith, Alterac Valley" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 249385, name = "Brilliant Wand", source = { kind = "profession", text = "Enchanting", skill = "Enchanting" } },
              },
            },
          },
        },
      },
    },
    ["warrior/arms"] = {
      label = "Arms",
      phases = {
        lvl60 = {
          title = "wowsims Arms Warrior preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12640, name = "Lionheart Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15411, name = "Mark of Fordring", source = { kind = "quest", text = "Quest: In Dreams", quest = "In Dreams" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 10263, name = "Adventurer's Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 13340, name = "Cape of the Black Baron", source = { kind = "dungeon", text = "Baron Rivendare, Stratholme", zone = "Stratholme", boss = "Baron Rivendare" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 13400, name = "Vambraces of the Sadist", source = { kind = "dungeon", text = "Timmy the Cruel, Stratholme", zone = "Stratholme", boss = "Timmy the Cruel" } },
              },
              enchants = {
                { effect = "Superior Strength", spell = "Enchant Bracer - Superior Strength", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 226861, name = "Gauntlets of Heroism", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
              enchants = {
                { effect = "Greater Strength", spell = "Enchant Gloves - Greater Strength", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272403, name = "Valiant's Waistguard", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 226857, name = "Battleboots of Heroism", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 13098, name = "Painweaver Band", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 11815, name = "Hand of Justice", source = { kind = "dungeon", text = "Emperor Dagran Thaurissan, Blackrock Depths", zone = "Blackrock Depths", boss = "Emperor Dagran Thaurissan" } },
                { id = 13965, name = "Blackhand's Breadth", source = { kind = "quest", text = "Quest: For The Horde! (Horde)", faction = "Horde", quest = "For The Horde!" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 12790, name = "Arcanite Champion", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 18323, name = "Satyr's Bow", source = { kind = "dungeon", text = "Zevrim Thornhoof, Dire Maul", zone = "Dire Maul", boss = "Zevrim Thornhoof" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Arms Warrior preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12620, name = "Enchanted Thorium Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "quest", text = "Quest: For All To See (Horde)", faction = "Horde", quest = "For All To See" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10148, name = "Mighty Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 11604, name = "Dark Iron Plate", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16735, name = "Bracers of Valor", source = { kind = "dungeon", text = "Trash, Blackrock Spire", zone = "Blackrock Spire", boss = "Trash" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 13072, name = "Stonegrip Gauntlets", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 13077, name = "Girdle of Uther", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 13070, name = "Sapphiron's Scale Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 18821, name = "Quick Strike Ring", source = { kind = "dungeon", text = "Magmadar, Molten Core", zone = "Molten Core", boss = "Magmadar" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "quest", text = "Quest: Hidden Treasures", quest = "Hidden Treasures" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "quest", text = "Quest: Heroes of Old", quest = "Heroes of Old" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "quest", text = "Quest: You Are Rakh'likh, Demon", quest = "You Are Rakh'likh, Demon" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 12784, name = "Arcanite Reaper", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 16996, name = "Gorewood Bow", source = { kind = "quest", text = "Quest: The Scarlet Oracle, Demetria (Horde)", faction = "Horde", quest = "The Scarlet Oracle, Demetria" } },
              },
            },
          },
        },
      },
    },
    ["warrior/fury"] = {
      label = "Fury",
      phases = {
        lvl60 = {
          title = "wowsims Fury Warrior preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12640, name = "Lionheart Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15411, name = "Mark of Fordring", source = { kind = "quest", text = "Quest: In Dreams", quest = "In Dreams" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 22241, name = "Dark Warder's Pauldrons", source = { kind = "dungeon", text = "Warder Stilgiss, Blackrock Depths", zone = "Blackrock Depths", boss = "Warder Stilgiss" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272414, name = "Howler's Furs", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "profession", text = "Leatherworking", skill = "Leatherworking" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 12936, name = "Battleborn Armbraces", source = { kind = "dungeon", text = "Warchief Rend Blackhand, Blackrock Spire", zone = "Blackrock Spire", boss = "Warchief Rend Blackhand" } },
              },
              enchants = {
                { effect = "Superior Strength", spell = "Enchant Bracer - Superior Strength", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 226861, name = "Gauntlets of Heroism", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
              enchants = {
                { effect = "Greater Strength", spell = "Enchant Gloves - Greater Strength", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272403, name = "Valiant's Waistguard", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 226857, name = "Battleboots of Heroism", source = { kind = "world", text = "Sold by Mokvar, Orgrimmar" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 13098, name = "Painweaver Band", source = { kind = "dungeon", text = "General Drakkisath, Blackrock Spire", zone = "Blackrock Spire", boss = "General Drakkisath" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 11815, name = "Hand of Justice", source = { kind = "dungeon", text = "Emperor Dagran Thaurissan, Blackrock Depths", zone = "Blackrock Depths", boss = "Emperor Dagran Thaurissan" } },
                { id = 13965, name = "Blackhand's Breadth", source = { kind = "quest", text = "Quest: For The Horde! (Horde)", faction = "Horde", quest = "For The Horde!" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 22384, name = "Persuader", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 871, name = "Flurry Axe", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 12651, name = "Blackcrow", source = { kind = "dungeon", text = "Shadow Hunter Vosh'gajin, Blackrock Spire", zone = "Blackrock Spire", boss = "Shadow Hunter Vosh'gajin" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Fury Warrior preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12620, name = "Enchanted Thorium Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "quest", text = "Quest: For All To See (Horde)", faction = "Horde", quest = "For All To See" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10148, name = "Mighty Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 11604, name = "Dark Iron Plate", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16735, name = "Bracers of Valor", source = { kind = "dungeon", text = "Trash, Blackrock Spire", zone = "Blackrock Spire", boss = "Trash" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 13072, name = "Stonegrip Gauntlets", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 13077, name = "Girdle of Uther", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 13070, name = "Sapphiron's Scale Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 18821, name = "Quick Strike Ring", source = { kind = "dungeon", text = "Magmadar, Molten Core", zone = "Molten Core", boss = "Magmadar" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "quest", text = "Quest: Hidden Treasures", quest = "Hidden Treasures" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "quest", text = "Quest: Heroes of Old", quest = "Heroes of Old" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "quest", text = "Quest: You Are Rakh'likh, Demon", quest = "You Are Rakh'likh, Demon" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12774, name = "Dawn's Edge", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 16996, name = "Gorewood Bow", source = { kind = "quest", text = "Quest: The Scarlet Oracle, Demetria (Horde)", faction = "Horde", quest = "The Scarlet Oracle, Demetria" } },
              },
            },
          },
        },
      },
    },
    ["warrior/tank"] = {
      label = "Protection",
      phases = {
        lvl60 = {
          title = "wowsims Protection Warrior preset (pre-raid)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12640, name = "Lionheart Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 275736, name = "Horn of Ve'han", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 10390, name = "Hyperion Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272414, name = "Howler's Furs", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 10378, name = "Commander's Armor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 250582, name = "Sentinel's Wristguards", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Superior Deflection", spell = "Enchant Bracer - Superior Deflection", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 9410, name = "Cragfists", source = { kind = "dungeon", text = "Ancient Stone Keeper, Uldaman", zone = "Uldaman", boss = "Ancient Stone Keeper" } },
              },
              enchants = {
                { effect = "Greater Strength", spell = "Enchant Gloves - Greater Strength", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 250572, name = "Sentinel's Waistguard", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 287033, name = "Furbolg Berserker's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 17713, name = "Blackstone Ring", source = { kind = "dungeon", text = "Princess Theradras, Maraudon", zone = "Maraudon", boss = "Princess Theradras" } },
                { id = 272409, name = "Ring of Awareness", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272440, name = "Defender's Grip Stabilizer", source = { kind = "world", text = "Sold by Pix Xizzix, Stranglethorn Vale" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "quest", text = "Quest: Job Opening: Guard Captain of Revantusk Village (Horde)", faction = "Horde", quest = "Job Opening: Guard Captain of Revantusk Village" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12798, name = "Annihilator", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 10271, name = "Masterwork Shield", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Stamina", spell = "Enchant Bracer - Superior Stamina", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 15289, name = "Archstrike Bow", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Protection Warrior preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12620, name = "Enchanted Thorium Helm", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "quest", text = "Quest: For All To See (Horde)", faction = "Horde", quest = "For All To See" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10148, name = "Mighty Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 11604, name = "Dark Iron Plate", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16735, name = "Bracers of Valor", source = { kind = "dungeon", text = "Trash, Blackrock Spire", zone = "Blackrock Spire", boss = "Trash" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16737, name = "Gauntlets of Valor", source = { kind = "dungeon", text = "Ramstein the Gorger, Stratholme", zone = "Stratholme", boss = "Ramstein the Gorger" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 13077, name = "Girdle of Uther", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 13070, name = "Sapphiron's Scale Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 18879, name = "Heavy Dark Iron Ring", source = { kind = "dungeon", text = "Lucifron, Molten Core", zone = "Molten Core", boss = "Lucifron" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "quest", text = "Quest: Hidden Treasures", quest = "Hidden Treasures" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "quest", text = "Quest: Heroes of Old", quest = "Heroes of Old" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "quest", text = "Quest: You Are Rakh'likh, Demon", quest = "You Are Rakh'likh, Demon" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12774, name = "Dawn's Edge", source = { kind = "profession", text = "Blacksmithing", skill = "Blacksmithing" } },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 16998, name = "Sacred Protector", source = { kind = "quest", text = "Quest: The Scarlet Oracle, Demetria (Horde)", faction = "Horde", quest = "The Scarlet Oracle, Demetria" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 16996, name = "Gorewood Bow", source = { kind = "quest", text = "Quest: The Scarlet Oracle, Demetria (Horde)", faction = "Horde", quest = "The Scarlet Oracle, Demetria" } },
              },
            },
          },
        },
      },
    },
  },
}
