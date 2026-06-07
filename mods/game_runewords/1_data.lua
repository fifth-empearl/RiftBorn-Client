RuneWords = RuneWords or {}
-- Shared RuneWords data.
-- This file is intentionally server/client compatible: copy it to the client module
-- when rune names, item ids, colors, combinations, or displayed buff values change.
--
-- Supported buff forms:
--   Storage:
--     {type = "storage", name = "BuffX", storage = "RuneWords.xBuffStorage", value = 5}
--
--   "CONDITION_ATTRIBUTES":
--     Supports skill/stat/crit/leech/damage/healing/element absorb/increase params.
--     Example:
--     {type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}
--
--   "CONDITION_HASTE":
--     Requires "CONDITION_PARAM_SPEED".
--     Example:
--     {type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 40}}}
--
--   "CONDITION_REGENERATION":
--     Requires gain and tick pairs, e.g. HEALTHGAIN/HEALTHTICKS or MANAGAIN/MANATICKS.
--     Example:
--     {type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 20}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000}, {param = "CONDITION_PARAM_MANAGAIN", value = 10}, {param = "CONDITION_PARAM_MANATICKS", value = 3000}}}
--
--   "CONDITION_MANASHIELD":
--     Requires "CONDITION_PARAM_MANASHIELD".
--     Example:
--     {type = "condition", name = "Mana Shield", conditionType = "CONDITION_MANASHIELD", params = {{param = "CONDITION_PARAM_MANASHIELD", value = 300}}}
--
RuneWords.runeConfig = {
	[1] = {
		name = "Kur", 
		itemId = 11603, 
		buffs = {
			{type = "storage", name = "BuffX", storage = "RuneWords.xBuffStorage", value = 5},
		},
		color = "#5DBCD2",
	},
	[2] = {
		name = "Hur", 
		itemId = 11604, 
		buffs = {
			{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 40}}},
		},
		color = "#5DBCD2",
	},
	[3] = {
		name = "Pelo", 
		itemId = 11605, 
		buffs = {
			{
				type = "condition",
				name = "Regeneration",
				conditionType = "CONDITION_REGENERATION",
				params = {
					{param = "CONDITION_PARAM_HEALTHGAIN", value = 20},
					{param = "CONDITION_PARAM_HEALTHTICKS", value = 3000},
					{param = "CONDITION_PARAM_MANAGAIN", value = 10},
					{param = "CONDITION_PARAM_MANATICKS", value = 3000}
				}
			},
		},
		color = "#BC68D0",
	},
	[4] = {
		name = "Nar", 
		itemId = 11606, 
		buffs = {
			{type = "condition", name = "Mana Shield", conditionType = "CONDITION_MANASHIELD", params = {{param = "CONDITION_PARAM_MANASHIELD", value = 300}}},
		},
		color = "#BC68D0",
	},
	[5] = {
		name = "Zam", 
		itemId = 11607, 
		buffs = {
			{type = "storage", name = "BuffX", storage = "RuneWords.xBuffStorage", value = 5},
		},
		color = "#BC68D0",
	},
	[6] = {
		name = "Thal", 
		itemId = 11608, 
		buffs = {
			{type = "storage", name = "BuffY", storage = "RuneWords.yBuffStorage", value = 5},
		},
		color = "#BC68D0",
	},
	[7] = {
		name = "Vira", 
		itemId = 11609, 
		buffs = {
			{type = "storage", name = "BuffY", storage = "RuneWords.yBuffStorage", value = 5},
		},
		color = "#B0B0B0",
	},
	[8] = {
		name = "Bora", 
		itemId = 11610, 
		buffs = {
			{type = "storage", name = "BuffY", storage = "RuneWords.yBuffStorage", value = 5},
		},
		color = "#B0B0B0",
	},
	[9] = {
		name = "Rao", 
		itemId = 11611, 
		buffs = {
			{type = "storage", name = "BuffY", storage = "RuneWords.yBuffStorage", value = 5},
		},
		color = "#E7B866",
	},
	[10] = {
		name = "Juna", 
		itemId = 11612, 
		buffs = {
			{type = "storage", name = "BuffY", storage = "RuneWords.yBuffStorage", value = 5},
		},
		color = "#E7B866",
	},
	[11] = {
		name = "Zera", 
		itemId = 11613, 
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
		},
		color = "#BC68D0",
	},
	[12] = {
		name = "Tera", 
		itemId = 11614, 
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
		},
		color = "#BC68D0",
	},
	[13] = {
		name = "Kal", 
		itemId = 11615, 
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
		},
		color = "#f54242",
	},
	[14] = {
		name = "Xor", 
		itemId = 11616, 
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
		},
		color = "#f54242",
	},
	[15] = {
		name = "Sura", 
		itemId = 11617, 
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
		},
		color = "#f54242",
	},
	[16] = {
		name = "Gel", 
		itemId = 11618, 
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
		},
		color = "#f54242",
	},
	[17] = {
		name = "Taz", 
		itemId = 11619, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#BC68D0",
	},
	[18] = {
		name = "Von", 
		itemId = 11620, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#BC68D0",
	},
	[19] = {
		name = "Mur", 
		itemId = 11621, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#5DBCD2",
	},
	[20] = {
		name = "Xan", 
		itemId = 11622, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#5DBCD2",
	},
	[21] = {
		name = "Tor", 
		itemId = 11623, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#5DBCD2",
	},
	[22] = {
		name = "Sal", 
		itemId = 11624, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#5DBCD2",
	},
	[23] = {
		name = "Jor", 
		itemId = 11625, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#E7B866",
	},
	[24] = {
		name = "Lin", 
		itemId = 11626, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#E7B866",
	},
	[25] = {
		name = "Nel", 
		itemId = 11627,
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#B0B0B0",
	},
	[26] = {
		name = "Vik", 
		itemId = 11628, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#B0B0B0",
	},
	[27] = {
		name = "Kaz", 
		itemId = 11629, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#67D5D2",
	},
	[28] = {
		name = "Eril", 
		itemId = 11630, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#67D5D2",
	},
	[29] = {
		name = "Xyro", 
		itemId = 11631, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#BC68D0",
	},
	[30] = {
		name = "Yorn", 
		itemId = 11632, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#BC68D0",
	},
	[31] = {
		name = "Vel", 
		itemId = 11633, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#99C77F",
	},
	[32] = {
		name = "Drak",
		itemId = 11634, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#99C77F",
	},
	[33] = {
		name = "Thol", 
		itemId = 11635, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#67D5D2",
	},
	[34] = {
		name = "Uzar", 
		itemId = 11636, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#67D5D2",
	},
	[35] = {
		name = "Gar", 
		itemId = 11637, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#f54242",
	},
	[36] = {
		name = "Loch", 
		itemId = 11638, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#f54242",
	},
	[37] = {
		name = "Pyra", 
		itemId = 11639, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#B0B0B0",
	},
	[38] = {
		name = "Tek", 
		itemId = 11640, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#B0B0B0",
	},
	[39] = {
		name = "Zhar", 
		itemId = 11641, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#5DBCD2",
	},
	[40] = {
		name = "Gran", 
		itemId = 11642, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#5DBCD2",
	},
	[41] = {
		name = "Rith", 
		itemId = 11643, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#f54242",
	},
	[42] = {
		name = "Jark", 
		itemId = 11644, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#f54242",
	},
	[43] = {
		name = "Zent", 
		itemId = 11645, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#99C77F",
	},
	[44] = {
		name = "Volk", 
		itemId = 11646, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#99C77F",
	},
	[45] = {
		name = "Ner", 
		itemId = 11647, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#99C77F",
	},
	[46] = {
		name = "Sok", 
		itemId = 11648, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#99C77F",
	},
	[47] = {
		name = "Tarn", 
		itemId = 11649, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#f54242",
	},
	[48] = {
		name = "Uld", 
		itemId = 11650, 
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#f54242",
	}
}

