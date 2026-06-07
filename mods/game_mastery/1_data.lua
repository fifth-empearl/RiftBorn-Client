Mastery = Mastery or {}
-- Shared Mastery data.
--
-- Supported effect forms:
--   Capacity:
--     {type = "capacity", name = "Capacity", value = 30}
--
--   "CONDITION_ATTRIBUTES":
--     Supports skill/stat/crit/etc params. Add percent = true for max health/mana percent params.
--     Example:
--     {type = "condition", name = "Melee Skill", everyLevels = 2, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_MELEE", value = 5}}}
--
--   "CONDITION_REGENERATION":
--     Supports health/mana gain and tick params.
--     Example:
--     {type = "condition", name = "Mana Regeneration", everyLevels = 2, conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 2000}}}
--
--   "CONDITION_HASTE":
--     Use haste = true and value for speed formula.
--     Example:
--     {type = "condition", name = "Movement Speed", everyLevels = 2, haste = true, conditionType = "CONDITION_HASTE", value = 6}

Mastery.masteryOrder = {"Strength", "Intelligence", "Dexterity", "Defense", "Endurance"}

Mastery.displayResetCost = {
	gold = 10000,
	items = {
		{id = 4840, name = "spectral stone", amount = 2},
	},
	storages = {
		{name = "task points", amount = 10},
	},
}

Mastery.masteriesConfig = {
	Strength = {
		badge = "images/masteryBadges/01",
		effectsDescription = {
			{"+5 melee skill every 2 levels"},
			{"+1 critical damage every 3 levels"},
			{"+30 capacity per level"},
		},
		color = "#a88d32",
		effects = {
			{type = "condition", name = "Melee Skill", everyLevels = 2, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_MELEE", value = 5}}},
			{type = "condition", name = "Critical Damage", everyLevels = 3, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}},
			{type = "capacity", name = "Capacity", value = 30},
		},
	},
	Intelligence = {
		badge = "images/masteryBadges/10",
		effectsDescription = {
			{"+1 magic level every 2 levels"},
			{"+2 mana every 2 seconds every 2 levels"},
			{"+1% maximum mana every 5 levels"},
		},
		color = "#8132a8",
		effects = {
			{type = "condition", name = "Magic Level", everyLevels = 2, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}},
			{type = "condition", name = "Mana Regeneration", everyLevels = 2, conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 2000}}},
			{type = "condition", name = "Maximum Mana", everyLevels = 5, percent = true, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}},
		},
	},
	Dexterity = {
		badge = "images/masteryBadges/08",
		effectsDescription = {
			{"+4 distance skill every 2 levels"},
			{"+1 critical chance every 3 levels"},
			{"+6 movement speed every 2 levels"},
		},
		color = "#5832a8",
		effects = {
			{type = "condition", name = "Distance Skill", everyLevels = 2, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_DISTANCE", value = 4}}},
			{type = "condition", name = "Critical Chance", everyLevels = 3, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}},
			{type = "condition", name = "Movement Speed", everyLevels = 2, haste = true, conditionType = "CONDITION_HASTE", value = 6},
		},
	},
	Defense = {
		badge = "images/masteryBadges/04",
		effectsDescription = {
			{"+4 shielding every 2 levels"},
			{"+1% maximum health every 5 levels"},
			{"+2 health every 2 seconds every 2 levels"},
		},
		color = "#eddb64",
		effects = {
			{type = "condition", name = "Shielding", everyLevels = 2, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_SHIELD", value = 4}}},
			{type = "condition", name = "Maximum Health", everyLevels = 5, percent = true, conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}},
			{type = "condition", name = "Health Regeneration", everyLevels = 2, conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 2000}}},
		},
	},
	Endurance = {
		badge = "images/masteryBadges/07",
		effectsDescription = {
			{"+35 capacity per level"},
			{"+3 health every 2 seconds every 2 levels"},
			{"+2 mana every 2 seconds every 3 levels"},
		},
		color = "#64dfed",
		effects = {
			{type = "capacity", name = "Capacity", value = 35},
			{type = "condition", name = "Health Regeneration", everyLevels = 2, conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 2000}}},
			{type = "condition", name = "Mana Regeneration", everyLevels = 3, conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 2000}}},
		},
	},
}
