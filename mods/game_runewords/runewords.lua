
RuneWords.opcode = 146

local selectedRune = nil
local selectedSlot = nil

function RuneWords.init()
	connect(
		g_game,
		{
			onGameStart = RuneWords.OnStart,
			onGameEnd = RuneWords.OnEnd
		}
	)
	ProtocolGame.registerExtendedOpcode(RuneWords.opcode, RuneWords.onExtendedOpcode)
	RuneWords.OnStart()
end

function RuneWords.terminate()
	disconnect(
		g_game,
		{
			onGameStart = RuneWords.OnStart,
			onGameEnd = RuneWords.OnEnd
		}
	)
	ProtocolGame.unregisterExtendedOpcode(RuneWords.opcode)
	RuneWords.OnEnd()
end

function RuneWords.OnStart()
	if not RuneWords.UI then
		RuneWords.UI = g_ui.displayUI("runewords")
	end
	RuneWords.UI:hide()

	if not RuneWords.Button then
		RuneWords.Button =
			modules.client_topmenu.addRightGameToggleButton(
			"runewordsButton",
			tr("RuneWords"),
			"/images/options/button_runewords",
			RuneWords.toggle
		)
	end

	RuneWords.UI.RuneWordsButton:setChecked(true)

	RuneWords.Define()
end

function RuneWords.OnEnd()

	if RuneWords.UI then
		RuneWords.UI:destroy()
		RuneWords.UI = nil
	end

	if RuneWords.Button then
		RuneWords.Button:destroy()
		RuneWords.Button = nil
	end

	selectedRune = nil
	selectedSlot = nil
end

function RuneWords.toggle()
	if RuneWords.UI:isVisible() then
		RuneWords.UI:hide()
	else
		RuneWords.UI:show()
		RuneWords.sendOpcode({topic = "base-data"})
	end
end

function RuneWords.hide()
	RuneWords.UI:hide()
end

----

function RuneWords.Define()
	RuneWords.UI.RuneWordsButton.onClick = function(self)
		self:setChecked(true)
		RuneWords.UI.RunesPediaButton:setChecked(false)
		RuneWords.UI.RuneWordsInternalBoard:setVisible(true)
		RuneWords.UI.RunePediaInternalBoard:setVisible(false)
		RuneWords.UI.pediaRunesSearch:setVisible(false)
		RuneWords.UI.pediaRuneWordsSearch:setVisible(false)
		RuneWords.UI.totalBuffsButton:setVisible(true)
	end

	RuneWords.UI.RunesPediaButton.onClick = function(self)
		self:setChecked(true)
		RuneWords.UI.RuneWordsButton:setChecked(false)
		RuneWords.UI.RuneWordsInternalBoard:setVisible(false)
		RuneWords.UI.RunePediaInternalBoard:setVisible(true)
		RuneWords.UI.pediaRunesSearch:setVisible(true)
		RuneWords.UI.pediaRuneWordsSearch:setVisible(true)
		RuneWords.UI.totalBuffsButton:setVisible(false)
	end

	RuneWords.UI.RuneWordsInternalBoard.instilButton.onClick = function()
		RuneWords.onImbueButtonClick()
	end

	RuneWords.UI.RuneWordsInternalBoard.dissipateButton.onClick = function()
		RuneWords.onDissipateButtonClick()
	end

	RuneWords.UI.RuneWordsInternalBoard.refundButton.onClick = function()
		RuneWords.onRefundButtonClick()
	end

	RuneWords.UI.totalBuffsButton.onClick = function()
		RuneWords.requestTotalBuffs()
	end

	RuneWords.UI.pediaRunesSearch.onTextChange = function(widget, text)
		RuneWords.onPediaRunesSearch(widget, text)
	end
	RuneWords.UI.pediaRuneWordsSearch.onTextChange = function(widget, text)
		RuneWords.onPediaRuneWordsSearch(widget, text)
	end

	RuneWords.setupOkayButton()
	RuneWords.setupNoButton()

	RuneWords.populateRunesPedia()
	RuneWords.populateRuneWordPedia()
end

function RuneWords.onPediaRunesSearch(widget, text)
	text = text:lower()

	local runesPanel = RuneWords.UI.RunePediaInternalBoard.runesPediaPanel
	for _, runeWidget in pairs(runesPanel:getChildren()) do
		local runeName = runeWidget.runeName:getText():lower()
		if runeName:match(text) then
			runeWidget:show()
		else
			runeWidget:hide()
		end
	end
