SpellsUnlocker = SpellsUnlocker or {}

local function commaValue(amount)
	local formatted = tostring(amount or 0)
	while true do
		local nextValue, replacements = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = nextValue
		if replacements == 0 then
			break
		end
	end
	return formatted
end

local function asset(path)
	if type(path) ~= "string" then
		return ""
	end
	if path:sub(1, 1) == "/" then
		return path
	end
	return "/game_spellsUnlocker/" .. path
end

local function isSpellLearned(categoryId, spellId)
	for _, progress in ipairs(SpellsUnlocker.spellsProgress or {}) do
		if progress.categoryId == categoryId then
			for _, learnedSpellId in ipairs(progress.learnedSpells or {}) do
				if learnedSpellId == spellId then
					return true
				end
			end
		end
	end
	return false
end

local function formatValue(value, emptyText)
	if value == nil or value == "" then
		return emptyText or "-"
	end
	return tostring(value)
end

local function getSpellPointsCost(spellData)
	local cost = spellData.cost or {}
	return tonumber(cost.SP or cost.spellPoints or cost.sp) or 0
end

local function getSpellPaymentLines(spellData)
	local cost = spellData.cost or {}
	local lines = {}
	local gold = tonumber(cost.gold) or 0
	if gold > 0 then
		lines[#lines + 1] = commaValue(gold) .. " gold coins"
	end

	local spellPoints = getSpellPointsCost(spellData)
	if spellPoints > 0 then
		lines[#lines + 1] = commaValue(spellPoints) .. " Spell Points"
	end

	for _, storageCost in ipairs(cost.storages or cost.storage or {}) do
		local amount = tonumber(storageCost.amount) or 0
		if amount > 0 then
			lines[#lines + 1] = commaValue(amount) .. " " .. formatValue(storageCost.name, "points")
		end
	end

	for _, itemCost in ipairs(cost.items or {}) do
		local amount = tonumber(itemCost.amount) or 0
		if amount > 0 then
			lines[#lines + 1] = commaValue(amount) .. "x " .. formatValue(itemCost.name or itemCost.itemid or itemCost.itemId or itemCost.id, "item")
		end
	end

	if #lines == 0 then
		lines[#lines + 1] = "Free"
	end
	return lines
end

local function getSpellRequirementLines(spellData)
	local cost = spellData.cost or {}
	local lines = {}
	for _, storageReq in ipairs(cost.reqs or cost.requirements or {}) do
		local requiredValue = tonumber(storageReq.value or storageReq.amount or storageReq.minValue)
		if requiredValue and requiredValue >= 0 then
			lines[#lines + 1] = formatValue(storageReq.name, "required storage") .. ": " .. commaValue(requiredValue)
		end
	end
	return lines
end

local function buildSpellDescription(spellData)
	local lines = {}
	lines[#lines + 1] = spellData.description or ""
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Words: " .. formatValue(spellData.words)
	lines[#lines + 1] = "Type: " .. formatValue(spellData.spellType, "Spell")
	lines[#lines + 1] = "Level: " .. formatValue(spellData.level or 0)
	lines[#lines + 1] = "Magic Level: " .. formatValue(spellData.magicLevel or 0)
	lines[#lines + 1] = "Mana Cost: " .. formatValue(spellData.manaCost or 0)
	lines[#lines + 1] = ""

	local requirementLines = getSpellRequirementLines(spellData)
	if #requirementLines > 0 then
		lines[#lines + 1] = "Requirements:"
		for _, requirementLine in ipairs(requirementLines) do
			lines[#lines + 1] = requirementLine
		end
		lines[#lines + 1] = ""
	end

	lines[#lines + 1] = "Unlock:"
	for _, costLine in ipairs(getSpellPaymentLines(spellData)) do
		lines[#lines + 1] = costLine
	end
	return table.concat(lines, "\n")
end

local function buildSpellUnlockTooltip(spellData, learned)
	if learned then
		return "Already unlocked"
	end

	local lines = {"Unlock " .. formatValue(spellData.name, "spell")}
	local requirementLines = getSpellRequirementLines(spellData)
	if #requirementLines > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Requirements:"
		for _, requirementLine in ipairs(requirementLines) do
			lines[#lines + 1] = requirementLine
		end
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Cost:"
	for _, costLine in ipairs(getSpellPaymentLines(spellData)) do
		lines[#lines + 1] = costLine
	end
	return table.concat(lines, "\n")
end

local function refreshCategoryEntryState(entry)
	if entry.stateFocused then
		entry:setImageColor("#6f5a25")
		entry:setOpacity(1)
		entry.name:setColor("#ffffff")
	elseif entry.stateHovered then
		entry:setImageColor("#463f33")
		entry:setOpacity(0.98)
		entry.name:setColor("#fff0a6")
	else
		entry:setImageColor("#ffffff")
		entry:setOpacity(0.92)
		entry.name:setColor("#edddc0")
	end
end

local function setCategoryEntryFocused(entry, focused)
	entry.stateFocused = focused
	refreshCategoryEntryState(entry)
end

local function setCategoryEntryHovered(entry, hovered)
	entry.stateHovered = hovered
	refreshCategoryEntryState(entry)
end

local function refreshSpellEntryState(entry)
	if entry.stateFocused then
		entry:setImageColor("#4f4428")
		entry:setOpacity(1)
		entry.name:setColor("#fff0a6")
		entry.details:setColor("#ffffff")
	elseif entry.stateHovered then
		entry:setImageColor("#3f3b34")
		entry:setOpacity(0.98)
		entry.name:setColor("#ffe68a")
		entry.details:setColor("#eee2ce")
	else
		entry:setImageColor("#ffffff")
		entry:setOpacity(0.94)
		entry.name:setColor("#e8be17")
		entry.details:setColor("#cfc7b8")
	end
end

local function setSpellEntryFocused(entry, focused)
	entry.stateFocused = focused
	refreshSpellEntryState(entry)
end

local function setSpellEntryHovered(entry, hovered)
	entry.stateHovered = hovered
	refreshSpellEntryState(entry)
end

function SpellsUnlocker.init()
	ProtocolGame.registerExtendedJSONOpcode(SpellsUnlocker.opcode, SpellsUnlocker.onExtendedOpcode)
	connect(g_game, { onGameStart = SpellsUnlocker.onStart, onGameEnd = SpellsUnlocker.onEnd })
	SpellsUnlocker.onStart()
end

function SpellsUnlocker.terminate()
	ProtocolGame.unregisterExtendedJSONOpcode(SpellsUnlocker.opcode)
	disconnect(g_game, { onGameStart = SpellsUnlocker.onStart, onGameEnd = SpellsUnlocker.onEnd })
	SpellsUnlocker.onEnd()
end

function SpellsUnlocker.onStart()
	if not SpellsUnlocker.UI then
		SpellsUnlocker.UI = g_ui.displayUI("spellsUnlocker")
		SpellsUnlocker.UI:hide()
		SpellsUnlocker.setupStaticCallbacks()
	end

	if not SpellsUnlocker.button then
		SpellsUnlocker.button = modules.client_topmenu.addRightGameToggleButton("SpellsUnlocker", tr("Spells Unlocker"), "/images/options/button_spellsUnlocker", SpellsUnlocker.toggle)
	end

	if g_game.isOnline() then
		SpellsUnlocker.sendOpcode({ topic = "base-data-request" })
	end
end

function SpellsUnlocker.onEnd()
	if SpellsUnlocker.UI then
		SpellsUnlocker.UI:destroy()
		SpellsUnlocker.UI = nil
	end
	if SpellsUnlocker.button then
		SpellsUnlocker.button:destroy()
		SpellsUnlocker.button = nil
	end
end

function SpellsUnlocker.toggle()
	if not SpellsUnlocker.UI then
		return
	end

	if SpellsUnlocker.UI:isVisible() then
		SpellsUnlocker.UI:hide()
		return
	end

	SpellsUnlocker.sendOpcode({ topic = "base-data-request" })
	SpellsUnlocker.UI:show()
	SpellsUnlocker.UI:raise()
	SpellsUnlocker.UI:focus()
end

function SpellsUnlocker.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(SpellsUnlocker.opcode, data)
	end
end

function SpellsUnlocker.onExtendedOpcode(protocol, opcode, data)
	if type(data) ~= "table" then
		return
	end

	if data.topic == "base-data-reply" then
		SpellsUnlocker.treeID = data.treeID
		SpellsUnlocker.goldAmount = data.gold or 0
		SpellsUnlocker.spellPointsAmount = data.spellPoints or 0
		SpellsUnlocker.spellsProgress = data.spellsProgress or {}
		SpellsUnlocker.setupMainWindow()
	elseif data.topic == "message-reply" then
		SpellsUnlocker.showMessage(data.title or "Message", data.message or "")
	end
end

function SpellsUnlocker.setupStaticCallbacks()
	local ui = SpellsUnlocker.UI
	ui.footer.closeButton.onClick = function()
		ui:hide()
	end

	ui.MessageBase.ok.onClick = function()
		ui.MessageBase:hide()
		ui.LockUI:hide()
	end

	ui.ConfirmMessageBase.no.onClick = function()
		ui.ConfirmMessageBase:hide()
		ui.LockUI:hide()
	end
end

function SpellsUnlocker.setupMainWindow()
	local ui = SpellsUnlocker.UI
	if not ui then
		return
	end

	ui.footer.goldAmount:setText(commaValue(SpellsUnlocker.goldAmount))
	ui.footer.spellPointsAmount:setText(commaValue(SpellsUnlocker.spellPointsAmount))

	local selectedTree = SpellsUnlocker.data[SpellsUnlocker.treeID]
	if not selectedTree then
		ui.title:setText("No spell tree available")
		return
	end

	ui.title:setText(selectedTree.name .. " Spells")
	local treeStyle = (SpellsUnlocker.treeStyles or {})[SpellsUnlocker.treeID] or SpellsUnlocker.defaultTreeStyle or {}
	ui.banner:setImageSource(asset(treeStyle.bannerImage))
	ui.banner.border:setImageSource(asset(treeStyle.bannerBorder))
	ui.banner.border:setImageColor(treeStyle.bannerBorderColor or "#edddc0")

	ui.categoryPanel:destroyChildren()
	ui.descriptionPanel:destroyChildren()
	ui.spellsPanel:destroyChildren()

	for categoryId, category in ipairs(selectedTree.categories or {}) do
		SpellsUnlocker.createCategoryEntry(categoryId, category, categoryId == 1)
	end

	local firstChild = ui.categoryPanel:getFirstChild()
	if firstChild then
		ui.categoryPanel:focusChild(firstChild)
	end
end

function SpellsUnlocker.createCategoryEntry(categoryId, category, selected)
	local entry = g_ui.createWidget("CategoryEntrySpellsUnlock", SpellsUnlocker.UI.categoryPanel)
	local categoryIcons = SpellsUnlocker.categoryIcons or {}
	entry.icon:setImageSource(asset(categoryIcons[category.name] or "images/categories/attackIcon"))
	entry.name:setText(category.name)
	entry.onFocusChange = function(widget, focused)
		setCategoryEntryFocused(widget, focused)
		if focused then
			SpellsUnlocker.showCategory(categoryId, category)
		end
	end
	entry.onHoverChange = function(widget, hovered)
		setCategoryEntryHovered(widget, hovered)
		return true
	end
	setCategoryEntryFocused(entry, false)

	if selected then
		scheduleEvent(function()
			if entry and not entry:isDestroyed() then
				SpellsUnlocker.UI.categoryPanel:focusChild(entry)
			end
		end, 1)
	end
end

function SpellsUnlocker.showCategory(categoryId, category)
	SpellsUnlocker.UI.descriptionPanel:destroyChildren()
	SpellsUnlocker.UI.spellsPanel:destroyChildren()

	local firstSpellData = nil
	for spellId, spellData in ipairs(category.spells or {}) do
		firstSpellData = firstSpellData or spellData
		SpellsUnlocker.createSpellEntry(categoryId, spellId, spellData)
	end

	local firstChild = SpellsUnlocker.UI.spellsPanel:getFirstChild()
	if firstChild then
		SpellsUnlocker.UI.spellsPanel:focusChild(firstChild)
	end
	if firstSpellData then
		SpellsUnlocker.showDescription(firstSpellData)
	end
end

function SpellsUnlocker.createSpellEntry(categoryId, spellId, spellData)
	local entry = g_ui.createWidget("SpellEntrySpellsUnlock", SpellsUnlocker.UI.spellsPanel)
	local vocationFolder = (SpellsUnlocker.spellIconFolders or {})[SpellsUnlocker.treeID] or "sorcerer"
	local categoryFolder = (SpellsUnlocker.categoryIconFolders or {})[categoryId] or "attack"
	entry.icon:setImageSource(asset("images/spells/" .. vocationFolder .. "/" .. categoryFolder .. "/" .. spellId))
	entry.name:setText(spellData.name)
	entry.details:setText(string.format(
		"%s | Level %s | Magic Level %s | Mana %s | %s",
		spellData.words or "",
		spellData.level or 0,
		spellData.magicLevel or 0,
		spellData.manaCost or 0,
		spellData.spellType or "Spell"
	))

	local learned = isSpellLearned(categoryId, spellId)
	local unlockTooltip = buildSpellUnlockTooltip(spellData, learned)
	entry:setTooltip(unlockTooltip)
	entry.icon:setTooltip(unlockTooltip)
	entry.name:setTooltip(unlockTooltip)
	entry.details:setTooltip(unlockTooltip)
	entry.unlockButton:setTooltip(unlockTooltip)

	if learned then
		entry.unlockButton:setText("Unlocked")
		entry.unlockButton:setEnabled(false)
	else
		entry.unlockButton.onClick = function()
			SpellsUnlocker.showConfirm("Confirm Spell Unlocking", "Unlock " .. spellData.name .. "?", function()
				SpellsUnlocker.sendOpcode({
					topic = "level-up-request",
					categoryId = categoryId,
					spellId = spellId,
				})
			end)
		end
	end

	entry.onFocusChange = function(widget, focused)
		setSpellEntryFocused(widget, focused)
		if focused then
			SpellsUnlocker.showDescription(spellData)
		end
	end
	entry.onHoverChange = function(widget, hovered)
		setSpellEntryHovered(widget, hovered)
		return true
	end
	setSpellEntryFocused(entry, false)
end

function SpellsUnlocker.showDescription(spellData)
	SpellsUnlocker.UI.descriptionPanel:destroyChildren()
	local label = g_ui.createWidget("SpellDescriptionLabel", SpellsUnlocker.UI.descriptionPanel)
	label:setText(buildSpellDescription(spellData))
end

function SpellsUnlocker.showMessage(title, message)
	local ui = SpellsUnlocker.UI
	if not ui then
		return
	end
	ui.LockUI:show()
	ui.MessageBase:show()
	ui.MessageBase:setText(title)
	ui.MessageBase.text:setText(message)
	ui.MessageBase:raise()
	ui.MessageBase:focus()
end

function SpellsUnlocker.showConfirm(title, message, onConfirm)
	local ui = SpellsUnlocker.UI
	ui.LockUI:show()
	ui.ConfirmMessageBase:show()
	ui.ConfirmMessageBase:setText(title)
	ui.ConfirmMessageBase.text:setText(message)
	ui.ConfirmMessageBase.yes.onClick = function()
		ui.ConfirmMessageBase:hide()
		ui.LockUI:hide()
		if onConfirm then
			onConfirm()
		end
	end
	ui.ConfirmMessageBase:raise()
	ui.ConfirmMessageBase:focus()
end
