ProgressiveTasks = ProgressiveTasks or {}

ProgressiveTasks.maxActiveTasks = 3
ProgressiveTasks.npcAccessed = false
ProgressiveTasks.taskPrestigeRankTable = {    -- Rank level is calculated from the player's KV-backed total task prestige exp.
	[0] = {
		name = "-",
		exp = 0,
		rewards = {}
	},
	[1] = {
		name = "Iron 1",
		exp = 100,
		rewards = {
			{type = "Gold", amount = 1000},
			{type = "Exp", amount = 5000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 5},
					{id = 5152, name = "Spell Points", amount = 5},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 1}, -- 1 crystal coin
					{id = 3028, amount = 5}, -- 5 small diamonds
					{id = 3035, amount = 10} -- 10 platinum coins
				}
			}
		}
	},
	[2] = {
		name = "Iron 2",
		exp = 210,
		rewards = {
			{type = "Gold", amount = 1500},
			{type = "Exp", amount = 7500},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 10},
					{id = 5152, name = "Spell Points", amount = 10},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 2}, -- 2 crystal coins
					{id = 3030, amount = 5}, -- 5 small rubies
					{id = 3035, amount = 15} -- 15 platinum coins
				}
			}
		}
	},
	[3] = {
		name = "Iron 3",
		exp = 320,
		rewards = {
			{type = "Gold", amount = 2000},
			{type = "Exp", amount = 10000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 15},
					{id = 5152, name = "Spell Points", amount = 15},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 3}, -- 3 crystal coins
					{id = 3032, amount = 5}, -- 5 small emeralds
					{id = 3035, amount = 20} -- 20 platinum coins
				}
			}
		}
	},
	[4] = {
		name = "Bronze 1",
		exp = 430,
		rewards = {
			{type = "Gold", amount = 3000},
			{type = "Exp", amount = 15000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 20},
					{id = 5152, name = "Spell Points", amount = 20},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 5}, -- 5 crystal coins
					{id = 3035, amount = 25}, -- 25 platinum coins
					{id = 3360, amount = 1} -- 1 crown armor
				}
			}
		}
	},
	[5] = {
		name = "Bronze 2",
		exp = 540,
		rewards = {
			{type = "Gold", amount = 4000},
			{type = "Exp", amount = 20000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 25},
					{id = 5152, name = "Spell Points", amount = 25},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 7}, -- 7 crystal coins
					{id = 3035, amount = 30}, -- 30 platinum coins
					{id = 3392, amount = 1} -- 1 crown helmet
				}
			}
		}
	},
	[6] = {
		name = "Bronze 3",
		exp = 650,
		rewards = {
			{type = "Gold", amount = 5000},
			{type = "Exp", amount = 25000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 30},
					{id = 5152, name = "Spell Points", amount = 30},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 10}, -- 10 crystal coins
					{id = 3035, amount = 35}, -- 35 platinum coins
					{id = 3364, amount = 1} -- 1 crown legs
				}
			}
		}
	},
	[7] = {
		name = "Silver 1",
		exp = 760,
		rewards = {
			{type = "Gold", amount = 6000},
			{type = "Exp", amount = 30000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 35},
					{id = 5152, name = "Spell Points", amount = 35},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 15}, -- 15 crystal coins
					{id = 3035, amount = 40}, -- 40 platinum coins
					{id = 3416, amount = 1} -- 1 crown shield
				}
			}
		}
	},
	[8] = {
		name = "Silver 2",
		exp = 880,
		rewards = {
			{type = "Gold", amount = 7000},
			{type = "Exp", amount = 35000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 40},
					{id = 5152, name = "Spell Points", amount = 40},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 20}, -- 20 crystal coins
					{id = 3035, amount = 45}, -- 45 platinum coins
					{id = 7402, amount = 1} -- 1 giant sword
				}
			}
		}
	},
	[9] = {
		name = "Silver 3",
		exp = 1000,
		rewards = {
			{type = "Gold", amount = 8000},
			{type = "Exp", amount = 40000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 45},
					{id = 5152, name = "Spell Points", amount = 45},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 25}, -- 25 crystal coins
					{id = 3035, amount = 50}, -- 50 platinum coins
					{id = 7382, amount = 1} -- 1 magic longsword
				}
			}
		}
	},
	[10] = {
		name = "Gold 1",
		exp = 1150,
		rewards = {
			{type = "Gold", amount = 10000},
			{type = "Exp", amount = 50000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 50},
					{id = 5152, name = "Spell Points", amount = 50},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 30}, -- 30 crystal coins
					{id = 3035, amount = 60}, -- 60 platinum coins
					{id = 3318, amount = 1} -- 1 war hammer
				}
			}
		}
	},
	[11] = {
		name = "Gold 2",
		exp = 1300,
		rewards = {
			{type = "Gold", amount = 12000},
			{type = "Exp", amount = 60000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 55},
					{id = 5152, name = "Spell Points", amount = 55},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 35}, -- 35 crystal coins
					{id = 3035, amount = 70}, -- 70 platinum coins
					{id = 3360, amount = 1}, -- 1 knight armor
					{id = 3027, amount = 1} -- 1 giant shimmering pearl
				}
			}
		}
	},
	[12] = {
		name = "Gold 3",
		exp = 1450,
		rewards = {
			{type = "Gold", amount = 14000},
			{type = "Exp", amount = 70000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 60},
					{id = 5152, name = "Spell Points", amount = 60},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 40}, -- 40 crystal coins
					{id = 3035, amount = 80}, -- 80 platinum coins
					{id = 3364, amount = 1}, -- 1 knight legs
					{id = 3032, amount = 1} -- 1 giant topaz
				}
			}
		}
	},
	[13] = {
		name = "Platinum 1",
		exp = 1650,
		rewards = {
			{type = "Gold", amount = 16000},
			{type = "Exp", amount = 80000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 65},
					{id = 5152, name = "Spell Points", amount = 65},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 50}, -- 50 crystal coins
					{id = 3035, amount = 90}, -- 90 platinum coins
					{id = 3392, amount = 1}, -- 1 knight helmet
					{id = 3029, amount = 1} -- 1 giant sapphire
				}
			}
		}
	},
	[14] = {
		name = "Platinum 2",
		exp = 1850,
		rewards = {
			{type = "Gold", amount = 18000},
			{type = "Exp", amount = 90000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 70},
					{id = 5152, name = "Spell Points", amount = 70},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 60}, -- 60 crystal coins
					{id = 3035, amount = 100}, -- 100 platinum coins
					{id = 3318, amount = 1}, -- 1 knight axe
					{id = 3033, amount = 1} -- 1 giant amethyst
				}
			}
		}
	},
	[15] = {
		name = "Platinum 3",
		exp = 2050,
		rewards = {
			{type = "Gold", amount = 20000},
			{type = "Exp", amount = 100000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 75},
					{id = 5152, name = "Spell Points", amount = 75},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 70}, -- 70 crystal coins
					{id = 3035, amount = 110}, -- 110 platinum coins
					{id = 3416, amount = 1}, -- 1 knight shield
					{id = 3032, amount = 1} -- 1 giant emerald
				}
			}
		}
	},
	[16] = {
		name = "Diamond 1",
		exp = 2300,
		rewards = {
			{type = "Gold", amount = 25000},
			{type = "Exp", amount = 120000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 80},
					{id = 5152, name = "Spell Points", amount = 80},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 80}, -- 80 crystal coins
					{id = 3035, amount = 120}, -- 120 platinum coins
					{id = 3386, amount = 1}, -- 1 dragon scale mail
					{id = 3030, amount = 1} -- 1 giant ruby
				}
			}
		}
	},
	[17] = {
		name = "Diamond 2",
		exp = 2550,
		rewards = {
			{type = "Gold", amount = 30000},
			{type = "Exp", amount = 140000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 85},
					{id = 5152, name = "Spell Points", amount = 85},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 90}, -- 90 crystal coins
					{id = 3035, amount = 130}, -- 130 platinum coins
					{id = 3416, amount = 1}, -- 1 dragon shield
					{id = 3032, amount = 1} -- 1 giant topaz
				}
			}
		}
	},
	[18] = {
		name = "Diamond 3",
		exp = 2800,
		rewards = {
			{type = "Gold", amount = 35000},
			{type = "Exp", amount = 160000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 90},
					{id = 5152, name = "Spell Points", amount = 90},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 100}, -- 100 crystal coins
					{id = 3035, amount = 140}, -- 140 platinum coins
					{id = 7429, amount = 1}, -- 1 dragon hammer
					{id = 3029, amount = 1} -- 1 giant sapphire
				}
			}
		}
	},
	[19] = {
		name = "Ascendant 1",
		exp = 3100,
		rewards = {
			{type = "Gold", amount = 40000},
			{type = "Exp", amount = 180000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 95},
					{id = 5152, name = "Spell Points", amount = 95},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 120}, -- 120 crystal coins
					{id = 3035, amount = 150}, -- 150 platinum coins
					{id = 7402, amount = 1}, -- 1 dragon slayer
					{id = 3033, amount = 1} -- 1 giant amethyst
				}
			}
		}
	},
	[20] = {
		name = "Ascendant 2",
		exp = 3400,
		rewards = {
			{type = "Gold", amount = 45000},
			{type = "Exp", amount = 200000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 100},
					{id = 5152, name = "Spell Points", amount = 100},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 150}, -- 150 crystal coins
					{id = 3035, amount = 160}, -- 160 platinum coins
					{id = 3277, amount = 1}, -- 1 dragon lance
					{id = 3032, amount = 1} -- 1 giant emerald
				}
			}
		}
	},
	[21] = {
		name = "Ascendant 3",
		exp = 3700,
		rewards = {
			{type = "Gold", amount = 50000},
			{type = "Exp", amount = 220000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 110},
					{id = 5152, name = "Spell Points", amount = 110},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 180}, -- 180 crystal coins
					{id = 3035, amount = 170}, -- 170 platinum coins
					{id = 8092, amount = 1}, -- 1 dragonbone staff
					{id = 3030, amount = 1} -- 1 giant ruby
				}
			}
		}
	},
	[22] = {
		name = "Immortal 1",
		exp = 4100,
		rewards = {
			{type = "Gold", amount = 60000},
			{type = "Exp", amount = 250000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 120},
					{id = 5152, name = "Spell Points", amount = 120},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 200}, -- 200 crystal coins
					{id = 3035, amount = 180}, -- 180 platinum coins
					{id = 3360, amount = 1}, -- 1 crown armor
					{id = 3028, amount = 1} -- 1 giant diamond
				}
			}
		}
	},
	[23] = {
		name = "Immortal 2",
		exp = 4500,
		rewards = {
			{type = "Gold", amount = 70000},
			{type = "Exp", amount = 280000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 130},
					{id = 5152, name = "Spell Points", amount = 130},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 250}, -- 250 crystal coins
					{id = 3035, amount = 190}, -- 190 platinum coins
					{id = 3392, amount = 1}, -- 1 crown helmet
					{id = 3027, amount = 1} -- 1 giant pearl
				}
			}
		}
	},
	[24] = {
		name = "Immortal 3",
		exp = 4900,
		rewards = {
			{type = "Gold", amount = 80000},
			{type = "Exp", amount = 300000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 140},
					{id = 5152, name = "Spell Points", amount = 140},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 300}, -- 300 crystal coins
					{id = 3035, amount = 200}, -- 200 platinum coins
					{id = 3364, amount = 1}, -- 1 crown legs
					{id = 3032, amount = 1} -- 1 giant topaz
				}
			}
		}
	},
	[25] = {
		name = "Radiant",
		exp = 10000,
		rewards = {
			{type = "Gold", amount = 100000},
			{type = "Exp", amount = 500000},
			{
				type = "storages",
				storages = {
					{id = 5151, name = "Honor Points", amount = 200},
					{id = 5152, name = "Spell Points", amount = 200},
				}
			},
			{
				type = "items",
				items = {
					{id = 3043, amount = 500}, -- 500 crystal coins
					{id = 3035, amount = 300}, -- 300 platinum coins
					{id = 3416, amount = 1}, -- 1 crown shield
					{id = 3029, amount = 1} -- 1 giant sapphire
				}
			}
		}
	},
}