end

function RuneWords.onPediaRuneWordsSearch(widget, text)
	text = text:lower()

	local runeWordsPanel = RuneWords.UI.RunePediaInternalBoard.runeWordsPediaPanel
	for _, runeWordWidget in pairs(runeWordsPanel:getChildren()) do
		local runeWordName = runeWordWidget.runeWordName:getText():lower()
		if runeWordName:match(text) then
			runeWordWidget:show()
		else
			runeWordWidget:hide()
		end
	end
end

function RuneWords.formatSeconds(milliseconds)
	local seconds = tonumber(milliseconds or 0) / 1000
	if seconds == math.floor(seconds) then
		return string.format("%ds", seconds)
	end
	return string.format("%.1fs", seconds)
end

function RuneWords.getBuffParam(buff, paramName)
	for _, param in pairs(buff.params or {}) do
		if param.param == paramName then
			return param.value
		end
	end
	return nil
end

function RuneWords.formatRegenerationBuff(buff)
	local healthGain = RuneWords.getBuffParam(buff, "CONDITION_PARAM_HEALTHGAIN")
	local healthTicks = RuneWords.getBuffParam(buff, "CONDITION_PARAM_HEALTHTICKS")
	local manaGain = RuneWords.getBuffParam(buff, "CONDITION_PARAM_MANAGAIN")
	local manaTicks = RuneWords.getBuffParam(buff, "CONDITION_PARAM_MANATICKS")
	local values = {}

	if healthGain and healthTicks then
		table.insert(values, string.format("%dhp/%s", healthGain, RuneWords.formatSeconds(healthTicks)))
	end

	if manaGain and manaTicks then
		table.insert(values, string.format("%dmp/%s", manaGain, RuneWords.formatSeconds(manaTicks)))
	end

	if #values == 0 then
		return nil
	end

	return string.format(" %s\n%s\n", buff.name, table.concat(values, " | "))
end

function RuneWords.formatBuffText(buffs)
	local buffText = ""

	for _, buff in pairs(buffs or {}) do
		if buff.type == "storage" then
			buffText = buffText .. string.format(" %s: +%d\n", buff.name, buff.value)
		elseif buff.type == "condition" then
			local regenerationText = nil
			if buff.conditionType == "CONDITION_REGENERATION" then
				regenerationText = RuneWords.formatRegenerationBuff(buff)
			end

			if regenerationText then
				buffText = buffText .. regenerationText
			else
				for _, param in pairs(buff.params or {}) do
					buffText = buffText .. string.format(" %s: +%d\n", buff.name, param.value)
				end
			end
		end
	end

	return buffText
end

function RuneWords.populateRunesPedia()
	RuneWords.UI.RunePediaInternalBoard.runesPediaPanel:destroyChildren()

	for _, rune in pairs(RuneWords.runeConfig) do
		local runeWidget = g_ui.createWidget("RunePediaEntry", RuneWords.UI.RunePediaInternalBoard.runesPediaPanel)

		runeWidget.runeEntry.runeSprite:setItemId(rune.itemId)

		runeWidget.runeName:parseColoredText("[color=" .. rune.color .. "]" .. rune.name .. "[/color]", "white")

		local buffText = RuneWords.formatBuffText(rune.buffs)

		runeWidget.runeBuff:parseColoredText(
			"[color=" .. rune.color .. "]" .. buffText .. "[/color]",
			"white"
		)

	end
end

