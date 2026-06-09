Talents = Talents or {}

Talents.trees = {
	[1] = {
		key = "sorc_arcane_core", name = "Arcane Core", background = "backgrounds/sorc_arcane_core", categoryIcon = "trees/sorc_arcane_core",
		{name = "Focus Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Spark Focus", icon = "nodes/spark_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Mana Channel", icon = "nodes/mana_channel", description = "Example percent stat reward: max mana.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Critical Ember", icon = "nodes/critical_ember", description = "Example critical reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
			{name = "Spark Focus2", icon = "nodes/spark_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Mana Channel2", icon = "nodes/mana_channel", description = "Example percent stat reward: max mana.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Critical Ember2", icon = "nodes/critical_ember", description = "Example critical reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
			{name = "Spark Focus3", icon = "nodes/spark_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Mana Channel3", icon = "nodes/mana_channel", description = "Example percent stat reward: max mana.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Critical Ember3", icon = "nodes/critical_ember", description = "Example critical reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
		}},
		{name = "Tempo Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Flame Pressure", icon = "nodes/flame_pressure", description = "Example storage-backed reward readable by other scripts.", maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Arcane Speed", icon = "nodes/arcane_speed", description = "Example haste condition reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 7}}}}},
			{name = "Mind Reserve", icon = "nodes/mind_reserve", description = "Example mana regeneration reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Mana Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 4}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
		}},
		{name = "Survival Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Rune Ward", icon = "nodes/rune_ward", description = "Example percent health reward.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Mana Recovery", icon = "nodes/mana_recovery", description = "Example combined regeneration reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}, {param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Arcane Seal", icon = "nodes/arcane_seal", description = "Example placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Arcane Pulse"}}},
		}},
		{name = "Focus Line2", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Spark Focus", icon = "nodes/spark_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Mana Channel", icon = "nodes/mana_channel", description = "Example percent stat reward: max mana.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Critical Ember", icon = "nodes/critical_ember", description = "Example critical reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
			{name = "Spark Focus2", icon = "nodes/spark_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Mana Channel2", icon = "nodes/mana_channel", description = "Example percent stat reward: max mana.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Critical Ember2", icon = "nodes/critical_ember", description = "Example critical reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
			{name = "Spark Focus3", icon = "nodes/spark_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Mana Channel3", icon = "nodes/mana_channel", description = "Example percent stat reward: max mana.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Critical Ember3", icon = "nodes/critical_ember", description = "Example critical reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
		}},
	},
	[2] = {
		key = "sorc_inferno_weave", name = "Inferno Weave", background = "backgrounds/sorc_inferno_weave", categoryIcon = "trees/sorc_inferno_weave",
		{name = "Ember Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Ember Skin", icon = "nodes/ember_skin", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Burning Mind", icon = "nodes/burning_mind", description = "Placeholder magic scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Scorching Crit", icon = "nodes/scorching_crit", description = "Placeholder critical damage scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
		}},
		{name = "Ash Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Pyro Stride", icon = "nodes/pyro_stride", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Ash Barrier", icon = "nodes/ash_barrier", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Inferno Word", icon = "nodes/inferno_word", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Inferno Word"}}},
		}},
		{name = "Heat Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Heat Vessel", icon = "nodes/heat_vessel", description = "Placeholder max mana scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Cinder Renewal", icon = "nodes/cinder_renewal", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Flame Seal", icon = "nodes/flame_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[3] = {
		key = "sorc_storm_rites", name = "Storm Rites", background = "backgrounds/sorc_storm_rites", categoryIcon = "trees/sorc_storm_rites",
		{name = "Static Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Static Focus", icon = "nodes/static_focus", description = "Placeholder magic scaling.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Storm Step", icon = "nodes/storm_step", description = "Placeholder speed scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Charged Crit", icon = "nodes/charged_crit", description = "Placeholder critical chance scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
		}},
		{name = "Current Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Air Current", icon = "nodes/air_current", description = "Placeholder storage reward.", maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Skyward Mana", icon = "nodes/skyward_mana", description = "Placeholder max mana scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Storm Call", icon = "nodes/storm_call", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Storm Call"}}},
		}},
		{name = "Cloud Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Cloud Guard", icon = "nodes/cloud_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Lightning Recovery", icon = "nodes/lightning_recovery", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Mana Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 4}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Storm Seal", icon = "nodes/storm_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
		}},
	},
	[4] = {
		key = "druid_verdant_circle", name = "Verdant Circle", background = "backgrounds/druid_verdant_circle", categoryIcon = "trees/druid_verdant_circle",
		{name = "Root Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Root Focus", icon = "nodes/root_focus", description = "Example flat stat reward: magic level.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Leaf Mending", icon = "nodes/leaf_mending", description = "Example health regeneration reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Nature Guard", icon = "nodes/nature_guard", description = "Example percent health reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
		}},
		{name = "Wild Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Wild Stride", icon = "nodes/wild_stride", description = "Example speed reward.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 7}}}}},
			{name = "Spirit Sap", icon = "nodes/spirit_sap", description = "Example storage-backed reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Verdant Mana", icon = "nodes/verdant_mana", description = "Example percent mana reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
		}},
		{name = "Bloom Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Bloom Skin", icon = "nodes/bloom_skin", description = "Example storage-backed reward.", maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Grove Renewal", icon = "nodes/grove_renewal", description = "Example combined regeneration reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}, {param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Grove Call", icon = "nodes/grove_call", description = "Example placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Grove Call"}}},
		}},
	},
	[5] = {
		key = "druid_lunar_spring", name = "Lunar Spring", background = "backgrounds/druid_lunar_spring", categoryIcon = "trees/druid_lunar_spring",
		{name = "Moon Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Moon Focus", icon = "nodes/moon_focus", description = "Placeholder magic scaling.", maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Quiet Waters", icon = "nodes/quiet_waters", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Mana Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 4}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Lunar Crit", icon = "nodes/lunar_crit", description = "Placeholder critical chance scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
		}},
		{name = "Spring Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Spring Renewal", icon = "nodes/spring_renewal", description = "Placeholder health regeneration.", maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Tide Step", icon = "nodes/tide_step", description = "Placeholder speed scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Moonlit Word", icon = "nodes/moonlit_word", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Moonlit Word"}}},
		}},
		{name = "Mist Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Mist Guard", icon = "nodes/mist_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Silver Reserve", icon = "nodes/silver_reserve", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Moon Seal", icon = "nodes/moon_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[6] = {
		key = "druid_thorn_ward", name = "Thorn Ward", background = "backgrounds/druid_thorn_ward", categoryIcon = "trees/druid_thorn_ward",
		{name = "Thorn Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Thorn Skin", icon = "nodes/thorn_skin", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Barbed Focus", icon = "nodes/barbed_focus", description = "Placeholder magic scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Magic Level", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_STAT_MAGICPOINTS", value = 1}}}}},
			{name = "Bramble Crit", icon = "nodes/bramble_crit", description = "Placeholder critical damage scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
		}},
		{name = "Briar Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Thorn Step", icon = "nodes/thorn_step", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Seed Reserve", icon = "nodes/seed_reserve", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Thorn Call", icon = "nodes/thorn_call", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Thorn Call"}}},
		}},
		{name = "Grove Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Bark Guard", icon = "nodes/bark_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Briar Recovery", icon = "nodes/briar_recovery", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Thorn Seal", icon = "nodes/thorn_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[7] = {
		key = "archer_hawkeye_path", name = "Hawkeye Path", background = "backgrounds/archer_hawkeye_path", categoryIcon = "trees/archer_hawkeye_path",
		{name = "Aim Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Steady Aim", icon = "nodes/steady_aim", description = "Example flat stat reward: distance.", maxLevel = 5, effect = {{type = "condition", name = "Distance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_DISTANCE", value = 1}}}}},
			{name = "Keen Eye", icon = "nodes/keen_eye", description = "Example critical chance reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
			{name = "Arrow Flow", icon = "nodes/arrow_flow", description = "Example storage-backed reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
		}},
		{name = "Nock Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Quick Nock", icon = "nodes/quick_nock", description = "Example speed reward.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 7}}}}},
			{name = "Field Stride", icon = "nodes/field_stride", description = "Example health regeneration reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Quiver Focus", icon = "nodes/quiver_focus", description = "Example percent mana reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
		}},
		{name = "Range Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Range Guard", icon = "nodes/range_guard", description = "Example percent health reward.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Hunter Recovery", icon = "nodes/hunter_recovery", description = "Example storage-backed reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "True Mark", icon = "nodes/true_mark", description = "Example placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "True Mark"}}},
		}},
	},
	[8] = {
		key = "archer_wild_runner", name = "Wild Runner", background = "backgrounds/archer_wild_runner", categoryIcon = "trees/archer_wild_runner",
		{name = "Trail Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Trail Step", icon = "nodes/trail_step", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Hunter Breath", icon = "nodes/hunter_breath", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Wild Crit", icon = "nodes/wild_crit", description = "Placeholder critical chance scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
		}},
		{name = "Runner Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Long Stride", icon = "nodes/long_stride", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Stamina Leaf", icon = "nodes/stamina_leaf", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Wild Call", icon = "nodes/wild_call", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Wild Call"}}},
		}},
		{name = "Scout Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Scout Guard", icon = "nodes/scout_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Path Recovery", icon = "nodes/path_recovery", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Mana Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 4}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Runner Seal", icon = "nodes/runner_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[9] = {
		key = "archer_trickshot_craft", name = "Trickshot Craft", background = "backgrounds/archer_trickshot_craft", categoryIcon = "trees/archer_trickshot_craft",
		{name = "Ricochet Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Ricochet Eye", icon = "nodes/ricochet_eye", description = "Placeholder distance scaling.", maxLevel = 5, effect = {{type = "condition", name = "Distance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_DISTANCE", value = 1}}}}},
			{name = "Trick Draw", icon = "nodes/trick_draw", description = "Placeholder speed scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Pierce Crit", icon = "nodes/pierce_crit", description = "Placeholder critical damage scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
		}},
		{name = "Snap Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Snap Step", icon = "nodes/snap_step", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Focus Quiver", icon = "nodes/focus_quiver", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Trickshot Mark", icon = "nodes/trickshot_mark", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Trickshot Mark"}}},
		}},
		{name = "Craft Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Craft Guard", icon = "nodes/craft_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Trick Recovery", icon = "nodes/trick_recovery", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Trickshot Seal", icon = "nodes/trickshot_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[10] = {
		key = "knight_iron_vanguard", name = "Iron Vanguard", background = "backgrounds/knight_iron_vanguard", categoryIcon = "trees/knight_iron_vanguard",
		{name = "Iron Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Iron Skin", icon = "nodes/iron_skin", description = "Example percent health reward.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Shield Memory", icon = "nodes/shield_memory", description = "Example shielding reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Shielding", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_SHIELD", value = 1}}}}},
			{name = "Vital Reserve", icon = "nodes/vital_reserve", description = "Example storage-backed reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
		}},
		{name = "Guard Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Guard Focus", icon = "nodes/guard_focus", description = "Example melee skill reward.", maxLevel = 5, effect = {{type = "condition", name = "Melee Skill", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_MELEE", value = 1}}}}},
			{name = "Heavy Stance", icon = "nodes/heavy_stance", description = "Example critical damage reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
			{name = "Steel Recovery", icon = "nodes/steel_recovery", description = "Example health regeneration reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
		}},
		{name = "Wall Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Wall Guard", icon = "nodes/wall_guard", description = "Example storage-backed reward.", maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Iron Recovery", icon = "nodes/iron_recovery", description = "Example speed reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 5}}}}},
			{name = "Vanguard Oath", icon = "nodes/vanguard_oath", description = "Example placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Vanguard Oath"}}},
		}},
	},
	[11] = {
		key = "knight_warbreaker", name = "Warbreaker", background = "backgrounds/knight_warbreaker", categoryIcon = "trees/knight_warbreaker",
		{name = "Weapon Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Heavy Swing", icon = "nodes/heavy_swing", description = "Placeholder melee scaling.", maxLevel = 5, effect = {{type = "condition", name = "Melee Skill", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_MELEE", value = 1}}}}},
			{name = "Break Guard", icon = "nodes/break_guard", description = "Placeholder critical chance scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
			{name = "Critical Weight", icon = "nodes/critical_weight", description = "Placeholder critical damage scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
		}},
		{name = "War Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "War Stride", icon = "nodes/war_stride", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 5}}}}},
			{name = "Weapon Memory", icon = "nodes/weapon_memory", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Warbreaker Call", icon = "nodes/warbreaker_call", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Warbreaker Call"}}},
		}},
		{name = "Breaker Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Breaker Guard", icon = "nodes/breaker_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "War Recovery", icon = "nodes/war_recovery", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Warbreaker Seal", icon = "nodes/warbreaker_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[12] = {
		key = "knight_bastion_oath", name = "Bastion Oath", background = "backgrounds/knight_bastion_oath", categoryIcon = "trees/knight_bastion_oath",
		{name = "Stone Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Stone Heart", icon = "nodes/stone_heart", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Bastion Skin", icon = "nodes/bastion_skin", description = "Placeholder shielding scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Shielding", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_SHIELD", value = 1}}}}},
			{name = "Oath Focus", icon = "nodes/oath_focus", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
		}},
		{name = "Oath Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Shield Pace", icon = "nodes/shield_pace", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 5}}}}},
			{name = "Enduring Core", icon = "nodes/enduring_core", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Health Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 3}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}}}}},
			{name = "Bastion Word", icon = "nodes/bastion_word", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Bastion Word"}}},
		}},
		{name = "Keep Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Keep Guard", icon = "nodes/keep_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Bastion Recovery", icon = "nodes/bastion_recovery", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Bastion Seal", icon = "nodes/bastion_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[13] = {
		key = "monk_flowing_body", name = "Flowing Body", background = "backgrounds/monk_flowing_body", categoryIcon = "trees/monk_flowing_body",
		{name = "Body Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Centered Body", icon = "nodes/centered_body", description = "Example flat stat reward: fist skill.", maxLevel = 5, effect = {{type = "condition", name = "Fist", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_FIST", value = 1}}}}},
			{name = "Flowing Step", icon = "nodes/flowing_step", description = "Example speed reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 7}}}}},
			{name = "Precise Strike", icon = "nodes/precise_strike", description = "Example critical damage reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
		}},
		{name = "Palm Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Palm Focus", icon = "nodes/palm_focus", description = "Example storage-backed reward.", maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Inner Current", icon = "nodes/inner_current", description = "Example combined regeneration reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}, {param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Body Reserve", icon = "nodes/body_reserve", description = "Example percent health reward.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
		}},
		{name = "Breath Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Breath Guard", icon = "nodes/breath_guard", description = "Example storage-backed reward.", maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Flow Reserve", icon = "nodes/flow_reserve", description = "Example percent mana reward.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Swift Jab", icon = "nodes/swift_jab", description = "Example placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Swift Jab"}}},
		}},
	},
	[14] = {
		key = "monk_spirit_palm", name = "Spirit Palm", background = "backgrounds/monk_spirit_palm", categoryIcon = "trees/monk_spirit_palm",
		{name = "Spirit Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Spirit Reserve", icon = "nodes/spirit_reserve", description = "Placeholder mana scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Calm Focus", icon = "nodes/calm_focus", description = "Placeholder fist scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Fist", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_FIST", value = 1}}}}},
			{name = "Balanced Strike", icon = "nodes/balanced_strike", description = "Placeholder critical chance scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Critical Chance", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 1}}}}},
		}},
		{name = "Serene Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Serene Step", icon = "nodes/serene_step", description = "Placeholder speed scaling.", maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Inner Mana", icon = "nodes/inner_mana", description = "Placeholder regeneration scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Mana Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_MANAGAIN", value = 4}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Serenity Word", icon = "nodes/serenity_word", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Serenity Word"}}},
		}},
		{name = "Soul Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Soul Guard", icon = "nodes/soul_guard", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Calm Reserve", icon = "nodes/calm_reserve", description = "Placeholder storage reward.", prevTalentLevelNeeded = 1, maxLevel = 10, effect = {{type = "storage", name = "BuffY", storageKey = "BuffY", value = 1}}},
			{name = "Spirit Seal", icon = "nodes/spirit_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
	[15] = {
		key = "monk_silent_mastery", name = "Silent Mastery", background = "backgrounds/monk_silent_mastery", categoryIcon = "trees/monk_silent_mastery",
		{name = "Discipline Line", color = "#ad1109", border = "/images/ui/borders/43", talents = {
			{name = "Rooted Stance", icon = "nodes/rooted_stance", description = "Placeholder health scaling.", maxLevel = 5, effect = {{type = "condition", name = "Max Health", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 1}}}}},
			{name = "Silent Step", icon = "nodes/silent_step", description = "Placeholder speed scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Speed", conditionType = "CONDITION_HASTE", params = {{param = "CONDITION_PARAM_SPEED", value = 6}}}}},
			{name = "Disciplined Palm", icon = "nodes/disciplined_palm", description = "Placeholder fist scaling.", prevTalentLevelNeeded = 2, maxLevel = 5, effect = {{type = "condition", name = "Fist", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_FIST", value = 1}}}}},
		}},
		{name = "Harmony Line", color = "#4f9ec4", border = "/images/ui/borders/44", talents = {
			{name = "Harmony Breath", icon = "nodes/harmony_breath", description = "Placeholder regeneration scaling.", maxLevel = 5, effect = {{type = "condition", name = "Regeneration", conditionType = "CONDITION_REGENERATION", params = {{param = "CONDITION_PARAM_HEALTHGAIN", value = 2}, {param = "CONDITION_PARAM_HEALTHTICKS", value = 3000, scale = false}, {param = "CONDITION_PARAM_MANAGAIN", value = 2}, {param = "CONDITION_PARAM_MANATICKS", value = 3000, scale = false}}}}},
			{name = "Quiet Force", icon = "nodes/quiet_force", description = "Placeholder critical damage scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Critical Damage", conditionType = "CONDITION_ATTRIBUTES", params = {{param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE", value = 1}}}}},
			{name = "Mastery Word", icon = "nodes/mastery_word", description = "Placeholder spell unlock.", prevTalentLevelNeeded = 2, maxLevel = 1, effect = {{type = "spell", name = "Mastery Word"}}},
		}},
		{name = "Mastery Line", color = "#6aa85f", border = "/images/ui/borders/45", talents = {
			{name = "Master Guard", icon = "nodes/master_guard", description = "Placeholder storage reward.", maxLevel = 10, effect = {{type = "storage", name = "BuffX", storageKey = "BuffX", value = 1}}},
			{name = "Quiet Reserve", icon = "nodes/quiet_reserve", description = "Placeholder mana scaling.", prevTalentLevelNeeded = 1, maxLevel = 5, effect = {{type = "condition", name = "Max Mana", conditionType = "CONDITION_ATTRIBUTES", percent = true, params = {{param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 1}}}}},
			{name = "Mastery Seal", icon = "nodes/mastery_seal", description = "Placeholder storage reward.", prevTalentLevelNeeded = 2, maxLevel = 10, effect = {{type = "storage", name = "BuffZ", storageKey = "BuffZ", value = 1}}},
		}},
	},
}
