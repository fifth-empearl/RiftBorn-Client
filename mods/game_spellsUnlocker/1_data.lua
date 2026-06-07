SpellsUnlocker = SpellsUnlocker or {}

local function buildCostLines(cost)
	local lines = {}
	if tonumber(cost.gold) and tonumber(cost.gold) > 0 then
		lines[#lines + 1] = string.format("%s gold coins", cost.gold)
	end
	if tonumber(cost.SP) and tonumber(cost.SP) > 0 then
		lines[#lines + 1] = string.format("%s Spell Points", cost.SP)
	end
	for _, storageCost in ipairs(cost.storages or {}) do
		if tonumber(storageCost.amount) and tonumber(storageCost.amount) > 0 then
			lines[#lines + 1] = string.format("%s %s", storageCost.amount, storageCost.name or "storage points")
		end
	end
	for _, itemCost in ipairs(cost.items or {}) do
		if tonumber(itemCost.amount) and tonumber(itemCost.amount) > 0 then
			lines[#lines + 1] = string.format("%sx %s", itemCost.amount, itemCost.name or itemCost.itemid or itemCost.id or "item")
		end
	end
	if #lines == 0 then
		lines[#lines + 1] = "Free"
	end
	return table.concat(lines, "\n")
end

local function normalizeCost(costOrGold, spellPoints)
	if type(costOrGold) == "table" then
		return {
			gold = costOrGold.gold,
			SP = costOrGold.SP or costOrGold.spellPoints or costOrGold.sp,
			reqs = costOrGold.reqs or costOrGold.requirements,
			items = costOrGold.items,
			storages = costOrGold.storages or costOrGold.storage,
		}
	end

	return {
		gold = costOrGold,
		SP = spellPoints,
	}
end

local function spell(name, words, level, mana, spellType, description, costOrGold, spellPoints)
	local cost = normalizeCost(costOrGold, spellPoints)
	return {
		name = name,
		words = words,
		level = level,
		magicLevel = 0,
		manaCost = mana,
		spellType = spellType,
		description = description,
		costDesc = buildCostLines(cost),
		cost = cost,
	}
end

-- spellType is displayed in the spell list and description.
-- Examples: Single Target, AoE, Delayed AoE, Beam, DoT, Self Heal, Target Heal, AoE Heal, HoT, Cleanse, Buff, Avatar Buff, Shield Buff, Haste Buff, Utility, Rune Conjure, Ammo Conjure, Field Rune, Debuff Rune.
--
-- Cost supports the shorthand spell(..., gold, spellPoints) and a table:
-- {gold = 30000, SP = 35, reqs = {{key = 84451, value = 2, name = "knights rage quest"}}, items = {{itemid = 22516, amount = 2, name = "silver tokens"}}, storages = {{key = 5151, amount = 10, name = "Honor Points"}}}
-- reqs are checked but not consumed. items, storages, gold, and SP are consumed when the spell is learned.
local function category(name, spells)
	return { name = name, spells = spells }
end

local function attackCategory(spells)
	return category("Attack", spells)
end

local function supportCategory(spells)
	return category("Support", spells)
end

local function healingCategory(spells)
	return category("Healing", spells)
end

local function conjuringCategory(spells)
	return category("Conjuring", spells)
end

SpellsUnlocker.data = {
	[1] = {
		name = "Sorcerer",
		categories = {
			attackCategory({
				spell("Great Death Beam", "exevo max mort", 300, 140, "Beam", "Fires a powerful death beam in front of the caster.", 300000, 15),
				spell("Rage of the Skies", "exevo gran mas vis", 60, 600, "AoE", "Calls down a wide storm of energy damage.", 180000, 10),
				spell("Hell's Core", "exevo gran mas flam", 60, 1100, "AoE", "Releases a massive fire explosion around the caster.", 180000, 10),
				spell("Ultimate Energy Strike", "exori gran vis", 100, 100, "Single Target", "Strikes one target with concentrated energy.", 150000, 8),
			}),
			supportCategory({
				spell("Avatar of Storm", "uteta res ven", 300, 2200, "Avatar Buff", "Temporarily empowers the sorcerer with storm avatar effects.", 600000, 25),
				spell("Magic Shield", "utamo vita", 14, 50, "Shield Buff", "Converts incoming damage to mana while active.", 75000, 5),
				spell("Invisibility", "utana vid", 35, 440, "Utility", "Turns the caster invisible for a short time.", 125000, 7),
			}),
			healingCategory({
				spell("Intense Healing", "exura gran", 20, 70, "Self Heal", "Restores a moderate amount of health.", 65000, 4),
				spell("Ultimate Healing", "exura vita", 30, 160, "Self Heal", "Restores a large amount of health.", 125000, 8),
				spell("Mass Healing", "exura gran mas res", 36, 150, "AoE Heal", "Heals nearby allies in an area.", 150000, 9),
			}),
			conjuringCategory({
				spell("Sudden Death Rune", "adori gran mort", 45, 985, "Rune Conjure", "Creates a rune that deals heavy death damage.", 175000, 10),
				spell("Great Fireball Rune", "adori mas flam", 30, 530, "Rune Conjure", "Creates a rune that explodes in a fire area.", 125000, 8),
				spell("Magic Wall Rune", "adevo grav tera", 32, 750, "Field Rune", "Creates a rune that places a temporary magic wall.", 175000, 10),
				spell("Fire Bomb Rune", "adevo mas flam", 27, 600, "Field Rune", "Creates a rune that spreads burning fields.", 100000, 7),
			}),
		},
	},
	[2] = {
		name = "Druid",
		categories = {
			attackCategory({
				spell("Ice Burst", "exevo ulus frigo", 300, 230, "AoE", "Unleashes a burst of ice damage around the target area.", 350000, 18),
				spell("Terra Burst", "exevo ulus tera", 300, 230, "AoE", "Unleashes a burst of earth damage around the target area.", 350000, 18),
				spell("Eternal Winter", "exevo gran mas frigo", 60, 1050, "AoE", "Freezes enemies around the caster with a powerful ice storm.", 180000, 10),
				spell("Wrath of Nature", "exevo gran mas tera", 55, 700, "AoE", "Calls nature damage over a wide area.", 180000, 10),
			}),
			supportCategory({
				spell("Avatar of Nature", "uteta res dru", 300, 2200, "Avatar Buff", "Temporarily empowers the druid with nature avatar effects.", 600000, 25),
				spell("Strong Haste", "utani gran hur", 20, 100, "Haste Buff", "Greatly increases movement speed for a short time.", 80000, 5),
				spell("Creature Illusion", "utevo res ina", 23, 100, "Utility", "Temporarily disguises the caster as a creature.", 80000, 5),
			}),
			healingCategory({
				spell("Heal Friend", "exura sio", 18, 140, "Target Heal", "Heals a selected ally from a distance.", 90000, 6),
				spell("Mass Healing", "exura gran mas res", 36, 150, "AoE Heal", "Heals nearby allies in an area.", 150000, 9),
				spell("Heal Placeholder", "placeholder example", 1, 0, "AoE Heal Large", "Heals nearby allies in an area.", {
					gold = 50000,
					SP = 3,
					reqs = {
						{ key = 84451, value = 2, name = "knights rage quest" },
					},
					items = {
						{ itemid = 22516, amount = 2, name = "silver tokens" },
					},
					storages = {
						{ key = 5151, amount = 5, name = "Honor Points" },
					},
				}),
				spell("Heal Placeholder B", "placeholder example b", 1, 0, "AoE Heal small", "Heals nearby allies in an area.", {
					gold = 75000,
					SP = 4,
					reqs = {
						{ key = 84452, value = 1, name = "monster healer trial" },
					},
					items = {
						{ itemid = 22721, amount = 1, name = "gold token" },
					},
					storages = {
						{ key = 5151, amount = 10, name = "Honor Points" },
					},
				}),
			}),
			conjuringCategory({
				spell("Avalanche Rune", "adori mas frigo", 30, 530, "Rune Conjure", "Creates a rune that explodes in an ice area.", 125000, 8),
				spell("Wild Growth Rune", "adevo grav vita", 27, 600, "Field Rune", "Creates a rune that grows temporary blocking vegetation.", 175000, 10),
				spell("Paralyze Rune", "adana ani", 54, 1400, "Debuff Rune", "Creates a rune that heavily slows one target.", 200000, 12),
				spell("Stone Shower Rune", "adori mas tera", 28, 430, "Rune Conjure", "Creates a rune that damages an area with earth.", 125000, 8),
			}),
		},
	},
	[3] = {
		name = "Knight",
		categories = {
			attackCategory({
				spell("Executioner's Throw", "exori amp kor", 300, 225, "Single Target", "Throws a heavy executioner's strike at the enemy.", 350000, 18),
				spell("Groundshaker", "exori mas", 33, 160, "AoE", "Slams the ground to damage nearby enemies.", 125000, 7),
				spell("Fierce Berserk", "exori gran", 90, 340, "AoE", "Performs a stronger melee area strike.", 175000, 10),
				spell("Annihilation", "exori gran ico", 110, 300, "Single Target", "Delivers a devastating single target blow.", 225000, 12),
			}),
			supportCategory({
				spell("Avatar of Steel", "uteta res eq", 300, 800, "Avatar Buff", "Temporarily empowers the knight with steel avatar effects.", 600000, 25),
				spell("Blood Rage", "utito tempo", 60, 290, "Buff", "Increases melee offense while reducing defense.", 150000, 9),
				spell("Protector", "utamo tempo", 55, 200, "Shield Buff", "Raises defense while reducing offensive output.", 150000, 9),
			}),
			healingCategory({
				spell("Wound Cleansing", "exana kor", 30, 65, "Cleanse", "Cleanses wounds and restores health.", 90000, 6),
				spell("Intense Wound Cleansing", "exana gran kor", 80, 200, "Self Heal", "Restores more health and cleanses wounds.", 150000, 9),
			}),
			conjuringCategory({
				spell("Conjure Arrow", "exevo con", 13, 100, "Ammo Conjure", "Creates a small bundle of arrows.", 50000, 3),
				spell("Conjure Bolt", "exevo con mort", 17, 140, "Ammo Conjure", "Creates a small bundle of bolts.", 60000, 4),
			}),
		},
	},
	[4] = {
		name = "Paladin",
		categories = {
			attackCategory({
				spell("Divine Grenade", "exevo tempo mas san", 300, 160, "Delayed AoE", "Throws a holy grenade that detonates after a short delay.", 350000, 18),
				spell("Divine Caldera", "exevo mas san", 50, 160, "AoE", "Calls holy damage over enemies around the caster.", 150000, 9),
				spell("Ethereal Spear", "exori con", 23, 25, "Single Target", "Launches a magical spear at one target.", 75000, 5),
				spell("Strong Ethereal Spear", "exori gran con", 90, 55, "Single Target", "Launches a stronger magical spear at one target.", 150000, 9),
			}),
			supportCategory({
				spell("Divine Empowerment", "utevo grav san", 300, 500, "Buff", "Empowers the paladin with divine force.", 450000, 20),
				spell("Avatar of Light", "uteta res sac", 300, 1500, "Avatar Buff", "Temporarily empowers the paladin with light avatar effects.", 600000, 25),
				spell("Sharpshooter", "utito tempo san", 60, 450, "Buff", "Increases distance fighting while reducing movement speed.", 150000, 9),
			}),
			healingCategory({
				spell("Divine Healing", "exura san", 35, 210, "Self Heal", "Restores health with holy energy.", 125000, 8),
				spell("Salvation", "exura gran san", 60, 210, "Self Heal", "Restores a larger amount of health with holy energy.", 175000, 10),
				spell("Cure Bleeding", "exana kor", 45, 30, "Cleanse", "Removes bleeding and restores minor health.", 75000, 5),
			}),
			conjuringCategory({
				spell("Conjure Arrow", "exevo con", 13, 100, "Ammo Conjure", "Creates a small bundle of arrows.", 50000, 3),
				spell("Conjure Bolt", "exevo con mort", 17, 140, "Ammo Conjure", "Creates a small bundle of bolts.", 60000, 4),
				spell("Conjure Power Bolt", "exevo con vis", 59, 700, "Ammo Conjure", "Creates power bolts for ranged combat.", 125000, 8),
				spell("Conjure Royal Star", "exevo gran con hur", 90, 1000, "Ammo Conjure", "Creates royal stars for ranged combat.", 175000, 10),
			}),
		},
	},
	[5] = {
		name = "Monk",
		categories = {
			attackCategory({
				spell("Mystic Repulse", "exori amp pug", 30, 150, "AoE", "Repels nearby enemies with a focused mystic strike.", 100000, 8),
				spell("Forceful Uppercut", "exori gran pug", 110, 325, "Single Target", "Delivers a strong uppercut attack.", 250000, 14),
				spell("Spiritual Outburst", "exori gran mas nia", 0, 425, "AoE", "Releases spiritual energy in a wide outburst.", 350000, 18),
				spell("Flurry of Blows", "exori mas pug", 45, 180, "AoE", "Unleashes a rapid series of close-range strikes.", 125000, 7),
			}),
			supportCategory({
				spell("Focus Harmony", "utevo nia", 275, 500, "Buff", "Focuses the monk's inner harmony.", 450000, 20),
				spell("Avatar of Balance", "uteta res tio", 300, 1200, "Avatar Buff", "Temporarily empowers the monk with balance avatar effects.", 600000, 25),
				spell("Balanced Brawl", "utito tempo pug", 60, 250, "Buff", "Balances offense and defense during close combat.", 150000, 9),
			}),
			healingCategory({
				spell("Restore Balance", "exura nia", 75, 180, "Self Heal", "Restores health by re-centering the monk's balance.", 150000, 9),
				spell("Spirit Mend", "exura gran nia", 140, 320, "Self Heal", "Repairs wounds with focused spirit energy.", 225000, 12),
				spell("Mass Spirit Mend", "exura mas nia", 180, 450, "AoE Heal", "Mends nearby allies with spirit energy.", 275000, 14),
			}),
			conjuringCategory({
				spell("Light Magic Missile Rune", "adori min vis", 15, 120, "Rune Conjure", "Creates a light magic missile rune.", 50000, 3),
				spell("Heavy Magic Missile Rune", "adori vis", 25, 350, "Rune Conjure", "Creates a stronger magic missile rune.", 90000, 6),
				spell("Stalagmite Rune", "adori tera", 24, 400, "Rune Conjure", "Creates a single-target earth rune.", 90000, 6),
			}),
		},
	},
}