function RuneWords.populateRuneWordPedia()
	RuneWords.UI.RunePediaInternalBoard.runeWordsPediaPanel:destroyChildren()

	for _, runeWord in pairs(RuneWords.runeWordsCombinations) do
		local runeWordWidget = g_ui.createWidget("RuneWordPediaEntry", RuneWords.UI.RunePediaInternalBoard.runeWordsPediaPanel)

		local runeOne = runeWord.runes[1] and RuneWords.runeConfig[runeWord.runes[1]] or nil
		local runeTwo = runeWord.runes[2] and RuneWords.runeConfig[runeWord.runes[2]] or nil
		local runeThree = runeWord.runes[3] and RuneWords.runeConfig[runeWord.runes[3]] or nil
		local runeFour = runeWord.runes[4] and RuneWords.runeConfig[runeWord.runes[4]] or nil

		if runeOne then
			runeWordWidget.runeWordRuneOneEntry.runeOneSprite:setItemId(runeOne.itemId)
			runeWordWidget.runeWordRuneOneEntry:setTooltip(runeOne.name)
			runeWordWidget.runeWordRuneOneEntry.runeOneSprite:setTooltip(runeOne.name)
		end

		if runeTwo then
			runeWordWidget.runeWordRuneTwoEntry.runeTwoSprite:setItemId(runeTwo.itemId)
			runeWordWidget.runeWordRuneTwoEntry:setTooltip(runeTwo.name)
			runeWordWidget.runeWordRuneTwoEntry.runeTwoSprite:setTooltip(runeTwo.name)
		end

		if runeThree then
			runeWordWidget.runeWordRuneThreeEntry.runeThreeSprite:setItemId(runeThree.itemId)
			runeWordWidget.runeWordRuneThreeEntry:setTooltip(runeThree.name)
			runeWordWidget.runeWordRuneThreeEntry.runeThreeSprite:setTooltip(runeThree.name)
		end

		if runeFour then
			runeWordWidget.runeWordRuneFourEntry.runeFourSprite:setItemId(runeFour.itemId)
			runeWordWidget.runeWordRuneFourEntry:setTooltip(runeFour.name)
			runeWordWidget.runeWordRuneFourEntry.runeFourSprite:setTooltip(runeFour.name)
		end

		runeWordWidget.runeWordName:parseColoredText(
			"[color=" .. runeWord.color .. "]RuneWord: " .. runeWord.runewordName .. "[/color]",
			"white"
		)

		local buffText = "[color=" .. runeWord.color .. "]Buffs: [/color]\n" .. RuneWords.formatBuffText(runeWord.buffs)

		runeWordWidget.runeWordBuff.text:parseColoredText(
			"" .. buffText .. "",
			"white"
		)
	end
end

----

function RuneWords.onRuneSelected(runeId, quantity)
	selectedRune = {runeId = runeId, quantity = quantity}
end

function RuneWords.onCheckChanged(selectedCheckbox)
	local pocketsPanel = RuneWords.UI.RuneWordsInternalBoard.pocketsPanel

	for pocketId, pocketWidget in ipairs(pocketsPanel:getChildren()) do
		pocketWidget.slotOneCheck.onCheckChange = nil
		pocketWidget.slotTwoCheck.onCheckChange = nil
		pocketWidget.slotThreeCheck.onCheckChange = nil
		pocketWidget.slotFourCheck.onCheckChange = nil

		RuneWords.updateSlotCheck(pocketWidget, selectedCheckbox, pocketId, "slotOne", 1)
		RuneWords.updateSlotCheck(pocketWidget, selectedCheckbox, pocketId, "slotTwo", 2)
		RuneWords.updateSlotCheck(pocketWidget, selectedCheckbox, pocketId, "slotThree", 3)
		RuneWords.updateSlotCheck(pocketWidget, selectedCheckbox, pocketId, "slotFour", 4)

		pocketWidget.slotOneCheck.onCheckChange = function(self)
			RuneWords.onCheckChanged(self)
		end
		pocketWidget.slotTwoCheck.onCheckChange = function(self)
			RuneWords.onCheckChanged(self)
		end
		pocketWidget.slotThreeCheck.onCheckChange = function(self)
			RuneWords.onCheckChanged(self)
		end
		pocketWidget.slotFourCheck.onCheckChange = function(self)
			RuneWords.onCheckChanged(self)
		end
	end
end

function RuneWords.updateSlotCheck(pocketWidget, selectedCheckbox, pocketId, slot, slotIndex)
	local checkBox = pocketWidget[slot .. "Check"]

	if checkBox == selectedCheckbox then
		if checkBox:isChecked() then
			selectedSlot = {pocketWidget = pocketWidget, slot = slot, slotIndex = slotIndex, pocketId = pocketId}
			pocketWidget[slot]:setImageSource("images/selectedSlotBBg")
		else
			local runeId = pocketWidget[slot]:getChildById("slotSprite"):getItemId()
			pocketWidget[slot]:setImageSource(runeId > 0 and "images/fullSlotBBg" or "images/emptySlotBBg")
			selectedSlot = nil
		end
	else
		checkBox:setChecked(false)
		local runeId = pocketWidget[slot]:getChildById("slotSprite"):getItemId()
		pocketWidget[slot]:setImageSource(runeId > 0 and "images/fullSlotBBg" or "images/emptySlotBBg")
	end