ProgressiveTasks.tasksConfig = {
	[1] = {
		name = "We all start somewhere",
		levelReq = 10,
		repeatable = false,
		repeatableCD = 0, -- in minutes
		rewardBagId = 2854, -- backpack used for item rewards
		task = {
			{type = "kills", amount = 60, monsters = {"Rat", "Cave Rat"}},		-- 60 total kills of 'rats' and, or 'cave rats'
			{type = "kills", amount = 20, monsters = {"Rotworm"}},		-- 20 total kills of 'rotworms'
			{type = "items", amount = 10, itemsIds = {"3492"}}, -- worm
			{type = "items", amount = 25, itemsIds = {"3031"}}, -- gold coin
		},
		rewards = {
			{type = "Task Prestige Exp", amount = 5},
			{type = "Gold", amount = 1000},
			{type = "Exp", amount = 10000},
			{type = "storages", storages = {
				{id = 5151, name = "Honor Points", minAmount = 5, maxAmount = 10, chance = 5000}, -- 50% chance to add between 5-10 Honor Points storage
				{id = 5152, name = "Spell Points", amount = 5},
				}},
			{type = "items", items = {
				{id = 3035, minAmount = 1, maxAmount = 3, chance = 5000}, -- platinum coin
				{id = 3492, amount = 5}, -- worm
				}},
		},
	},
	[2] = {
		name = "Let the Journey Begin",
		levelReq = 100, -- Requires level 100 and completion of the previous task atleast once
		storagesReqs = {{id = 5157, value = 2, name = "finish 2nd quest from Terax"}, {id = 5158, value = 1, name = "kill X boss atleast once"}},
		repeatable = true,
		repeatableCD = 0.5,
		task = {
			{type = "kills", amount = 50, monsters = {"Minotaur", "Minotaur Mage", "Minotaur Archer"}},
			{type = "kills", amount = 30, monsters = {"Cyclops", "Cyclops Smith"}},
			{type = "items", amount = 20, itemsIds = {"11472"}}, -- minotaur horn
			{type = "items", amount = 10, itemsIds = {"9657"}}, -- cyclops toe
		},
		rewards = {
			{type = "Task Prestige Exp", amount = 10},
			{type = "Gold", amount = 2000},
			{type = "Exp", amount = 20000},
			{type = "storages", storages = {
				{id = 5151, name = "Honor Points", minAmount = 10, maxAmount = 20, chance = 6000},
				{id = 5152, name = "Spell Points", amount = 10},
			}},
			{type = "items", items = {
				{id = 3043, amount = 1, chance = 4000}, -- crystal coin
				{id = 5880, amount = 1, chance = 2000},
			}},
		},
	},
	[3] = {
		name = "The Hunt for Greater Prey",
		levelReq = 150,
		repeatable = true,
		repeatableCD = 180,
		task = {
			{type = "kills", amount = 40, monsters = {"Dragon", "Dragon Lord"}},
			{type = "kills", amount = 30, monsters = {"Demon"}},
			{type = "items", amount = 15, itemsIds = {"5877", "5948"}}, -- dragon leather
			{type = "items", amount = 5, itemsIds = {"5906"}}, -- demon dust
		},
		rewards = {
			{type = "Task Prestige Exp", amount = 15},
			{type = "Gold", amount = 5000},
			{type = "Exp", amount = 50000},
			{type = "storages", storages = {
				{id = 5151, name = "Honor Points", minAmount = 10, maxAmount = 20, chance = 7000},
				{id = 5152, name = "Spell Points", amount = 10},
			}},
			{type = "items", items = {
				{id = 3043, minAmount = 1, maxAmount = 3, chance = 3000}, -- crystal coin
				{id = 3416, amount = 1}, -- dragon shield
			}},
		},
	},
	[4] = {
		name = "A Real Challenge",
		levelReq = 200,
		repeatable = true,
		repeatableCD = 240,
		task = {
			{type = "kills", amount = 50, monsters = {"Behemoth", "Frost Dragon"}},
			{type = "kills", amount = 20, monsters = {"Hydra"}},
			{type = "items", amount = 10, itemsIds = {"5930"}}, -- behemoth claw
			{type = "items", amount = 5, itemsIds = {"10282"}}, -- hydra head
		},
		rewards = {
			{type = "Task Prestige Exp", amount = 20},
			{type = "Gold", amount = 10000},
			{type = "Exp", amount = 100000},
			{type = "storages", storages = {
				{id = 5151, name = "Honor Points", minAmount = 20, maxAmount = 30, chance = 8000},
				{id = 5152, name = "Spell Points", amount = 20},
			}},
			{type = "items", items = {
				{id = 3043, minAmount = 1, maxAmount = 2, chance = 2000}, -- crystal coin
				{id = 3420, amount = 1}, -- demon shield
			}},
		},
	},
	[5] = {
		name = "The Shadow's Grasp",
		levelReq = 250,
		repeatable = false,
		repeatableCD = 0,
		task = {
			{type = "kills", amount = 50, monsters = {"Nightstalker", "Shadow Hound"}},
			{type = "kills", amount = 30, monsters = {"Banshee"}},
			{type = "items", amount = 15, itemsIds = {"11446"}}, -- hair of a banshee
			{type = "items", amount = 10, itemsIds = {"20274"}}, -- nightmare horn
		},
		rewards = {
			{type = "Task Prestige Exp", amount = 25},
			{type = "Gold", amount = 15000},
			{type = "Exp", amount = 150000},
			{type = "storages", storages = {
				{id = 5151, name = "Honor Points", minAmount = 25, maxAmount = 35, chance = 7000},
				{id = 5152, name = "Spell Points", amount = 25},
			}},
			{type = "items", items = {
				{id = 6390, amount = 1}, -- nightmare shield
				{id = 6499, minAmount = 1, maxAmount = 3, chance = 5000}, -- demonic essence
			}},
		},
	},
	[6] = {
		name = "The Titan's Wrath",
		levelReq = 300,
		repeatable = true,
		repeatableCD = 360,
		task = {
			{type = "kills", amount = 40, monsters = {"Giant Spider", "Ancient Scarab"}},
			{type = "kills", amount = 20, monsters = {"Stone Devourer"}},
			{type = "items", amount = 15, itemsIds = {"9631", "9641"}}, -- scarab loot
			{type = "items", amount = 5, itemsIds = {"16138"}}, -- crystalline spikes
		},
		rewards = {
			{type = "Task Prestige Exp", amount = 30},
			{type = "Gold", amount = 20000},
			{type = "Exp", amount = 200000},
			{type = "storages", storages = {
				{id = 5151, name = "Honor Points", minAmount = 30, maxAmount = 40, chance = 8000},
				{id = 5152, name = "Spell Points", amount = 30},
			}},
			{type = "items", items = {
				{id = 16161, amount = 1}, -- crystalline axe
				{id = 16128, minAmount = 1, maxAmount = 2, chance = 4000}, -- minor crystalline token
			}},
		},
	},
}