RuneWords.runeWordsCombinations = {
	{
		runes = {1, 2, 3, 5},
		runewordName = "Harmony",
		buffs = {
			{type = "storage", name = "BuffZ", storage = "RuneWords.zBuffStorage", value = 5},
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#7bcc6e",
	},
	{
		runes = {39, 31, 4, 6},
		runewordName = "Halo",
		buffs = {
			{type = "storage", name = "BuffX", storage = "RuneWords.xBuffStorage", value = 5},
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#00BFFF",
	},
	{
		runes = {21, 48, 44, 18},
		runewordName = "Chaos",
		buffs = {
			{type = "storage", name = "BuffY", storage = "RuneWords.yBuffStorage", value = 5},
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#FF4500",
	},
	{
		runes = {33, 26, 10, 23},
		runewordName = "Eclipse",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#9370DB",
	},
	{
		runes = {7, 20, 11, 15},
		runewordName = "Aegis",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#FFD700",
	},
	{
		runes = {27, 12, 19, 32},
		runewordName = "Wrath",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#DC143C",
	},
	{
		runes = {8, 14, 16, 37},
		runewordName = "Storm",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#00FA9A",
	},
	{
		runes = {13, 22, 29, 34},
		runewordName = "Valor",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#8B4513",
	},
	{
		runes = {25, 35, 38, 40},
		runewordName = "Fury",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#FF6347",
	},
	{
		runes = {9, 17, 24, 28},
		runewordName = "Glory",
		buffs = {
			{type = "condition", name = "Critical Amount", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
		},
		color = "#4682B4",
	}
}


