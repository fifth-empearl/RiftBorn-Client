ExtendedModals = ExtendedModals or {}

-- displayType: details, banner, optionsGrid, hybrid, sections.
ExtendedModals.defaultWindowWidth = 620
ExtendedModals.defaultBannerHeight = 110
ExtendedModals.defaultOptionsHeight = 300
ExtendedModals.defaultConfirmText = "Confirm"
ExtendedModals.defaultCloseText = "Close"

ExtendedModals.windowsConfig = {
	[1] = {
		name = "Ember Vault",
		displayType = "details",
		confirmText = "Enter",
		banner = {path = "images/banners/1", height = 110},
		rewards = {
			{name = "Experience", amount = 10000},
			{name = "Gold", amount = 10000, chance = 20},
			{name = "Honor Points", minAmount = 1, maxAmount = 3},
			{name = "Spell Points", minAmount = 1, maxAmount = 3, chance = 20},
		},
		itemRewards = {
			{itemId = 3043, amount = 10},
			{itemId = 22516, amount = 3, chance = 25},
			{itemId = 7643, minAmount = 1, maxAmount = 5},
			{itemId = 3048, amount = 1, chance = 10},
		},
		itemRequirements = {
			{itemId = 3043, amount = 10},
		},
		requirementsInfoPanel = "[color=#f5c105]Level: [/color][color=#ff4d4d]40[/color]\n"
			.. "[color=#f5c105]Party: [/color][color=#66ffff]1-3 players[/color]\n"
			.. "[color=#f5c105]Progress: [/color][color=#66ffff]Defeat the Ember Warden once[/color]\n"
			.. "[color=#f5c105]Lockout: [/color][color=#ff9933]20 hours[/color]",
		descriptionPanel = "Entry cost and reward preview.",
	},
	[2] = {
		name = "Trial of Heroes",
		displayType = "banner",
		width = 700,
		confirmText = "Accept",
		banner = {path = "images/banners/2", height = 460},
		descriptionPanel = "The trial is open. Enter when ready.",
	},
	[3] = {
		name = "Faction Choice",
		displayType = "optionsGrid",
		width = 680,
		confirmText = "Pick",
		optionsGrid = {
			title = "Choose a Side",
			subtitle = "This choice cannot be changed today.",
			mode = "single",
			maxChoices = 1,
			height = 220,
			cellSize = {width = 196, height = 140},
			entries = {
				{choiceId = "heaven", type = "image", image = "images/banners/heaven", label = "Heaven", description = "Sanctuary faction."},
				{choiceId = "hell", type = "image", image = "images/banners/hell", label = "Hell", description = "Infernal faction."},
				{choiceId = "neutral", type = "image", image = "images/rewards/default", label = "Neutral", description = "No faction bonus."},
			},
		},
		descriptionPanel = "Pick one faction for the next cycle.",
	},
	[4] = {
		name = "Bonus Reward",
		displayType = "hybrid",
		width = 720,
		confirmText = "Claim",
		banner = {path = "images/banners/1", height = 90},
		requirementsInfoPanel = "[color=#f5c105]Choice: [/color][color=#66ffff]One bonus reward[/color]\n"
			.. "[color=#f5c105]Available: [/color][color=#cc66ff]Items, outfits, mounts, forms[/color]",
		rewards = {
			{name = "Experience", amount = 50000},
			{name = "Gold", amount = 25000},
			{name = "Honor Points", amount = 5},
		},
		optionsGrid = {
			title = "Pick One Bonus",
			subtitle = "Choose the reward you want.",
			mode = "single",
			maxChoices = 1,
			height = 345,
			cellSize = {width = 123, height = 140},
			entries = {
				{choiceId = "crystal_bundle", type = "item", itemId = 3043, amount = 100, label = "Crystal Coins", description = "Spendable coins."},
				{choiceId = "silver_tokens", type = "item", itemId = 22516, amount = 25, label = "Silver Tokens", description = "Shop currency."},
				{choiceId = "spectral_pack", type = "item", itemId = 4840, amount = 5, label = "Spectral Stones", description = "Forge material."},
				{choiceId = "citizen_outfit", type = "creature", outfit = {type = 128}, label = "Citizen Outfit", description = "Outfit unlock."},
				{choiceId = "hunter_outfit", type = "creature", outfit = {type = 129}, label = "Hunter Outfit", description = "Outfit unlock."},
				{choiceId = "widow_mount", type = "creature", mountId = 1, outfit = {type = 128, mountLookType = 368}, label = "Widow Queen", description = "Mount unlock."},
				{choiceId = "damage_form", type = "item", itemId = 22721, amount = 1, label = "Damage Form", description = "Attack upgrade."},
				{choiceId = "defense_form", type = "item", itemId = 3081, amount = 1, label = "Defense Form", description = "Defense upgrade."},
				{choiceId = "utility_form", type = "item", itemId = 9058, amount = 1, label = "Utility Form", description = "Utility upgrade."},
			},
		},
		descriptionPanel = "Claim one bonus reward.",
	},
	[5] = {
		name = "Upgrade Path",
		displayType = "optionsGrid",
		width = 760,
		confirmText = "Unlock",
		optionsGrid = {
			title = "Select Path",
			subtitle = "Choose one upgrade track.",
			mode = "single",
			maxChoices = 1,
			height = 380,
			cellSize = {width = 166, height = 150},
			entries = {
				{choiceId = "ember_weapon", type = "image", image = "images/banners/hell", label = "Ember Weapon", description = "Fire damage."},
				{choiceId = "frost_guard", type = "image", image = "images/banners/2", label = "Frost Guard", description = "Defense."},
				{choiceId = "coin_mastery", type = "item", itemId = 3043, amount = 250, label = "Coin Mastery", description = "More gold."},
				{choiceId = "token_mastery", type = "item", itemId = 22516, amount = 50, label = "Token Mastery", description = "More tokens."},
				{choiceId = "spectral_mastery", type = "item", itemId = 4840, amount = 10, label = "Spectral Mastery", description = "More materials."},
				{choiceId = "swift_form", type = "creature", outfit = {type = 128, feet = 114}, label = "Swift Form", description = "Speed form."},
				{choiceId = "arcane_form", type = "creature", outfit = {type = 130, head = 95, body = 95, legs = 95, feet = 95}, label = "Arcane Form", description = "Magic form."},
				{choiceId = "guardian_form", type = "creature", outfit = {type = 131, head = 78, body = 69, legs = 58, feet = 76}, label = "Guardian Form", description = "Defense form."},
			},
		},
		descriptionPanel = "Unlock one account path.",
	},
	[6] = {
		name = "Weekly Claim",
		displayType = "sections",
		width = 740,
		confirmText = "Continue",
		sections = {
			{
				title = "Status",
				text = "[color=#f5c105]Tier: [/color][color=#66ffff]17[/color]\n"
					.. "[color=#f5c105]Track: [/color][color=#33cc33]Premium[/color]\n"
					.. "[color=#f5c105]Reset: [/color][color=#ff9933]Monday 06:00[/color]",
			},
			{
				title = "Rewards",
				rewards = {
					{name = "Experience", amount = 150000},
					{name = "Gold", amount = 65000},
				},
				itemRewards = {
					{itemId = 22516, amount = 15},
					{itemId = 7643, amount = 10},
				},
			},
			{
				title = "Bonus",
				optionsGrid = {
					mode = "single",
					maxChoices = 1,
					height = 260,
					cellSize = {width = 148, height = 166},
					entries = {
						{choiceId = "premium_tokens", type = "item", itemId = 22721, amount = 3, label = "Gold Tokens", description = "Currency."},
						{choiceId = "premium_mount", type = "creature", mountId = 2, outfit = {type = 128, mountLookType = 369}, label = "Racing Mount", description = "Mount."},
						{choiceId = "premium_utility", type = "item", itemId = 9058, amount = 1, label = "Utility Form", description = "Upgrade."},
					},
				},
			},
		},
		descriptionPanel = "Weekly rewards are ready.",
	},
}