end

----

function RuneWords.onImbueButtonClick()
	if not selectedRune then
		RuneWords.setupMessage("No Rune Selected!", "You need to select a rune.")
		return
	end

	if not selectedSlot or not selectedSlot.pocketWidget then
		RuneWords.setupMessage("No Slot Selected!", "You need to select a slot to imbue.")
		return
	end

	local slotWidget = selectedSlot.pocketWidget:getChildById(selectedSlot.slot)

	if not slotWidget then
		RuneWords.setupMessage("Invalid Slot!", "There was an issue with the selected slot.")
		return
	end

	local runeId = slotWidget:getChildById("slotSprite"):getItemId()
	if runeId > 0 then
		RuneWords.setupMessage("Slot Already Has Rune!", "You cannot imbue a slot that already has a rune.")
	else
		RuneWords.setupConfirmMessage(
			"Confirm Imbue",
			"Are you sure you want to imbue this rune?",
			function()
				RuneWords.sendOpcode({
					topic = "imbue",
					runeId = selectedRune.runeId,
					slotIndex = selectedSlot.slotIndex,
					pocketId = selectedSlot.pocketId
				})

				selectedSlot.pocketWidget[selectedSlot.slot .. "Check"]:setChecked(false)
				selectedSlot = nil
			end
		)
	end
end

function RuneWords.onDissipateButtonClick()
	if not selectedSlot or not selectedSlot.pocketWidget then
		RuneWords.setupMessage("No Slot Selected!", "You need to select a slot to dissipate.")
		return
	end

	local slotWidget = selectedSlot.pocketWidget:getChildById(selectedSlot.slot)

	if not slotWidget then
		RuneWords.setupMessage("Invalid Slot!", "There was an issue with the selected slot.")
		return
	end

	local runeId = slotWidget:getChildById("slotSprite"):getItemId()
	if runeId <= 0 then
		RuneWords.setupMessage("Slot Does not Have a Rune!", "You cannot dissipate a slot that has no rune.")
	else
		RuneWords.setupConfirmMessage(
			"Confirm Dissipate",
			"Are you sure you want to dissipate this rune?",
			function()
				RuneWords.sendOpcode({
					topic = "dissipate",
					slotIndex = selectedSlot.slotIndex,
					pocketId = selectedSlot.pocketId
				})

				selectedSlot.pocketWidget[selectedSlot.slot .. "Check"]:setChecked(false)
				selectedSlot = nil
			end
		)
	end
end

function RuneWords.onRefundButtonClick()
	if not selectedRune then
		RuneWords.setupMessage("No Rune Selected!", "You need to select a rune to refund it.")
		return
	end

	local runeQty = tonumber(selectedRune.quantity) or 0
	if runeQty < 1 then
		RuneWords.setupMessage("No Rune to Refund", "You do not have this rune in storage to refund it.")
	else
		RuneWords.setupRefundConfirmMessage(
			"Confirm Refund",
			"Select how many runes to refund.",
			runeQty,
			function(amount)
				RuneWords.sendOpcode(
					{
						topic = "refund",
						runeId = selectedRune.runeId,
						amount = amount
					}
				)

			end
		)
	end
end

----

function RuneWords.createPockets(totalMaxPockets, fullPocketsData)
	for i = 1, totalMaxPockets do
		local pocketWidget = g_ui.createWidget("PocketEntry", RuneWords.UI.RuneWordsInternalBoard.pocketsPanel)
		if not pocketWidget then
			g_logger.error("RuneWords: failed to create PocketEntry widget")
			return
		end

		local pocketData = fullPocketsData["pocket" .. i]

		if pocketData then
			pocketWidget.notUnlockedMask:setVisible(false)
			RuneWords.populateSlots(pocketWidget, pocketData.runes)

			if pocketData.runeWordName ~= nil then
				local runeWordColor = "#FFFFFF"
				for _, runeWord in pairs(RuneWords.runeWordsCombinations) do
					if runeWord.runewordName == pocketData.runeWordName then
						runeWordColor = runeWord.color
						break
					end
				end

				pocketWidget.RuneWord:parseColoredText(
					"[color=" .. runeWordColor .. "]" .. pocketData.runeWordName .. "[/color]",
					"white"
				)
			else
				pocketWidget.RuneWord:setText("")
			end

			if pocketData.totalBuffs ~= nil and pocketData.totalBuffs ~= "" then
				pocketWidget.pocketTooltip:setTooltip("Pocket buffs:\n" .. pocketData.totalBuffs)
			else
				pocketWidget.pocketTooltip:setTooltip("No buffs applied.")
			end
		else
			pocketWidget.notUnlockedMask:setVisible(true)
			pocketWidget.notUnlockedMask.onClick = function()
				RuneWords.onLockedPocketClick(i)
			end
		end

		local slotNames = {"slotOne", "slotTwo", "slotThree", "slotFour"}
		for _, slotName in ipairs(slotNames) do
			pocketWidget[slotName .. "Check"].onCheckChange = function(self)
				RuneWords.onCheckChanged(self)
			end
		end
	end
