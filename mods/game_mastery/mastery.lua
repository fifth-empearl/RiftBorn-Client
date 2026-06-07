
Mastery.opCode = 24
Mastery.totalPointsColor = "#f54242"
Mastery.availablePointsColor = "#42b9f5"


local function getMasteryConstantName(value)
	return type(value) == "string" and value or tostring(value)
end

local function isRegenGainParam(param)
	local paramName = getMasteryConstantName(param)
	return paramName == "CONDITION_PARAM_HEALTHGAIN" or paramName == "CONDITION_PARAM_MANAGAIN" or paramName == "CONDITION_PARAM_SOULGAIN"
end

local function isRegenTickParam(param)
	local paramName = getMasteryConstantName(param)
	return paramName == "CONDITION_PARAM_HEALTHTICKS" or paramName == "CONDITION_PARAM_MANATICKS" or paramName == "CONDITION_PARAM_SOULTICKS"
end

local function getEffectMultiplier(effect, masteryLevel)
	local everyLevels = math.max(1, tonumber(effect.everyLevels) or 1)
	return math.floor(masteryLevel / everyLevels)
end

------ Initialization & Termination

function Mastery.init()
	ProtocolGame.registerExtendedJSONOpcode(Mastery.opCode, Mastery.onExtendedOpcode)
	connect(g_game, {onGameStart = Mastery.onStart, onGameEnd = Mastery.onEnd})
	if g_game.isOnline() then
		Mastery.onStart()
	end
end

function Mastery.terminate()
	ProtocolGame.unregisterExtendedJSONOpcode(Mastery.opCode)
	disconnect(g_game, {onGameStart = Mastery.onStart, onGameEnd = Mastery.onEnd})
	Mastery.onEnd()
end

function Mastery.onStart()
	if not Mastery.Button then
		Mastery.Button = modules.client_topmenu.addRightGameToggleButton("masteryButton", tr("Mastery"), "/images/options/button_mastery", Mastery.toggle)
	end
	if not Mastery.UI then
		Mastery.UI = g_ui.displayUI("mastery")
	end

	Mastery.UI:setVisible(false)
	Mastery.setupMasteryCards()
	Mastery.colorMasteryPanels()
	Mastery.setupEffectsDescription()
	Mastery.attachLevelUpHandlers()
	Mastery.setupDialogButtons()
	Mastery.setupResetButton()

	Mastery.cachedProgress = nil
	Mastery.cachedAvailablePoints = nil
	Mastery.cachedTotalPoints = nil
	Mastery.sendOpcode({topic = "base-data-request"})
end

function Mastery.onEnd()
	if Mastery.UI then
		Mastery.UI:destroy()
		Mastery.UI = nil
	end
	if Mastery.Button then
		Mastery.Button:destroy()
		Mastery.Button = nil
	end
end

