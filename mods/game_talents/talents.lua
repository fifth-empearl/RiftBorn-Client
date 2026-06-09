Talents.opcode = 213
Talents.allowLockedTreeNodeTooltips = true

Talents.treeLayout = {
	-- Horizontal tree sizing is based on how many branch lines a tree has.
	branchSlotWidth = 72,
	branchGap = 50,
	paddingLeft = 50,
	paddingRight = 50,

	-- Vertical tree sizing is based on the highest node count in any branch.
	nodeIconSize = 64,
	nodeButtonHeight = 20,
	nodeButtonGap = 6,
	nodeGap = 50,
	connectorWidth = 2,
	paddingTop = 50,
	paddingBottom = 35,
}

local function getTalentConstantName(value)
	return type(value) == "string" and value or tostring(value)
end

local function isRegenGainParam(param)
	local paramName = getTalentConstantName(param)
	return paramName == "CONDITION_PARAM_HEALTHGAIN" or paramName == "CONDITION_PARAM_MANAGAIN" or paramName == "CONDITION_PARAM_SOULGAIN"
end

local function isRegenTickParam(param)
	local paramName = getTalentConstantName(param)
	return paramName == "CONDITION_PARAM_HEALTHTICKS" or paramName == "CONDITION_PARAM_MANATICKS" or paramName == "CONDITION_PARAM_SOULTICKS"
end

local function getScaledParamValue(param, currentLevel)
	local value = tonumber(param.value) or 0
	if param.scale == false then
		return value
	end
	return value * currentLevel
end

local function formatSignedValue(value, suffix)
	suffix = suffix or ""
	if value > 0 then
		return "+" .. value .. suffix
	end
	return tostring(value) .. suffix
end

local function talentImage(path, fallback)
	path = path or fallback
	if type(path) ~= "string" or path == "" then
		return ""
	end
	if path:sub(1, 1) == "/" then
		return path
	end
	return "/game_talents/images/" .. path
end

function Talents.init()
	connect(g_game, {onGameStart = Talents.onGameStart, onGameEnd = Talents.onGameEnd})
	ProtocolGame.registerExtendedJSONOpcode(Talents.opcode, Talents.onExtendedOpcode)
	Talents.onGameStart()
end

function Talents.terminate()
	disconnect(g_game, {onGameStart = Talents.onGameStart, onGameEnd = Talents.onGameEnd})
	ProtocolGame.unregisterExtendedJSONOpcode(Talents.opcode)
	Talents.onGameEnd()
end

function Talents.onGameStart()
	if not Talents.UI then
		Talents.UI = g_ui.displayUI("talents")
	end
	Talents.UI:hide()

	if not Talents.Button then
		Talents.Button = modules.client_topmenu.addRightGameToggleButton("talentsButton", tr("Talents"), "/images/options/button_talents", Talents.toggle)
	end

	if not Talents.Tooltip then
		Talents.Tooltip = g_ui.displayUI("talentTooltip")
		Talents.Tooltip:hide()
	end

	Talents.cachedProgress = {}
	Talents.cachedAvailableTrees = {}
	Talents.cachedUnlockedTrees = {}
	Talents.cachedTreeLockReasons = {}
	Talents.cachedAvailablePoints = 0
	Talents.cachedTotalPoints = 0
	Talents.selectedTreeId = nil
	Talents.setupDialogButtons()

	if Talents.UI.ResetButton then
		Talents.UI.ResetButton.onClick = Talents.onResetButtonClick
	end

	if g_game.isOnline() then
		Talents.sendOpcode({topic = "base-data-request"})
	end
end

function Talents.onGameEnd()
	disconnect(rootWidget, {onMouseMove = Talents.moveToolTip})
	if Talents.Tooltip then
		Talents.Tooltip:destroy()
		Talents.Tooltip = nil
	end
	if Talents.Button then
		Talents.Button:destroy()
		Talents.Button = nil
	end
	if Talents.UI then
		Talents.UI:destroy()
		Talents.UI = nil
	end
end

function Talents.toggle()
	if Talents.UI:isVisible() then
		Talents.hide()
	else
		Talents.show()
	end
end

function Talents.show()
	Talents.UI:show()
	Talents.UI:raise()
	Talents.UI:focus()
	Talents.sendOpcode({topic = "base-data-request"})