end

function RuneWords.populateSlots(pocketWidget, runes)
	local slotNames = {"slotOne", "slotTwo", "slotThree", "slotFour"}

	for i = 1, 4 do
		local slot = slotNames[i]
		local sprite = pocketWidget[slot]:getChildById("slotSprite")
		local runeId = runes[i]

		if runeId > 0 then
			sprite:setItemId(runeId)
			pocketWidget[slot]:setImageSource("images/fullSlotBBg")

			local runeName = "Unknown Rune"
			for _, rune in pairs(RuneWords.runeConfig) do
				if rune.itemId == runeId then
					runeName = rune.name
					break
				end
			end

			pocketWidget[slot]:setTooltip("" .. runeName)
			pocketWidget[slot].slotSprite:setTooltip("" .. runeName)
		else
			sprite:setItemId(0)
			pocketWidget[slot]:setImageSource("images/emptySlotBBg")
			pocketWidget[slot]:setTooltip("No Rune Imbued")
			pocketWidget[slot].slotSprite:setTooltip("No Rune Imbued")
		end
	end
end

function RuneWords.onLockedPocketClick(pocketId)
	RuneWords.sendOpcode({topic = "unlock-requirements", pocketId = pocketId})
end

function RuneWords.showUnlockConfirmation(pocketId, requirementsMessage)
	RuneWords.setupConfirmMessage(
		"Unlock Pocket " .. pocketId,
		requirementsMessage,
		function()
			RuneWords.sendOpcode({topic = "unlock-pocket", pocketId = pocketId})
		end
	)
end

----

function RuneWords.getRuneInfo(runeId)
	for _, rune in pairs(RuneWords.runeConfig) do
		if rune.itemId == runeId then
			return rune.name, rune.color
		end
	end
	return "Unknown Rune", "#FFFFFF"
end

function RuneWords.updateRuneInventoryEmptyState(runeInventory)
	local isEmpty = not runeInventory or #runeInventory == 0
	RuneWords.UI.RuneWordsInternalBoard.runesEmptyPanel:setVisible(isEmpty)
end

function RuneWords.populateRuneInventory(runeInventory)
    RuneWords.UI.RuneWordsInternalBoard.runesPanel:destroyChildren()
	RuneWords.updateRuneInventoryEmptyState(runeInventory)

    for _, rune in pairs(runeInventory) do
        local runeWidget = g_ui.createWidget("RuneEntry", RuneWords.UI.RuneWordsInternalBoard.runesPanel)
        runeWidget.runeSprite:setItemId(rune.runeId)
        runeWidget.runeQty:setText("Quantity: " .. rune.quantity)

        local runeName, runeColor = RuneWords.getRuneInfo(rune.runeId)
        runeWidget.runeName:setText(runeName)
        runeWidget.runeName:setColor(runeColor)

        runeWidget.quantity = rune.quantity

        runeWidget.onClick = function()
            RuneWords.onRuneSelected(rune.runeId, rune.quantity)
        end
    end
    RuneWords.UI.RuneWordsInternalBoard.runesPanel:focusChild()
end

function RuneWords.displayTotalBuffs(buffs)
	local buffsString = ""
	if type(buffs) == "table" then
		for buffsType, buffValue in pairs(buffs) do
			buffsString = buffsString .. buffsType:sub(1, 1):upper() .. buffsType:sub(2) .. ": +" .. buffValue .. "\n"
		end
	end

	if buffsString == "" then
		buffsString = "No current buffs."
	end

	RuneWords.setupMessage("Total Buffs", buffsString)
end

function RuneWords.requestTotalBuffs()
	RuneWords.sendOpcode({topic = "total-buffs"})
end

----

function RuneWords.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(RuneWords.opcode, data)
	end
