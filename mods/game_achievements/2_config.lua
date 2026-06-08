AchievementsRewardConfig = {
	byAchievementId = {
		[513] = {
			experience = 50000,
			gold = 250000,
			items = {
				{ id = 3043, count = 25, name = "crystal coins" },
			},
			storages = {
				{ key = 45000, value = 3, name = "Achievement Prestige" },
				{ key = 45001, value = 1, name = "Soul Mender Legacy" },
			},
			buffs = {
				{
					name = "Soul Mender's Resolve",
					conditionType = "CONDITION_ATTRIBUTES",
					params = {
						{ param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 110, label = "+10% maximum health" },
						{ param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 110, label = "+10% maximum mana" },
						{ param = "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE", value = 2, label = "+2 critical chance" },
					},
				},
				{
					name = "Soul Recovery",
					conditionType = "CONDITION_REGENERATION",
					params = {
						{ param = "CONDITION_PARAM_HEALTHGAIN", value = 8, label = "+8 health regeneration" },
						{ param = "CONDITION_PARAM_HEALTHTICKS", value = 2000, label = "health regen every 2s" },
						{ param = "CONDITION_PARAM_MANAGAIN", value = 8, label = "+8 mana regeneration" },
						{ param = "CONDITION_PARAM_MANATICKS", value = 2000, label = "mana regen every 2s" },
					},
				},
				{
					name = "Soul Momentum",
					conditionType = "CONDITION_HASTE",
					haste = 40,
					label = "+40 speed",
				},
			},
		},
	},
	defaultRewardsByGrade = {
		[1] = {
			experience = 1000,
			gold = 5000,
		},
		[2] = {
			experience = 2500,
			gold = 12500,
		},
		[3] = {
			experience = 7500,
			gold = 35000,
			buffs = {
				{
					name = "Achievement Focus",
					conditionType = "CONDITION_REGENERATION",
					params = {
						{ param = "CONDITION_PARAM_HEALTHGAIN", value = 2, label = "+2 health regeneration" },
						{ param = "CONDITION_PARAM_HEALTHTICKS", value = 4000, label = "health regen every 4s" },
						{ param = "CONDITION_PARAM_MANAGAIN", value = 2, label = "+2 mana regeneration" },
						{ param = "CONDITION_PARAM_MANATICKS", value = 4000, label = "mana regen every 4s" },
					},
				},
			},
		},
		[4] = {
			experience = 25000,
			gold = 100000,
			items = {
				{ id = 3043, count = 10, name = "crystal coins" },
			},
			storages = {
				{ key = 45000, value = 1, name = "Achievement Prestige" },
			},
			buffs = {
				{
					name = "Achievement Heroism",
					conditionType = "CONDITION_ATTRIBUTES",
					params = {
						{ param = "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT", value = 105, label = "+5% maximum health" },
						{ param = "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT", value = 105, label = "+5% maximum mana" },
					},
				},
				{
					name = "Achievement Momentum",
					conditionType = "CONDITION_HASTE",
					haste = 20,
					label = "+20 speed",
				},
			},
		},
	},
}
