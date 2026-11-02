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
                { id = 22149, name = "Beads of Ogre Mojo", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 272413, name = "Drape of Recovery", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 18405, name = "Belt of the Archmage", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 252486, name = "Ironfeather Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Focus", spell = "Arcanum of Focus", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 254129, name = "Ghostweave Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272407, name = "Blessed Band of Light", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272438, name = "Weakness Analyzer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272439, name = "Serenity Field", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 272430, name = "Swarming Idol", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Balance Druid preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 21353, name = "Genesis Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18814, name = "Choker of the Fire Lord", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 21354, name = "Genesis Shoulderpads", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21409, name = "Cloak of Unending Life", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 21357, name = "Genesis Vest", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 21594, name = "Bracers of the Fallen Son", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21585, name = "Dark Storm Gauntlets", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 19162, name = "Corehound Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 21356, name = "Genesis Trousers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21355, name = "Genesis Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21709, name = "Ring of the Fallen God", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 23031, name = "Band of the Inevitable", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19379, name = "Neltharion's Tear", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 23046, name = "The Restrained Essence of Sapphiron", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 21407, name = "Mace of Unending Life", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 19366, name = "Master Dragonslayer's Orb", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 8345, name = "Wolfshead Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19491, name = "Amulet of the Darkmoon", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 271955, name = "Theramore Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252484, name = "Timbermaw Tunic", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 19587, name = "Forest Stalker's Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272396, name = "Shifter's Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15065, name = "Warbear Woolies", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 20715, name = "Dunestalker's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 275981, name = "Warden's Signet of Ferocity", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 270275, name = "Cleansed Vilebranch Medallion", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 19323, name = "The Unstoppable Force", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Impact", spell = "Enchant 2H Weapon - Superior Impact", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272427, name = "Howling Idol", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Feral Druid preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 279253, name = "Outlaw's Collar", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 19587, name = "Forest Stalker's Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272396, name = "Shifter's Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 15065, name = "Warbear Woolies", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 20715, name = "Dunestalker's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 275981, name = "Warden's Signet of Ferocity", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 21188, name = "Fist of Cenarius", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272427, name = "Howling Idol", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 252485, name = "Warbear Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19491, name = "Amulet of the Darkmoon", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 271955, name = "Theramore Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 272754, name = "Premier Knight-Captain's Beasthide Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 19049, name = "Timbermaw Brawlers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272396, name = "Shifter's Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22749, name = "Sentinel's Leather Pants", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 20715, name = "Dunestalker's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21202, name = "Signet Ring of the Bronze Dragonflight", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 18879, name = "Heavy Dark Iron Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 17904, name = "Stormpike Insignia Rank 6", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 272848, name = "Premier Grand Marshal's Battle Hammer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
      },
    },
    ["hunter/melee"] = {
      label = "Melee",
      phases = {
        raid1 = {
          title = "wowsims Melee Hunter preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 16677, name = "Beaststalker's Cap", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19620, name = "Maelstrom's Tendril", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 16679, name = "Beaststalker's Mantle", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Agility", spell = "Enchant Cloak - Lesser Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16674, name = "Beaststalker's Tunic", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16681, name = "Beaststalker's Bindings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16676, name = "Beaststalker's Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16680, name = "Beaststalker's Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16678, name = "Beaststalker's Pants", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Forceful Rugged Armor Kit", spell = "Forceful Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16675, name = "Beaststalker's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 11990, name = "Selenium Loop", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12798, name = "Annihilator", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 12783, name = "Heartseeker", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Biznicks 247x128 Accurascope", spell = "Biznicks 247x128 Accurascope", source = "" },
              },
            },
          },
        },
      },
    },
    ["hunter/ranged"] = {
      label = "Ranged",
      phases = {
        raid1 = {
          title = "wowsims Ranged Hunter preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 16677, name = "Beaststalker's Cap", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19620, name = "Maelstrom's Tendril", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 16679, name = "Beaststalker's Mantle", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Agility", spell = "Enchant Cloak - Lesser Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16674, name = "Beaststalker's Tunic", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16681, name = "Beaststalker's Bindings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16676, name = "Beaststalker's Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16680, name = "Beaststalker's Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16678, name = "Beaststalker's Pants", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Forceful Rugged Armor Kit", spell = "Forceful Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16675, name = "Beaststalker's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 11990, name = "Selenium Loop", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 250619, name = "Legionite Glaive", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant 2H Weapon - Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Biznicks 247x128 Accurascope", spell = "Biznicks 247x128 Accurascope", source = "" },
              },
            },
          },
        },
      },
    },
    ["mage/arcane"] = {
      label = "Arcane",
      phases = {
        raid1 = {
          title = "wowsims Arcane Mage preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 16686, name = "Magister's Crown", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 23057, name = "Gem of Trapped Innocents", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 22068, name = "Sorcerer's Mantle", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21415, name = "Drape of Vaulted Secrets", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16688, name = "Magister's Robes", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16683, name = "Magister's Bindings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16684, name = "Magister's Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16685, name = "Magister's Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16687, name = "Magister's Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16682, name = "Magister's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 275982, name = "Warden's Signet of Brilliance", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 18543, name = "Ring of Entropy", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 18820, name = "Talisman of Ephemeral Power", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19379, name = "Neltharion's Tear", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 23451, name = "Grand Marshal's Mageblade", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 19366, name = "Master Dragonslayer's Orb", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 279246, name = "Torch of Light", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 12633, name = "Whitesoul Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15856, name = "Archlight Talisman", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272413, name = "Drape of Recovery", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16726, name = "Lightforge Breastplate", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16722, name = "Lightforge Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 250554, name = "Prefect's Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 250574, name = "Prefect's Waistguard", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16728, name = "Lightforge Legplates", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16725, name = "Lightforge Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 22681, name = "Band of Piety", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272439, name = "Serenity Field", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 11811, name = "Smoking Heart of the Mountain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 20648, name = "Cold Forged Hammer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 276754, name = "Sunderbark Vigil", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272436, name = "Libram of Economy", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 12640, name = "Lionheart Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Necklace - Agility", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 22093, name = "Soulforge Spaulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 279269, name = "Fel Cape", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Agility", spell = "Enchant Cloak - Lesser Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 22089, name = "Soulforge Breastplate", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22088, name = "Soulforge Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Healing Power", spell = "Enchant Bracer - Healing Power", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 22090, name = "Soulforge Gauntlets", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 22086, name = "Soulforge Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 22087, name = "Soulforge Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 21182, name = "Band of Earthen Might", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19325, name = "Don Julio's Band", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 274759, name = "Everlook Pathcarver", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 12784, name = "Arcanite Reaper", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272435, name = "Libram of Law", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 16686, name = "Magister's Crown", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 15856, name = "Archlight Talisman", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Spell Power", spell = "Enchant Necklace - Spell Power", source = "" },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 16729, name = "Lightforge Spaulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18510, name = "Hide of the Wild", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Agility", spell = "Enchant Cloak - Lesser Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 16666, name = "Vest of Elements", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16722, name = "Lightforge Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Healing Power", spell = "Enchant Bracer - Healing Power", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16672, name = "Gauntlets of Elements", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Healing Power", spell = "Enchant Gloves - Healing Power", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16723, name = "Lightforge Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16687, name = "Magister's Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16682, name = "Magister's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Mystic Rugged Armor Kit", spell = "Mystic Rugged Armor Kit", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272407, name = "Blessed Band of Light", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272406, name = "Channeler's Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 270225, name = "Jewel of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 9449, name = "Manual Crowd Pummeler", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Mighty Spell Power", spell = "Enchant 2H Weapon - Mighty Spell Power", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 272435, name = "Libram of Law", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 250599, name = "Stalwart Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 275736, name = "Horn of Ve'han", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272745, name = "Premier Chevalier Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18413, name = "Cloak of Warding", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 250595, name = "Enriched Thorium Breastplate", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16722, name = "Lightforge Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 279264, name = "Heavy Thorium Gauntlets", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 22086, name = "Soulforge Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 279263, name = "Depleted Thorium Sabatons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 15855, name = "Ring of Protection", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272409, name = "Ring of Awareness", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 19024, name = "Arena Grand Master", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272440, name = "Defender's Grip Stabilizer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 18168, name = "Force Reactive Disk", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 14140, name = "Mooncloth Circlet", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22149, name = "Beads of Ogre Mojo", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 14139, name = "Mooncloth Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 19527, name = "Battle Healer's Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 10020, name = "Stormcloth Vest", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 254061, name = "Nethergeld Cuffs", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 254095, name = "Gilded Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 19047, name = "Wisdom of the Timbermaw", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 14137, name = "Mooncloth Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 275609, name = "Swarmtender's Footpads", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272439, name = "Serenity Field", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 249454, name = "Dreamstaff", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 249385, name = "Brilliant Wand", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 22005, name = "Darkmantle Cap", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21187, name = "Earthweave Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 22009, name = "Darkmantle Tunic", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Living Stats", spell = "Enchant Chest - Living Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22004, name = "Darkmantle Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21278, name = "Stormshroud Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272395, name = "Assassin's Waistguard", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22007, name = "Darkmantle Pants", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 18506, name = "Mongoose Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 21189, name = "Might of Cenarius", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 19324, name = "The Lobotomizer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 19166, name = "Black Amnesty", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 22005, name = "Darkmantle Cap", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21187, name = "Earthweave Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 22009, name = "Darkmantle Tunic", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Living Stats", spell = "Enchant Chest - Living Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22004, name = "Darkmantle Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21278, name = "Stormshroud Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272395, name = "Assassin's Waistguard", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22007, name = "Darkmantle Pants", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 18506, name = "Mongoose Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 21189, name = "Might of Cenarius", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 19324, name = "The Lobotomizer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 22005, name = "Darkmantle Cap", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 272105, name = "Darkspear Pauldrons", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 21187, name = "Earthweave Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 22009, name = "Darkmantle Tunic", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Living Stats", spell = "Enchant Chest - Living Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 22004, name = "Darkmantle Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21278, name = "Stormshroud Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272395, name = "Assassin's Waistguard", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22007, name = "Darkmantle Pants", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Lesser Arcane Amalgamation", spell = "Lesser Arcane Amalgamation", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 18506, name = "Mongoose Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Minor Speed", spell = "Enchant Boots - Minor Speed", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 19325, name = "Don Julio's Band", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 21189, name = "Might of Cenarius", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19120, name = "Rune of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 19324, name = "The Lobotomizer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Agility", spell = "Enchant Gloves - Superior Agility", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 16698, name = "Dreadmist Mask", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22149, name = "Beads of Ogre Mojo", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 16701, name = "Dreadmist Mantle", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 272413, name = "Drape of Recovery", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 14153, name = "Robe of the Void", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16703, name = "Dreadmist Bracers", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16705, name = "Dreadmist Wraps", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 16702, name = "Dreadmist Belt", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 16699, name = "Dreadmist Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 16704, name = "Dreadmist Sandals", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 275738, name = "Jereman's Bauble", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 19518, name = "Advisor's Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272438, name = "Weakness Analyzer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 270225, name = "Jewel of the Guard Captain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 22379, name = "Shivsprocket's Shiv", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand: held item",
              items = {
                { id = 249455, name = "Truesilver Conduit", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 15283, name = "Lunar Wand", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 12640, name = "Lionheart Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19491, name = "Amulet of the Darkmoon", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 10263, name = "Adventurer's Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10249, name = "Master's Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 10147, name = "Mighty Armsplints", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21998, name = "Gauntlets of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 272403, name = "Valiant's Waistguard", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21995, name = "Boots of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272409, name = "Ring of Awareness", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 249469, name = "Frozen Heart of the Mountain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 12784, name = "Arcanite Reaper", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
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
          title = "wowsims Arms Warrior preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12620, name = "Enchanted Thorium Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10148, name = "Mighty Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 11604, name = "Dark Iron Plate", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16735, name = "Bracers of Valor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21998, name = "Gauntlets of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 21994, name = "Belt of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21995, name = "Boots of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 18821, name = "Quick Strike Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Two-hand weapon",
              items = {
                { id = 12784, name = "Arcanite Reaper", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 16996, name = "Gorewood Bow", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 12640, name = "Lionheart Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 19491, name = "Amulet of the Darkmoon", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 10263, name = "Adventurer's Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18511, name = "Shifting Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 10147, name = "Mighty Armsplints", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Bracer - Agility", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21998, name = "Gauntlets of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 20216, name = "Belt of Preserved Heads", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 22385, name = "Titanic Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21995, name = "Boots of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272408, name = "Cutthroat's Signet", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272409, name = "Ring of Awareness", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 249469, name = "Frozen Heart of the Mountain", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 272437, name = "Adaptive Combat Assistant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 22384, name = "Persuader", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 12798, name = "Annihilator", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 22347, name = "Fahrad's Reloading Repeater", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
        raid1 = {
          title = "wowsims Fury Warrior preset (phase 1)",
          slots = {
            { slot = "Head",
              items = {
                { id = 12620, name = "Enchanted Thorium Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10148, name = "Mighty Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 11604, name = "Dark Iron Plate", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16735, name = "Bracers of Valor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 21998, name = "Gauntlets of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 21994, name = "Belt of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21995, name = "Boots of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 18821, name = "Quick Strike Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12774, name = "Dawn's Edge", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand",
              items = {
                { id = 17016, name = "Dark Iron Destroyer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 16996, name = "Gorewood Bow", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 10388, name = "Hyperion Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Neck",
              items = {
                { id = 22150, name = "Beads of Ogre Might", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 275737, name = "Hermit's Pauldron", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 18413, name = "Cloak of Warding", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Agility", spell = "Enchant Cloak - Agility", source = "" },
              },
            },
            { slot = "Chest",
              items = {
                { id = 252483, name = "Dawn Armor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Stats", spell = "Enchant Chest - Greater Stats", source = "" },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 10147, name = "Mighty Armsplints", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Superior Deflection", spell = "Enchant Bracer - Superior Deflection", source = "" },
              },
            },
            { slot = "Hands",
              items = {
                { id = 250552, name = "Sentinel's Gloves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Gloves - Greater Agility", source = "" },
              },
            },
            { slot = "Waist",
              items = {
                { id = 21994, name = "Belt of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 10389, name = "Hyperion Legplates", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Arcanum of Rapidity", spell = "Arcanum of Rapidity", source = "" },
              },
            },
            { slot = "Feet",
              items = {
                { id = 10376, name = "Commander's Boots", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Greater Agility", spell = "Enchant Bracer - Greater Agility", source = "" },
              },
            },
            { slot = "Finger",
              items = {
                { id = 272409, name = "Ring of Awareness", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 272440, name = "Defender's Grip Stabilizer", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12798, name = "Annihilator", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
              enchants = {
                { effect = "Crusader", spell = "Enchant Weapon - Crusader", source = "" },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 16998, name = "Sacred Protector", source = { kind = "unknown", text = "Source not listed by wowsims" } },
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
                { id = 12620, name = "Enchanted Thorium Helm", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Neck",
              items = {
                { id = 18404, name = "Onyxia Tooth Pendant", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Shoulder",
              items = {
                { id = 12625, name = "Dawnbringer Shoulders", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Back",
              items = {
                { id = 10148, name = "Mighty Cloak", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Chest",
              items = {
                { id = 11604, name = "Dark Iron Plate", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Wrist",
              items = {
                { id = 16735, name = "Bracers of Valor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Hands",
              items = {
                { id = 16737, name = "Gauntlets of Valor", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Waist",
              items = {
                { id = 21994, name = "Belt of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Legs",
              items = {
                { id = 12619, name = "Enchanted Thorium Leggings", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Feet",
              items = {
                { id = 21995, name = "Boots of Heroism", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Finger",
              items = {
                { id = 18879, name = "Heavy Dark Iron Ring", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 15855, name = "Ring of Protection", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Trinket",
              items = {
                { id = 10659, name = "Shard of the Splithooves", source = { kind = "unknown", text = "Source not listed by wowsims" } },
                { id = 10779, name = "Demon's Blood", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Main hand",
              items = {
                { id = 12774, name = "Dawn's Edge", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Off hand: shield",
              items = {
                { id = 16998, name = "Sacred Protector", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
            { slot = "Ranged",
              items = {
                { id = 16996, name = "Gorewood Bow", source = { kind = "unknown", text = "Source not listed by wowsims" } },
              },
            },
          },
        },
      },
    },
  },
}