end

function RuneWords.setupMessage(title, message)
	RuneWords.UI.LockUI:setVisible(true)
	RuneWords.UI.MessageBase:setVisible(true)
	RuneWords.UI.MessageBase:setText(title)
	RuneWords.UI.MessageBase.Text:setText(message)
	RuneWords.UI.MessageBase:setHeight(RuneWords.UI.MessageBase.Text:getTextSize().height + 100)
end

function RuneWords.setupConfirmMessage(title, message, onConfirm)
	RuneWords.UI.LockUI:setVisible(true)
	RuneWords.UI.ConfirmMessageBase:setVisible(true)
	RuneWords.UI.ConfirmMessageBase:setText(title)
	RuneWords.UI.ConfirmMessageBase.Text:setText(message)
	RuneWords.UI.ConfirmMessageBase.RefundAmountPanel:setVisible(false)
	RuneWords.UI.ConfirmMessageBase.RefundAmountPanel:setHeight(0)
	RuneWords.UI.ConfirmMessageBase:setHeight(RuneWords.UI.ConfirmMessageBase.Text:getTextSize().height + 100)

	RuneWords.UI.ConfirmMessageBase.ConfirmButton.onClick = function()
		if onConfirm then
			onConfirm()
		end

		RuneWords.UI.ConfirmMessageBase:setVisible(false)
		RuneWords.UI.LockUI:setVisible(false)
	end
end

function RuneWords.setupRefundConfirmMessage(title, message, maxAmount, onConfirm)
	local confirmWindow = RuneWords.UI.ConfirmMessageBase
	local amountPanel = confirmWindow.RefundAmountPanel
	local amountSlider = amountPanel.AmountSlider
	local amountLabel = amountPanel.AmountLabel
	local selectedAmount = 1

	maxAmount = math.max(1, tonumber(maxAmount) or 1)

	local function updateAmount(value)
		selectedAmount = math.max(1, math.min(maxAmount, tonumber(value) or 1))
		amountLabel:setText("Amount: " .. selectedAmount .. " / " .. maxAmount)
	end

	RuneWords.UI.LockUI:setVisible(true)
	confirmWindow:setVisible(true)
	confirmWindow:setText(title)
	confirmWindow.Text:setText(message)
	amountPanel:setHeight(42)
	amountPanel:setVisible(true)

	amountSlider.onValueChange = function(_, value)
		updateAmount(value)
	end
	amountSlider:setMinimum(1)
	amountSlider:setMaximum(maxAmount)
	amountSlider:setValue(1)
	updateAmount(1)

	confirmWindow:setHeight(confirmWindow.Text:getTextSize().height + 150)
	confirmWindow.ConfirmButton.onClick = function()
		if onConfirm then
			onConfirm(selectedAmount)
		end

		confirmWindow:setVisible(false)
		amountPanel:setVisible(false)
		amountPanel:setHeight(0)
		RuneWords.UI.LockUI:setVisible(false)
	end
end

function RuneWords.setupOkayButton()
	RuneWords.UI.MessageBase.ConfirmButton.onClick = function()
		RuneWords.UI.MessageBase:setVisible(false)
		RuneWords.UI.LockUI:setVisible(false)
	end
end

function RuneWords.setupNoButton()
	RuneWords.UI.ConfirmMessageBase.CancelButton.onClick = function()
		RuneWords.UI.ConfirmMessageBase:setVisible(false)
		RuneWords.UI.ConfirmMessageBase.RefundAmountPanel:setVisible(false)
		RuneWords.UI.ConfirmMessageBase.RefundAmountPanel:setHeight(0)
		RuneWords.UI.LockUI:setVisible(false)
	end
end

function RuneWords.setupData(data)
	RuneWords.UI.RuneWordsInternalBoard.pocketsPanel:destroyChildren()
	RuneWords.UI.RuneWordsInternalBoard.runesPanel:destroyChildren()
	RuneWords.createPockets(data.data.totalMaxPockets, data.data.pockets)
	RuneWords.populateRuneInventory(data.data.runeInventory)
	selectedRune = nil
	selectedSlot = nil
end

