local combatStates= {
	CLIENT_COMBAT_PHYSICAL = 0,
	CLIENT_COMBAT_FIRE = 1,
	CLIENT_COMBAT_EARTH = 2,
	CLIENT_COMBAT_ENERGY = 3,
	CLIENT_COMBAT_ICE = 4,
	CLIENT_COMBAT_HOLY = 5,
	CLIENT_COMBAT_DEATH = 6,
	CLIENT_COMBAT_HEALING = 7,
	CLIENT_COMBAT_DROWN = 8,
	CLIENT_COMBAT_LIFEDRAIN = 9,
	CLIENT_COMBAT_MANADRAIN = 10,
}

Cyclopedia.clientCombat ={}
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_PHYSICAL] = { path = '/game_cyclopedia/images/bestiary/icons/monster-icon-physical-resist', id = 'Physical' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_FIRE] = {  path = '/game_cyclopedia/images/bestiary/icons/monster-icon-fire-resist', id = 'Fire' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_EARTH] = { path = '/game_cyclopedia/images/bestiary/icons/monster-icon-earth-resist', id = 'Earth' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_ENERGY] = {  path = '/game_cyclopedia/images/bestiary/icons/monster-icon-energy-resist', id = 'Energy' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_ICE] = { path = '/game_cyclopedia/images/bestiary/icons/monster-icon-ice-resist', id = 'Ice' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_HOLY] = {path = '/game_cyclopedia/images/bestiary/icons/monster-icon-holy-resist', id = 'Holy' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_DEATH] = {  path = '/game_cyclopedia/images/bestiary/icons/monster-icon-death-resist', id = 'Death' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_HEALING] = { path = '/game_cyclopedia/images/bestiary/icons/monster-icon-healing-resist', id = 'Healing' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_DROWN] = {  path = '/game_cyclopedia/images/bestiary/icons/monster-icon-drowning-resist', id = 'Drown' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_LIFEDRAIN] = {  path = '/game_cyclopedia/images/bestiary/icons/monster-icon-lifedrain-resist', id = 'Lifedrain ' }
Cyclopedia.clientCombat[combatStates.CLIENT_COMBAT_MANADRAIN] = {  path = '/game_cyclopedia/images/bestiary/icons/monster-icon-manadrain-resist', id = 'Manadrain' }