end

function Talents.hide()
	if Talents.UI then
		Talents.UI:hide()
	end
end

function Talents.moveToolTip()
	if not Talents.Tooltip or not Talents.Tooltip:isVisible() then
		return
	end
	local pos = g_window.getMousePosition()
	local windowSize = g_window.getSize()
	local tipSize = Talents.Tooltip:getSize()
	pos.x = pos.x + 1
	pos.y = pos.y + 1
	pos.x = windowSize.width - (pos.x + tipSize.width) < 10 and pos.x - tipSize.width - 3 or pos.x + 10
	pos.y = windowSize.height - (pos.y + tipSize.height) < 10 and pos.y - tipSize.height - 3 or pos.y + 10
	Talents.Tooltip:setPosition(pos)
	Talents.Tooltip:raise()
end

function Talents.getEffectPreviewLines(talentData, currentLevel)
	local lines = {}
	local nextLevel = math.min(currentLevel + 1, tonumber(talentData.maxLevel) or 1)

	for _, effect in ipairs(talentData.effect or {}) do
		local effectName = effect.name or talentData.name or "Buff"
		if effect.type == "condition" then
			if getTalentConstantName(effect.conditionType) == "CONDITION_REGENERATION" then
				local tickTime = nil
				local currentGain = 0
				local nextGain = 0
				for _, param in ipairs(effect.params or {}) do
					if isRegenGainParam(param.param) then
						currentGain = currentGain + getScaledParamValue(param, currentLevel)
						nextGain = nextGain + getScaledParamValue(param, nextLevel)
					elseif isRegenTickParam(param.param) then
						tickTime = tonumber(param.value) or tickTime
					end
				end
				if currentGain ~= 0 or nextGain ~= 0 then
					local tickText = tickTime and string.format(" per %.1fs", tickTime / 1000.0) or ""
					lines[#lines + 1] = string.format("%s: Current %s%s | Next %s%s", effectName, formatSignedValue(currentGain), tickText, formatSignedValue(nextGain), tickText)
				end
			else
				local currentTotal = 0
				local nextTotal = 0
				for _, param in ipairs(effect.params or {}) do
					currentTotal = currentTotal + getScaledParamValue(param, currentLevel)
					nextTotal = nextTotal + getScaledParamValue(param, nextLevel)
				end
				if currentTotal ~= 0 or nextTotal ~= 0 then
					local suffix = effect.percent and "%" or ""
					lines[#lines + 1] = string.format("%s: Current %s | Next %s", effectName, formatSignedValue(currentTotal, suffix), formatSignedValue(nextTotal, suffix))
				end
			end
		elseif effect.type == "storage" then
			local currentValue = (tonumber(effect.value) or 0) * currentLevel
			local nextValue = (tonumber(effect.value) or 0) * nextLevel
			if currentValue ~= 0 or nextValue ~= 0 then
				lines[#lines + 1] = string.format("%s: Current %s | Next %s", effectName, formatSignedValue(currentValue), formatSignedValue(nextValue))
			end
		elseif effect.type == "spell" then
			local prefix = effect.placeholder and "Example spell unlock: " or "Unlocks spell: "
			lines[#lines + 1] = prefix .. (effect.name or "unknown")
		end
	end

	return lines
end

function Talents.applyTooltip(widget)
	local talentData = widget.talentData
	Talents.moveToolTip()
	Talents.Tooltip:setText(talentData.name)
	local lines = {talentData.description or ""}
	for _, line in ipairs(Talents.getEffectPreviewLines(talentData, widget.currentLevel or 0)) do
		lines[#lines + 1] = line
	end
	if widget.lockReason and widget.lockReason ~= "" then
		lines[#lines + 1] = "Locked: " .. widget.lockReason
	end
	Talents.Tooltip.description:setText(table.concat(lines, "\n"))
	Talents.Tooltip.maxLevel:setText("Level: " .. (widget.currentLevel or 0) .. "/" .. (talentData.maxLevel or 1))
	Talents.Tooltip:setHeight(Talents.Tooltip.description:getTextSize().height + Talents.Tooltip.maxLevel:getHeight() + 80)
end

function Talents.onHoverChange(widget, hovered)
	if hovered and widget.isTreeLocked and not Talents.allowLockedTreeNodeTooltips then
		return
	end
	if hovered then
		Talents.applyTooltip(widget)
		Talents.Tooltip:show()
		connect(rootWidget, {onMouseMove = Talents.moveToolTip})
	else
		Talents.Tooltip:hide()
		disconnect(rootWidget, {onMouseMove = Talents.moveToolTip})
	end
end

function Talents.setupDialogButtons()
	if Talents.UI.MessageBase and Talents.UI.MessageBase.ConfirmButton then
		Talents.UI.MessageBase.ConfirmButton.onClick = function()
			Talents.UI.MessageBase:setVisible(false)
			Talents.UI.LockUI:setVisible(false)
		end
	end
	if Talents.UI.ConfirmMessageBase and Talents.UI.ConfirmMessageBase.CancelButton then
		Talents.UI.ConfirmMessageBase.CancelButton.onClick = function()
			Talents.UI.ConfirmMessageBase:setVisible(false)
			Talents.UI.LockUI:setVisible(false)
		end
	end
end

Talents.dialogLayout = {
	minHeight = 112,
	maxWindowMargin = 80,
	contentPadding = 8,
}

function Talents.hideDialogs()
	if Talents.UI.MessageBase then
		Talents.UI.MessageBase:setVisible(false)
	end
	if Talents.UI.ConfirmMessageBase then
		Talents.UI.ConfirmMessageBase:setVisible(false)
	end
end

function Talents.getDialogContentWidgets(dialog)
	return {
		text = dialog:recursiveGetChildById("Text"),
		scroll = dialog:recursiveGetChildById("TextScroll"),
		scrollbar = dialog:recursiveGetChildById("TextScrollBar"),
		button = dialog:recursiveGetChildById("ConfirmButton"),
	}
end

function Talents.resizeDialog(dialog)
	local widgets = Talents.getDialogContentWidgets(dialog)
	if not widgets.text or not widgets.scroll or not widgets.button then
		return
	end

	local layout = Talents.dialogLayout
	local maxHeight = math.max(layout.minHeight, Talents.UI:getHeight() - layout.maxWindowMargin)

	dialog:setHeight(layout.minHeight)
	dialog:updateLayout()
	widgets.text:setWidth(widgets.scroll:getWidth())

	local textHeight = widgets.text:getTextSize().height
	local chromeHeight =
		widgets.scroll:getMarginTop() +
		widgets.scroll:getMarginBottom() +
		widgets.button:getHeight() +
		widgets.button:getMarginBottom()
	local targetHeight = math.min(maxHeight, math.max(layout.minHeight, textHeight + chromeHeight + layout.contentPadding))

	dialog:setHeight(targetHeight)
	dialog:updateLayout()
	widgets.text:setWidth(widgets.scroll:getWidth())

	if widgets.scrollbar then
		local needsScrollbar = widgets.text:getTextSize().height > widgets.scroll:getHeight()
		widgets.scrollbar:setVisible(needsScrollbar)
		widgets.scrollbar:setValue(0)
	end

	local virtualOffset = widgets.scroll:getVirtualOffset()
	virtualOffset.x = 0
	virtualOffset.y = 0
	widgets.scroll:setVirtualOffset(virtualOffset)
	widgets.scroll:updateScrollBars()
end

function Talents.setupDialog(dialog, title, message)
	Talents.hideDialogs()
	Talents.UI.LockUI:setVisible(true)
	dialog:setVisible(true)
	dialog:setText(title)
	local widgets = Talents.getDialogContentWidgets(dialog)
	if not widgets.text then
		return
	end
	widgets.text:setText(message or "")
	Talents.resizeDialog(dialog)
	addEvent(function()
		if Talents.UI and dialog:isVisible() then
			Talents.resizeDialog(dialog)
		end
	end)
end

function Talents.setupMessage(title, message)
	Talents.setupDialog(Talents.UI.MessageBase, title, message)
end

function Talents.setupConfirmMessage(title, message, onConfirm)
	Talents.setupDialog(Talents.UI.ConfirmMessageBase, title, message)
	Talents.UI.ConfirmMessageBase.ConfirmButton.onClick = function()
		if onConfirm then
			onConfirm()
		end
		Talents.UI.ConfirmMessageBase:setVisible(false)
		Talents.UI.LockUI:setVisible(false)
	end
end

function Talents.setupPointsData(data)
	Talents.cachedAvailablePoints = data.availablePoints or 0
	Talents.cachedTotalPoints = data.totalPoints or 0
	Talents.UI.AvailableTalentPoints:setText("Available Talent Points: " .. (data.availablePoints or 0))
	Talents.UI.TotalTalentPoints:setText("Total Talent Points: " .. (data.totalPoints or 0))
end

function Talents.tableContains(values, value)
	for _, entry in ipairs(values or {}) do
		if entry == value then
			return true
		end
	end
	return false
end

function Talents.isTreeActive(treeId)
	return Talents.tableContains(Talents.cachedAvailableTrees, treeId) and Talents.tableContains(Talents.cachedUnlockedTrees, treeId)
end

function Talents.getTreeLockReason(treeId)
	local reasons = Talents.cachedTreeLockReasons and (Talents.cachedTreeLockReasons[treeId] or Talents.cachedTreeLockReasons[tostring(treeId)])
	if type(reasons) == "table" and #reasons > 0 then
		return table.concat(reasons, "\n")
	end
	return "Locked"
end

function Talents.setupCategories()
	Talents.UI.talentsCategoryPanel:destroyChildren()
	local isFirstCategory = true
	local firstCategory = nil
	local selectedCategory = nil
	for _, treeId in ipairs(Talents.cachedAvailableTrees or {}) do
		local treeData = Talents.trees[treeId]
		if treeData then
			local categoryEntry = Talents.createCategoryEntry(treeId, treeData, isFirstCategory, Talents.tableContains(Talents.cachedUnlockedTrees, treeId))
			firstCategory = firstCategory or categoryEntry
			if treeId == Talents.selectedTreeId then
				selectedCategory = categoryEntry
			end
			isFirstCategory = false
		end
	end
	local categoryToFocus = selectedCategory or firstCategory
	if categoryToFocus then
		Talents.UI.talentsCategoryPanel:focusChild(categoryToFocus)
	end
end

function Talents.createCategoryEntry(treeId, treeData, isFirstCategory, isUnlocked)
	local categoryEntry = g_ui.createWidget("TalentsCategoryEntry", Talents.UI.talentsCategoryPanel)
	categoryEntry.TalentsCategoryEntryName:setText(treeData.name)
	categoryEntry.TalentsCategoryEntryIcon:setImageSource(talentImage(treeData.categoryIcon, "trees/sorc_arcane_core"))
	if isFirstCategory then
		categoryEntry:setMarginLeft(20)
	end
	categoryEntry.onFocusChange = function(_, focused)
		if focused then
			Talents.selectedTreeId = treeId
			Talents.showTree(treeId, treeData, isUnlocked)
		end
	end
	categoryEntry:setFocusable(true)
	categoryEntry.lock:setVisible(not isUnlocked)
	categoryEntry.lock:setTooltip(Talents.getTreeLockReason(treeId))
	return categoryEntry
end

function Talents.getTreeScroll()
	if not Talents.UI then
		return nil
	end
	return {
		x = Talents.UI.internalHorizontalScrollBar and Talents.UI.internalHorizontalScrollBar:getValue() or 0,
		y = Talents.UI.internalScrollBar and Talents.UI.internalScrollBar:getValue() or 0,
	}
end

function Talents.restoreTreeScroll(scroll)
	if not scroll then
		return
	end
	addEvent(function()
		if not Talents.UI then
			return
		end
		if Talents.UI.internalHorizontalScrollBar then
			Talents.UI.internalHorizontalScrollBar:setValue(scroll.x or 0)
		end
		if Talents.UI.internalScrollBar then
			Talents.UI.internalScrollBar:setValue(scroll.y or 0)
		end
	end)
end

function Talents.getTreeMetrics(treeData)
	local layout = Talents.treeLayout
	local branchCount = #treeData
	local maxNodes = 0
	for _, branchData in ipairs(treeData) do
		maxNodes = math.max(maxNodes, #(branchData.talents or {}))
	end

	local nodeBlockHeight = layout.nodeIconSize + layout.nodeButtonGap + layout.nodeButtonHeight
	local width = layout.paddingLeft + (branchCount * layout.branchSlotWidth) + (math.max(0, branchCount - 1) * layout.branchGap) + layout.paddingRight
	local height = layout.paddingTop + (maxNodes * nodeBlockHeight) + (math.max(0, maxNodes - 1) * layout.nodeGap) + layout.paddingBottom

	return {
		branchCount = branchCount,
		maxNodes = maxNodes,
		nodeBlockHeight = nodeBlockHeight,
		requiredWidth = width,
		requiredHeight = height,
	}
end

function Talents.getTreeContentSize(treeData)
	local viewport = Talents.UI.internalPanel:getPaddingRect()
	local metrics = Talents.getTreeMetrics(treeData)
	return {
		width = math.max(metrics.requiredWidth, viewport.width),
		height = math.max(metrics.requiredHeight, viewport.height),
	}
end

function Talents.showTree(treeId, treeData, isUnlocked)
	Talents.UI.internalPanel:destroyChildren()
	local background = g_ui.createWidget("TalentBackground", Talents.UI.internalPanel)
	background:setImageSource(talentImage(treeData.background, "backgrounds/sorc_arcane_core"))
	local contentSize = Talents.getTreeContentSize(treeData)
	background:setSize(contentSize)

	for branchIndex, branchData in ipairs(treeData) do
		local branchProgress = Talents.cachedProgress[treeId] and Talents.cachedProgress[treeId][branchIndex] or {}
		Talents.createBranch(treeId, branchIndex, branchData, branchProgress, isUnlocked)
	end

	if not isUnlocked then
		local lock = g_ui.createWidget("TalentBackground", Talents.UI.internalPanel)
		lock:setBackgroundColor("#000000")
		lock:setOpacity(0.4)
		lock:setPhantom(true)
		lock:setSize(contentSize)
	end
end

function Talents.getTalentLockReason(treeId, talentIndex, talentData, branchProgress, isTreeUnlocked)
	local currentLevel = branchProgress[talentIndex] or 0
	local maxLevel = tonumber(talentData.maxLevel) or 1
	if not isTreeUnlocked then
		return Talents.getTreeLockReason(treeId)
	end
	if currentLevel >= maxLevel then
		return "This talent is already at maximum level."
	end
	if (Talents.cachedAvailablePoints or 0) <= 0 then
		return "You do not have any available talent points."
	end
	if talentIndex > 1 then
		local requiredPreviousLevel = tonumber(talentData.prevTalentLevelNeeded) or 1
		local previousLevel = branchProgress[talentIndex - 1] or 0
		if previousLevel < requiredPreviousLevel then
			return "Requires previous talent level " .. requiredPreviousLevel .. "."
		end
	end
	return nil
end

function Talents.getTalentPathState(talentIndex, talentData, branchProgress, isTreeUnlocked)
	if not isTreeUnlocked then
		return "locked"
	end

	if talentIndex > 1 then
		local requiredPreviousLevel = tonumber(talentData.prevTalentLevelNeeded) or 1
		local previousLevel = branchProgress[talentIndex - 1] or 0
		if previousLevel < requiredPreviousLevel then
			return "locked"
		end
	end

	local currentLevel = branchProgress[talentIndex] or 0
	local maxLevel = tonumber(talentData.maxLevel) or 1
	if currentLevel >= maxLevel then
		return "unlocked"
	end

	if (Talents.cachedAvailablePoints or 0) <= 0 then
		return "unlocked"
	end

	return "levelable"
end

function Talents.applyConnectorState(connector, state)
	if state == "levelable" then
		connector:setBackgroundColor("#ffd84a")
		connector:setOpacity(1.0)
	elseif state == "unlocked" then
		connector:setBackgroundColor("#9f8125")
		connector:setOpacity(0.75)
	else
		connector:setBackgroundColor("#d8d8d8")
		connector:setOpacity(0.35)
	end
end

function Talents.createBranch(treeId, branchIndex, branchData, branchProgress, isTreeUnlocked)
	local layout = Talents.treeLayout
	local leftMargin = layout.paddingLeft + ((branchIndex - 1) * (layout.branchSlotWidth + layout.branchGap))
	local prevButton = nil

	for talentIndex, talentData in ipairs(branchData.talents or {}) do
		local talentWidgetId = "tree" .. treeId .. "_branch" .. branchIndex .. "_talent" .. talentIndex
		local talent = g_ui.createWidget("TalentEntry", Talents.UI.internalPanel)
		talent:setId(talentWidgetId)
		talent:setImageSource(talentImage(talentData.icon, "nodes/spark_focus"))
		talent:addAnchor(AnchorLeft, "parent", AnchorLeft)
		talent:setMarginLeft(leftMargin)

		local border = g_ui.createWidget("TalentEntryBorder", talent)
		border:setImageSource(branchData.border or "/images/ui/borders/43")
		border:setImageColor(branchData.color or "#ffffff")
		border.talentData = talentData
		border.currentLevel = branchProgress[talentIndex] or 0
		border.lockReason = Talents.getTalentLockReason(treeId, talentIndex, talentData, branchProgress, isTreeUnlocked)
		border.isTreeLocked = not isTreeUnlocked
		border.onHoverChange = Talents.onHoverChange
		talent:setOpacity(border.lockReason and 0.45 or 1.0)

		local talentLevel = g_ui.createWidget("TalentEntryLevel", Talents.UI.internalPanel)
		talentLevel:addAnchor(AnchorLeft, talentWidgetId, AnchorLeft)
		talentLevel:addAnchor(AnchorTop, talentWidgetId, AnchorTop)
		talentLevel:setText((branchProgress[talentIndex] or 0) .. "/" .. (talentData.maxLevel or 1))

		if prevButton then
			talent:addAnchor(AnchorTop, prevButton:getId(), AnchorBottom)
			talent:setMarginTop(layout.nodeGap)
			talent:setMarginBottom(40)
			local connector = g_ui.createWidget("UIWidget", Talents.UI.internalPanel)
			connector:setId("connector_" .. talentWidgetId)
			connector:addAnchor(AnchorTop, prevButton:getId(), AnchorBottom)
			connector:addAnchor(AnchorBottom, talent:getId(), AnchorTop)
			connector:addAnchor(AnchorHorizontalCenter, talent:getId(), AnchorHorizontalCenter)
			connector:setWidth(layout.connectorWidth)
			connector:setFocusable(false)
			connector:setPhantom(true)
			Talents.applyConnectorState(connector, Talents.getTalentPathState(talentIndex, talentData, branchProgress, isTreeUnlocked))
			Talents.UI.internalPanel:moveChildToIndex(connector, 2)
		else
			talent:addAnchor(AnchorTop, "parent", AnchorTop)
			talent:setMarginTop(layout.paddingTop)
		end

		local button = g_ui.createWidget("TalentButton", Talents.UI.internalPanel)
		button:setId("button_" .. talentWidgetId)
		button:addAnchor(AnchorTop, talent:getId(), AnchorBottom)
		button:addAnchor(AnchorHorizontalCenter, talent:getId(), AnchorHorizontalCenter)
		button:setMarginTop(layout.nodeButtonGap)
		button:setFocusable(false)
		button:setEnabled(border.lockReason == nil)
		button:setTooltip(border.lockReason or "Ctrl + left click levels up without confirmation")
		button.onClick = function()
			if not border.lockReason then
				Talents.onTalentLevelupButtonClick(treeId, branchIndex, talentIndex)
			end
		end
		prevButton = button
	end
end

function Talents.onTalentLevelupButtonClick(treeId, branchId, talentId)
	local request = function(silentSuccess)
		Talents.sendOpcode({topic = "talent-levelup-request", treeId = treeId, branchId = branchId, talentId = talentId, silentSuccess = silentSuccess == true})
	end
	if g_keyboard.isCtrlPressed() then
		request(true)
	else
		Talents.setupConfirmMessage("Confirm Level Up", "Are you sure you want to level up this talent?", function()
			request(false)
		end)
	end
end

function Talents.onResetButtonClick()
	Talents.sendOpcode({topic = "reset-talents-request"})
end

function Talents.handleResetRequirements(data)
	Talents.setupConfirmMessage("Confirm Talents Reset", "To reset talents, you need:\n" .. (data.requirements or "No requirements.") .. "\n\nAre you sure?", function()
		Talents.sendOpcode({topic = "confirm-reset-request"})
	end)
end

function Talents.updateTotalTalentsDisplay()
	Talents.UI.totalTalentsPanel:destroyChildren()
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
				tooltip = options.tooltip or "",
			}
			combinedEffectOrder[#combinedEffectOrder + 1] = key
		end

		combinedEffects[key].total = combinedEffects[key].total + value
	end

	for treeId, treeData in pairs(Talents.trees or {}) do
		if Talents.isTreeActive(treeId) then
			for branchId, branchData in ipairs(treeData) do
				local branchProgress = Talents.cachedProgress[treeId] and Talents.cachedProgress[treeId][branchId] or {}
				for talentId, talentData in ipairs(branchData.talents or {}) do
					local currentLevel = branchProgress[talentId] or 0
					if currentLevel > 0 then
						for _, effect in ipairs(talentData.effect or {}) do
							local effectName = effect.name or talentData.name or "Buff"
							if effect.type == "condition" then
								if getTalentConstantName(effect.conditionType) == "CONDITION_REGENERATION" then
									local tickTime = nil
									local totalGain = 0

									for _, param in ipairs(effect.params or {}) do
										if isRegenGainParam(param.param) then
											totalGain = totalGain + getScaledParamValue(param, currentLevel)
										elseif isRegenTickParam(param.param) then
											tickTime = tonumber(param.value) or tickTime
										end
									end

									if totalGain ~= 0 then
										addEffectValue(effectName, totalGain, {tickTime = tickTime, tooltip = talentData.description or ""})
									end
								else
									local total = 0
									for _, param in ipairs(effect.params or {}) do
										total = total + getScaledParamValue(param, currentLevel)
									end
									if total ~= 0 then
										addEffectValue(effectName, total, {suffix = effect.percent and "%" or "", tooltip = talentData.description or ""})
									end
								end
							elseif effect.type == "storage" then
								local totalValue = (tonumber(effect.value) or 0) * currentLevel
								if totalValue ~= 0 then
									addEffectValue(effectName, totalValue, {tooltip = talentData.description or ""})
								end
							end
						end
					end
				end
			end
		end
	end

	for _, key in ipairs(combinedEffectOrder) do
		local data = combinedEffects[key]
		local label = g_ui.createWidget("Label", Talents.UI.totalTalentsPanel)
		label:setTextWrap(true)
		label:setTextAutoResize(true)
		label:setTooltip(data.tooltip or "")

		local valueText = string.format("+%d%s", data.total, data.suffix)
		if data.tickTime and data.tickTime > 0 then
			label:setText(string.format("- %s: %s per %.1fs", data.name, valueText, data.tickTime / 1000.0))
		else
			label:setText(string.format("- %s: %s", data.name, valueText))
		end
	end
end

function Talents.convertKeysToNumber(t)
	local newt = {}
	for key, value in pairs(t or {}) do
		local newKey = tonumber(key) or key
		newt[newKey] = type(value) == "table" and Talents.convertKeysToNumber(value) or value
	end
	return newt
end

function Talents.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(Talents.opcode, data)
	end
end

function Talents.onExtendedOpcode(protocol, opcode, data)
	if type(data) ~= "table" then
		return
	end
	if data.topic == "points-data-reply" then
		Talents.setupPointsData(data)
	elseif data.topic == "message-reply" then
		Talents.setupMessage(data.title or "Talents", data.message or "")
	elseif data.topic == "reset-requirements-reply" then
		Talents.handleResetRequirements(data)
	elseif data.topic == "base-data-reply" then
		local treeScroll = Talents.getTreeScroll()
		Talents.cachedProgress = Talents.convertKeysToNumber(data.progress or {})
		Talents.cachedAvailableTrees = data.availableTrees or {}
		Talents.cachedUnlockedTrees = data.unlockedTrees or {}
		Talents.cachedTreeLockReasons = Talents.convertKeysToNumber(data.treeLockReasons or {})
		Talents.setupPointsData(data)
		Talents.setupCategories()
		Talents.updateTotalTalentsDisplay()
		Talents.restoreTreeScroll(treeScroll)
	end
end