local function getOrderedMasteryNames()
	local names = {}
	local seen = {}

	for _, masteryName in ipairs(Mastery.masteryOrder or {}) do
		if Mastery.masteriesConfig[masteryName] then
			names[#names + 1] = masteryName
			seen[masteryName] = true
		end
	end

	for masteryName in pairs(Mastery.masteriesConfig) do
		if not seen[masteryName] then
			names[#names + 1] = masteryName
		end
	end
	return names
end

function Mastery.setupMasteryCards()
	local cardsPanel = Mastery.UI and Mastery.UI.masteryCardsPanel
	if not cardsPanel then
		return
	end

	cardsPanel:destroyChildren()
	for _, masteryName in ipairs(getOrderedMasteryNames()) do
		local masteryConfig = Mastery.masteriesConfig[masteryName]
		local masteryPanel = g_ui.createWidget("MasteryPanel", cardsPanel)
		masteryPanel:setId("masteryPanel" .. masteryName)
		masteryPanel.masteryName = masteryName

		local nameLabel = masteryPanel:recursiveGetChildById("name")
		if nameLabel then
			nameLabel:setText(masteryName)
			nameLabel:setColor(masteryConfig.color or "#FFFFFF")
		end

		local badge = masteryPanel:recursiveGetChildById("badge")
		if badge and masteryConfig.badge then
			badge:setImageSource("/game_mastery/" .. masteryConfig.badge)
		end
	end
end



------ UI Setup & Handling

function Mastery.toggle()
	if Mastery.UI:isVisible() then
		Mastery.UI:setVisible(false)
	else
		Mastery.UI:setVisible(true)
		Mastery.UI:focus()
	end
end

function Mastery.hide()
	if Mastery.UI:isVisible() then
		Mastery.UI:setVisible(false)
	end
end

function Mastery.show()
	if not Mastery.UI:isVisible() then
		Mastery.UI:setVisible(true)
		Mastery.UI:focus()
	end
end

function Mastery.setupDialogButtons()
	if Mastery.UI.MessageBase and Mastery.UI.MessageBase.ConfirmButton then
		Mastery.UI.MessageBase.ConfirmButton.onClick = function()
			Mastery.UI.MessageBase:setVisible(false)
			Mastery.UI.LockUI:setVisible(false)
		end
	end

	if Mastery.UI.ConfirmMessageBase and Mastery.UI.ConfirmMessageBase.CancelButton then
		Mastery.UI.ConfirmMessageBase.CancelButton.onClick = function()
			Mastery.UI.ConfirmMessageBase:setVisible(false)
			Mastery.UI.LockUI:setVisible(false)
		end
	end

	if Mastery.UI then
		Mastery.UI.onKeyDown = function(widget, keyCode)
			if keyCode == KeyEnter and Mastery.UI.MessageBase and Mastery.UI.MessageBase:isVisible() then
				Mastery.UI.MessageBase:setVisible(false)
				Mastery.UI.LockUI:setVisible(false)
				return true
			end
			return false
		end
	end
end

function Mastery.setupMessage(title, message)
	if not Mastery.UI.MessageBase or not Mastery.UI.LockUI then
		return
	end
	Mastery.UI.LockUI:setVisible(true)
	Mastery.UI.MessageBase:setVisible(true)
	Mastery.UI.MessageBase:setText(title)
	Mastery.UI.MessageBase.Text:parseColoredText(message)
	local height = Mastery.UI.MessageBase.Text:getTextSize().height + 150 -- Adjust as needed
	Mastery.UI.MessageBase:setHeight(height)
end

function Mastery.setupConfirmMessage(title, message, onConfirm)
	if not Mastery.UI.ConfirmMessageBase or not Mastery.UI.LockUI then
		return
	end
	Mastery.UI.LockUI:setVisible(true)
	Mastery.UI.ConfirmMessageBase:setVisible(true)
	Mastery.UI.ConfirmMessageBase:setText(title)
	Mastery.UI.ConfirmMessageBase.Text:parseColoredText(message)
	local height = Mastery.UI.ConfirmMessageBase.Text:getTextSize().height + 150 -- Adjust as needed
	Mastery.UI.ConfirmMessageBase:setHeight(height)

	Mastery.UI.ConfirmMessageBase.ConfirmButton.onClick = function()
		if onConfirm then
			onConfirm()
		end
		Mastery.UI.ConfirmMessageBase:setVisible(false)
		Mastery.UI.LockUI:setVisible(false)
	end
end

function Mastery.colorMasteryPanels()
	for masteryName, masteryConfig in pairs(Mastery.masteriesConfig) do
		local masteryPanel = Mastery.UI:recursiveGetChildById("masteryPanel" .. masteryName)
		if masteryPanel then
			local color = masteryConfig.color or "#FFFFFF"

			local nameLabel = masteryPanel:recursiveGetChildById("name")
			if nameLabel then
				nameLabel:setColor(color)
			end
		end
	end
end

function Mastery.setupEffectsDescription()
	for masteryName, masteryConfig in pairs(Mastery.masteriesConfig) do
		local masteryPanel = Mastery.UI:recursiveGetChildById("masteryPanel" .. masteryName)
		if masteryPanel then
			local effectsPanel = masteryPanel:recursiveGetChildById("effectsPanel")
			if effectsPanel then
				effectsPanel:destroyChildren()
				effectsPanel:setPhantom(false)
				effectsPanel:setFocusable(false)
				effectsPanel:setText("Buffs")

				local descriptions = {}
				if masteryConfig.effectsDescription then
					for _, descList in ipairs(masteryConfig.effectsDescription) do
						descriptions[#descriptions + 1] = descList[1] or ""
					end
				end
				effectsPanel:setTooltip(table.concat(descriptions, "\n"))
			end
		end
	end
end

function Mastery.updateActiveEffects()
	local activeEffectsPanel = Mastery.UI and Mastery.UI.activeEffectsPanel
	if not activeEffectsPanel then
		return
	end

	activeEffectsPanel:destroyChildren()
	local combinedEffects = {}
	local combinedEffectOrder = {}

	local function addEffectValue(effectName, value, options)
		options = options or {}
		local tickTime = options.tickTime or 0
		local suffix = options.suffix or ""
		local key = effectName .. "|" .. tickTime .. "|" .. suffix

		if not combinedEffects[key] then
			combinedEffects[key] = {
				name = effectName,
				tickTime = tickTime,
				suffix = suffix,
				total = 0,
			}
			combinedEffectOrder[#combinedEffectOrder + 1] = key
		end

		combinedEffects[key].total = combinedEffects[key].total + value
	end

	for masteryName, masteryConfig in pairs(Mastery.masteriesConfig) do
		local masteryLevel = Mastery.cachedProgress[masteryName] or 0
		if masteryLevel > 0 then
			for _, effect in ipairs(masteryConfig.effects) do
				local effectMultiplier = getEffectMultiplier(effect, masteryLevel)
				if effectMultiplier > 0 then
					local effectName = effect.name or "Buff"
					if effect.type == "condition" then
						if getMasteryConstantName(effect.conditionType) == "CONDITION_REGENERATION" then
							local tickTime = nil
							local totalGain = 0

							if effect.params then
								for _, paramData in ipairs(effect.params) do
									if isRegenGainParam(paramData.param) then
										totalGain = totalGain + (paramData.value * effectMultiplier)
									elseif isRegenTickParam(paramData.param) then
										tickTime = paramData.value
									end
								end
							end

							if totalGain > 0 then
								addEffectValue(effectName, totalGain, {tickTime = tickTime})
							end
						elseif effect.haste then
							local totalHaste = effect.value * effectMultiplier
							local halfHaste = math.floor(totalHaste)
							addEffectValue(effectName, halfHaste)
						else
							if effect.params then
								local total = 0
								for _, paramData in ipairs(effect.params) do
									local val = paramData.value * effectMultiplier
									total = total + val
								end
								if total ~= 0 then
									addEffectValue(effectName, total, {suffix = effect.percent and "%" or ""})
								end
							end
						end
					elseif effect.type == "storage" then
						local totalValue = effect.value * effectMultiplier
						if totalValue ~= 0 then
							addEffectValue(effectName, totalValue)
						end
					elseif effect.type == "capacity" then
						local totalValue = effect.value * effectMultiplier
						if totalValue ~= 0 then
							addEffectValue(effectName, totalValue)
						end
					end
				end
			end
		end
	end

	for _, key in ipairs(combinedEffectOrder) do
		local data = combinedEffects[key]
		local label = g_ui.createWidget("Label", activeEffectsPanel)
		label:setTextAutoResize(true)
		label:setTextWrap(true)
		label:setBackgroundColor("#00000060")

		local valueText = string.format("+%d%s", data.total, data.suffix)
		if data.tickTime > 0 then
			local seconds = data.tickTime / 1000.0
			label:setText(string.format("%s %s per %.1fs", data.name, valueText, seconds))
		else
			label:setText(string.format("%s %s", data.name, valueText))
		end
	end
end

function Mastery.attachLevelUpHandlers()
	for masteryName, masteryConfig in pairs(Mastery.masteriesConfig) do
		local masteryPanel = Mastery.UI:recursiveGetChildById("masteryPanel" .. masteryName)
		if masteryPanel then
			local levelUpButton = masteryPanel:recursiveGetChildById("levelUpButton")
			if levelUpButton then
				levelUpButton.onClick = function()
					local masteryColor = masteryConfig.color or "#FFFFFF"

					local confirmText =
						string.format(
						"Are you sure you want to level up [color=%s]%s[/color] mastery?",
						masteryColor,
						masteryName
					)

					if g_keyboard.isCtrlPressed() then
						Mastery.sendOpcode(
							{
								topic = "levelup-mastery-request",
								masteryName = masteryName,
								confirmation = false
							}
						)
					else
						Mastery.setupConfirmMessage(
							"Confirm Level Up",
							confirmText,
							function()
								Mastery.sendOpcode(
									{
										topic = "levelup-mastery-request",
										masteryName = masteryName,
										confirmation = true
									}
								)
							end
						)
					end
				end
			end
		end
	end
end

function Mastery.setupResetButton()
	local resetButton = Mastery.UI.bottomPanel and Mastery.UI.bottomPanel.resetButton
	if not resetButton then
		return
	end

	resetButton.onClick = function()
		local requirementsText = "To reset your masteries, you need:\n"
		local resetCost = Mastery.displayResetCost or {}

		if resetCost.gold and resetCost.gold > 0 then
			requirementsText = requirementsText .. string.format("%d gold\n", resetCost.gold)
		end

		if resetCost.items then
			for _, itemData in ipairs(resetCost.items) do
				local itemName = itemData.name
				local itemCount = itemData.amount or 1
				requirementsText = requirementsText .. string.format("%d x %s\n", itemCount, itemName)
			end
		end

		if resetCost.storages then
			for _, storageData in ipairs(resetCost.storages) do
				local storageName = storageData.name
				local requiredValue = storageData.amount or 1
				requirementsText = requirementsText .. string.format("%d %s\n", requiredValue, storageName)
			end
		end

		requirementsText = requirementsText .. "\nAre you sure you want to reset all your masteries?"

		Mastery.setupConfirmMessage(
			"Confirm Mastery Reset",
			requirementsText,
			function()
				Mastery.sendOpcode({topic = "reset-request"})
			end
		)
	end
end

function Mastery.setupPoints()
	local pointsText =
		string.format(
		"[color=%s]Total Mastery Points: %d[/color]  |  [color=%s]Available Mastery Points: %d[/color]",
		Mastery.totalPointsColor or "#FFFFFF",
		Mastery.cachedTotalPoints,
		Mastery.availablePointsColor or "#FFFFFF",
		Mastery.cachedAvailablePoints
	)
	Mastery.UI.bottomPanel.pointsLabel:parseColoredText(pointsText)
end

function Mastery.setupBaseData()
	for masteryName, _ in pairs(Mastery.masteriesConfig) do
		local masteryLevel = Mastery.cachedProgress[masteryName] or 0

		if masteryLevel < 0 then
			masteryLevel = 0
		end

		local masteryPanel = Mastery.UI:recursiveGetChildById("masteryPanel" .. masteryName)
		if masteryPanel then
			local levelLabel = masteryPanel:recursiveGetChildById("level")
			if levelLabel then
				levelLabel:setText("Level - " .. masteryLevel)
			end
		end
	end
end



------ Communication

function Mastery.onExtendedOpcode(protocol, opcode, data)
	if type(data) ~= "table" then
		return
	end

	local topic = data.topic

	if topic == "base-data-response" then
		Mastery.cachedProgress = data.masteries
		Mastery.cachedAvailablePoints = data.availablePoints
		Mastery.cachedTotalPoints = data.totalPoints
		Mastery.setupPoints()
		Mastery.setupBaseData()
		Mastery.updateActiveEffects()
	elseif data.topic == "message" then
		Mastery.setupMessage(data.title, data.message)
	elseif data.topic == "points-update" then
		Mastery.cachedAvailablePoints = data.availablePoints
		Mastery.cachedTotalPoints = data.totalPoints
		Mastery.setupPoints()
	end
end

function Mastery.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(Mastery.opCode, data)
	end
end