function RuneWords.updateRuneInventory(runeInventory)
	RuneWords.UI.RuneWordsInternalBoard.runesPanel:destroyChildren()
	RuneWords.updateRuneInventoryEmptyState(runeInventory)

	for _, rune in pairs(runeInventory) do
		local runeWidget = g_ui.createWidget("RuneEntry", RuneWords.UI.RuneWordsInternalBoard.runesPanel)
		runeWidget.runeSprite:setItemId(rune.runeId)
		runeWidget.runeQty:setText("Quantity: " .. rune.quantity)

		local runeName, runeColor = RuneWords.getRuneInfo(rune.runeId)
		runeWidget.runeName:setText(runeName)
		runeWidget.runeName:setColor(runeColor)

		runeWidget.quantity = rune.quantity

		runeWidget.onClick = function()
			RuneWords.onRuneSelected(rune.runeId, rune.quantity)
		end
	end

	RuneWords.UI.RuneWordsInternalBoard.runesPanel:focusChild()
end

function RuneWords.updatePocketData(pocketId, runes, runeWordName, totalBuffs)
	local pocketsPanel = RuneWords.UI.RuneWordsInternalBoard.pocketsPanel
	local pocketWidget = pocketsPanel:getChildByIndex(pocketId)

	if not pocketWidget then
		return
	end

	local slotNames = {"slotOne", "slotTwo", "slotThree", "slotFour"}
	for i = 1, 4 do
		local slot = slotNames[i]
		local sprite = pocketWidget[slot]:getChildById("slotSprite")
		local runeId = runes[i]

		if runeId > 0 then
			sprite:setItemId(runeId)
			pocketWidget[slot]:setImageSource("images/fullSlotBBg")

			local runeName = "Unknown Rune"
			for _, rune in pairs(RuneWords.runeConfig) do
				if rune.itemId == runeId then
					runeName = rune.name
					break
				end
			end

			pocketWidget[slot]:setTooltip("" .. runeName)
			pocketWidget[slot].slotSprite:setTooltip("" .. runeName)
		else
			sprite:setItemId(0)
			pocketWidget[slot]:setImageSource("images/emptySlotBBg")
			pocketWidget[slot]:setTooltip("No Rune Imbued")
			pocketWidget[slot].slotSprite:setTooltip("No Rune Imbued")
		end
	end

	if runeWordName then
		local runeWordColor = "#FFFFFF"
		for _, runeWord in pairs(RuneWords.runeWordsCombinations) do
			if runeWord.runewordName == runeWordName then
				runeWordColor = runeWord.color
				break
			end
		end
		pocketWidget.RuneWord:parseColoredText("[color=" .. runeWordColor .. "]" .. runeWordName .. "[/color]", "white")
	else
		pocketWidget.RuneWord:setText("")
	end

	if totalBuffs and totalBuffs ~= "" then
		pocketWidget.pocketTooltip:setTooltip("Pocket buffs:\n" .. totalBuffs)
	else
		pocketWidget.pocketTooltip:setTooltip("No buffs applied.")
	end
end

----

function RuneWords.onExtendedOpcode(protocol, opcode, buffer)
	local data = json.decode(buffer)
	if data.topic == "base-data" then
		RuneWords.setupData(data)
	elseif data.topic == "imbue-success" then
		RuneWords.setupMessage("Rune Imbuing Success!", data.message)
	elseif data.topic == "imbue-failed" then
		RuneWords.setupMessage("Error!", data.message)
	elseif data.topic == "dissipate-success" then
		RuneWords.setupMessage("Rune dissipate Success!", data.message)
	elseif data.topic == "dissipate-failed" then
		RuneWords.setupMessage("Error!", data.message)
	elseif data.topic == "refund-success" then
		RuneWords.setupMessage("Rune refund Success!", data.message)
	elseif data.topic == "refund-failed" then
		RuneWords.setupMessage("Error!", data.message)
	elseif data.topic == "unlock-requirements" then
		RuneWords.showUnlockConfirmation(data.pocketId, data.message)
	elseif data.topic == "unlock-pocket-success" then
		RuneWords.setupMessage("Success!", "You have unlocked pocket " .. data.pocketId .. ".")
	elseif data.topic == "unlock-pocket-failed" then
		RuneWords.setupMessage("Error!", data.message)
	elseif data.topic == "total-buffs-response" then
		RuneWords.displayTotalBuffs(data.buffs)
	elseif data.topic == "rune-inventory-update" then
		RuneWords.updateRuneInventory(data.runeInventory)
	elseif data.topic == "pocket-update" then
		RuneWords.updatePocketData(data.pocketId, data.runes, data.runeWordName, data.totalBuffs)
	end
end
