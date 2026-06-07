ProgressiveTasks = ProgressiveTasks or {}
ProgressiveTasks.Opcode = 43
ProgressiveTasks.rewardIcons = {
	["Placeholder Points"]  = "images/ui/honorPoints",
	["Spell Points"] = "images/ui/spellPoints",
	["Task Prestige Exp"] = "images/ui/decor1",
	["Gold"] = "images/ui/gold",
	["Exp"] = "images/ui/exp",
	["Default"] = "images/ui/Lobby_Tooltip_Anchor" -- if not identified
}

function ProgressiveTasks.getCachedItemInfo(itemId)
	if not ProgressiveTasks.cachedItemsInfo then
		return nil
	end
	return ProgressiveTasks.cachedItemsInfo[tostring(itemId)]
end


------ Initialization & Termination

function ProgressiveTasks.init()
	ProtocolGame.registerExtendedJSONOpcode(ProgressiveTasks.Opcode, ProgressiveTasks.onExtendedOpcode)
	connect(g_game, {onGameStart = ProgressiveTasks.onStart, onGameEnd = ProgressiveTasks.onEnd})
	if g_game.isOnline() then
		ProgressiveTasks.onStart()
	end
end

function ProgressiveTasks.terminate()
	ProtocolGame.unregisterExtendedJSONOpcode(ProgressiveTasks.Opcode)
	disconnect(g_game, {onGameStart = ProgressiveTasks.onStart, onGameEnd = ProgressiveTasks.onEnd})
	ProgressiveTasks.onEnd()
end

function ProgressiveTasks.onStart()
	if not ProgressiveTasks.Button and not ProgressiveTasks.npcAccessed then
		ProgressiveTasks.Button =
			modules.client_topmenu.addRightGameToggleButton(
			"ProgressiveTasks",
			tr("Progessive Tasks"),
			"/images/options/button_ptasks",
			ProgressiveTasks.toggle
		)
	end
	if not ProgressiveTasks.UI then
		ProgressiveTasks.UI = g_ui.displayUI("progressiveTasks")
	end

	if not ProgressiveTasks.trackerWindow then
		ProgressiveTasks.trackerWindow = g_ui.loadUI("progressiveTasks_tracker", modules.game_interface.getRightPanel())
	end
	local scrollbar = ProgressiveTasks.trackerWindow:getChildById("miniwindowScrollBar")
	scrollbar:mergeStyle({["$!on"] = {}})
	ProgressiveTasks.trackerWindow:setContentMinimumHeight(90)
	ProgressiveTasks.trackerWindow:setup()
	ProgressiveTasks.setupTrackerHeaderButtons()

	ProgressiveTasks.UI.sortingComboBox:addOption("Highest level first")
	ProgressiveTasks.UI.sortingComboBox:addOption("Lowest level first")

	ProgressiveTasks.UI.sortingComboBox.onOptionChange = function()
		ProgressiveTasks.onSortingOptionChange(ProgressiveTasks.UI.sortingComboBox:getText())
	end

	ProgressiveTasks.UI.filteringComboBox:addOption("Show All")
	ProgressiveTasks.UI.filteringComboBox:addOption("Active Tasks")
	ProgressiveTasks.UI.filteringComboBox:addOption("Ready (Repeatable & No CD)")
	ProgressiveTasks.UI.filteringComboBox:addOption("On Cooldown")

	ProgressiveTasks.UI.filteringComboBox.onOptionChange = function()
		ProgressiveTasks.onFilteringOptionChange(ProgressiveTasks.UI.filteringComboBox:getText())
	end

	ProgressiveTasks.setupOkayButton()
	ProgressiveTasks.setupNoButton()

	ProgressiveTasks.UI.topInfoPanel.rankRewardsButton.onClick = function()
		ProgressiveTasks.UI.RankRewardsWindow:setVisible(true)
		ProgressiveTasks.UI.LockUI:setVisible(true)
	end
	ProgressiveTasks.UI.trackerButton.onClick = ProgressiveTasks.toggleTracker

	ProgressiveTasks.UI:setVisible(false)
	ProgressiveTasks.sendOpcode({topic = "base-data-request"})
end

function ProgressiveTasks.setupTrackerHeaderButtons()
	if not ProgressiveTasks.trackerWindow then
		return
	end

	for _, buttonId in ipairs({"newWindowButton", "toggleFilterButton"}) do
		local button = ProgressiveTasks.trackerWindow:recursiveGetChildById(buttonId)
		if button then
			button:setVisible(false)
		end
	end

	local contextMenuButton = ProgressiveTasks.trackerWindow:recursiveGetChildById("contextMenuButton")
	local minimizeButton = ProgressiveTasks.trackerWindow:recursiveGetChildById("minimizeButton")
	if contextMenuButton and minimizeButton then
		contextMenuButton:setVisible(true)
		contextMenuButton:breakAnchors()
		contextMenuButton:addAnchor(AnchorTop, minimizeButton:getId(), AnchorTop)
		contextMenuButton:addAnchor(AnchorRight, minimizeButton:getId(), AnchorLeft)
		contextMenuButton:setMarginRight(2)
		contextMenuButton:setMarginTop(0)
		contextMenuButton:setTooltip(tr("Progressive Tasks"))
		contextMenuButton.onClick = ProgressiveTasks.toggle
	end

	local lockButton = ProgressiveTasks.trackerWindow:recursiveGetChildById("lockButton")
	if lockButton and contextMenuButton then
		lockButton:setVisible(true)
		lockButton:breakAnchors()
		lockButton:addAnchor(AnchorTop, contextMenuButton:getId(), AnchorTop)
		lockButton:addAnchor(AnchorRight, contextMenuButton:getId(), AnchorLeft)
		lockButton:setMarginRight(2)
		lockButton:setMarginTop(0)
	end
end

function ProgressiveTasks.onEnd()
	if ProgressiveTasks.UI then
		ProgressiveTasks.UI:destroy()
		ProgressiveTasks.UI = nil
	end
	if ProgressiveTasks.Button then
		ProgressiveTasks.Button:destroy()
		ProgressiveTasks.Button = nil
	end
	if ProgressiveTasks.trackerWindow then
		ProgressiveTasks.trackerWindow:destroy()
		ProgressiveTasks.trackerWindow = nil
	end
	if ProgressiveTasks.cooldownEvent then
		removeEvent(ProgressiveTasks.cooldownEvent)
		ProgressiveTasks.cooldownEvent = nil
	end
end


------ UI Setup & Handling

function ProgressiveTasks.toggle()
	if ProgressiveTasks.UI:isVisible() then
		ProgressiveTasks.UI:setVisible(false)
	else
		ProgressiveTasks.UI:setVisible(true)
		ProgressiveTasks.UI:focus()
	end
end

function ProgressiveTasks.hide()
	if ProgressiveTasks.UI:isVisible() then
		ProgressiveTasks.UI:setVisible(false)
	end
end

function ProgressiveTasks.show()
	if not ProgressiveTasks.UI:isVisible() then
		ProgressiveTasks.UI:setVisible(true)
		ProgressiveTasks.UI:focus()
	end
end

function ProgressiveTasks.toggleTracker()
	if ProgressiveTasks.trackerWindow:isVisible() then
		ProgressiveTasks.trackerWindow:setVisible(false)
	else
		ProgressiveTasks.trackerWindow:setVisible(true)
	end
end

function ProgressiveTasks.populateRankRewards()
	for i, rankData in ipairs(ProgressiveTasks.taskPrestigeRankTable) do
		local rankEntry = g_ui.createWidget("RankRewardEntry", ProgressiveTasks.UI.RankRewardsWindow.rankRewardsPanel)

		rankEntry.rankName:setText("Rank: " .. rankData.name)

		rankEntry.rankExp:setText("Exp: " .. rankData.exp)

		local nameForFile = string.gsub(rankData.name, " ", "_") -- convert "Gold 1" to "Gold_1"
		local imagePath = "images/ui/ranks/" .. nameForFile .. "_Rank.png"
		rankEntry.rankIcon:setImageSource(imagePath)

		ProgressiveTasks.populateRankRewardPanel(rankEntry.rewardsPanel, rankData.rewards)
	end
end

function ProgressiveTasks.populateRankRewardPanel(rewardsPanel, rewards)
	for _, reward in ipairs(rewards) do
		if reward.type == "storages" then
			for _, storageData in ipairs(reward.storages) do
				local rewardEntry = g_ui.createWidget("RewardEntry", rewardsPanel)
				local rewardIcon =
					ProgressiveTasks.rewardIcons[storageData.name] or ProgressiveTasks.rewardIcons["Default"]
				rewardEntry.reward:setImageSource(rewardIcon)
				rewardEntry.info:setText(tostring(storageData.amount) .. "x")
				rewardEntry:setTooltip(storageData.name)
				rewardEntry.reward:setTooltip(storageData.name)
				rewardEntry.info:setTooltip(storageData.name)
			end
		elseif reward.type == "items" then
			for _, itemData in ipairs(reward.items) do
				local itemInfo = ProgressiveTasks.getCachedItemInfo(itemData.id)
				if itemInfo and itemInfo.itemId then
					local rewardEntry = g_ui.createWidget("SingleItemEntry", rewardsPanel)
					rewardEntry.item:setItemId(itemInfo.itemId)
					rewardEntry.item:setItemCount(itemData.amount)
					rewardEntry.item:setShowCount(false)
					rewardEntry.info:setText(tostring(itemData.amount) .. "x")
					rewardEntry:setTooltip(itemInfo.name)
					rewardEntry.item:setTooltip(itemInfo.name)
					rewardEntry.info:setTooltip(itemInfo.name)
				end
			end
		else
			local rewardEntry = g_ui.createWidget("RewardEntry", rewardsPanel)
			local rewardIcon = ProgressiveTasks.rewardIcons[reward.type] or ProgressiveTasks.rewardIcons["Default"]
			rewardEntry.reward:setImageSource(rewardIcon)
			rewardEntry.info:setText(tostring(reward.amount))
			rewardEntry:setTooltip(reward.type)
			rewardEntry.reward:setTooltip(reward.type)
			rewardEntry.info:setTooltip(reward.type)
		end
	end
end

function ProgressiveTasks.setupMessage(title, message)
	ProgressiveTasks.UI.LockUI:setVisible(true)
	ProgressiveTasks.UI.MessageBase:setVisible(true)
	ProgressiveTasks.UI.MessageBase:setText(title)
	ProgressiveTasks.UI.MessageBase.Text:setText(message)
	ProgressiveTasks.UI.MessageBase:setHeight(ProgressiveTasks.UI.MessageBase.Text:getTextSize().height + 100)
end

function ProgressiveTasks.setupConfirmMessage(title, message, onConfirm)
	ProgressiveTasks.UI.LockUI:setVisible(true)
	ProgressiveTasks.UI.ConfirmMessageBase:setVisible(true)
	ProgressiveTasks.UI.ConfirmMessageBase:setText(title)
	ProgressiveTasks.UI.ConfirmMessageBase.Text:setText(message)
	ProgressiveTasks.UI.ConfirmMessageBase:setHeight(
		ProgressiveTasks.UI.ConfirmMessageBase.Text:getTextSize().height + 100
	)

	ProgressiveTasks.UI.ConfirmMessageBase.ConfirmButton.onClick = function()
		if onConfirm then
			onConfirm()
		end

		ProgressiveTasks.UI.ConfirmMessageBase:setVisible(false)
		ProgressiveTasks.UI.LockUI:setVisible(false)
	end
end

function ProgressiveTasks.setupOkayButton()
	ProgressiveTasks.UI.MessageBase.ConfirmButton.onClick = function()
		ProgressiveTasks.UI.MessageBase:setVisible(false)
		ProgressiveTasks.UI.LockUI:setVisible(false)
	end
	ProgressiveTasks.UI.RankRewardsWindow.ConfirmButton.onClick = function()
		ProgressiveTasks.UI.RankRewardsWindow:setVisible(false)
		ProgressiveTasks.UI.LockUI:setVisible(false)
	end
end

function ProgressiveTasks.setupNoButton()
	ProgressiveTasks.UI.ConfirmMessageBase.CancelButton.onClick = function()
		ProgressiveTasks.UI.ConfirmMessageBase:setVisible(false)
		ProgressiveTasks.UI.LockUI:setVisible(false)
	end
end


------ Data Processing & Display

function ProgressiveTasks.onFilteringOptionChange(option)
	ProgressiveTasks.currentFilterOption = option
	ProgressiveTasks.buildTaskList()
end

function ProgressiveTasks.onSortingOptionChange(option)
	ProgressiveTasks.currentSortingOption = option
	ProgressiveTasks.buildTaskList()
end

function ProgressiveTasks.applyTaskFilter(taskId, taskConfig, taskEntry)
	local filterOption = ProgressiveTasks.currentFilterOption or "Show All"

	local isActive = ProgressiveTasks.isTaskActive(taskId)

	local cdRemaining =
		ProgressiveTasks.playersTasksCooldowns and ProgressiveTasks.playersTasksCooldowns[tostring(taskId)]
	local isOnCooldown = (cdRemaining and cdRemaining > 0)

	local isRepeatable = (taskConfig.repeatable == true)

	local visible = true

	if filterOption == "Show All" then
		visible = true
	elseif filterOption == "Active Tasks" then
		visible = isActive
	elseif filterOption == "Ready (Repeatable & No CD)" then
		visible = (isRepeatable and (not isOnCooldown))
	elseif filterOption == "On Cooldown" then
		visible = isOnCooldown
	end

	if not visible then
		taskEntry:setVisible(false)
	end
end

function ProgressiveTasks.buildTrackerList()
	local trackerPanel = ProgressiveTasks.trackerWindow.contentsPanel.trackedTasksPanel
	if not trackerPanel then
		return
	end
	trackerPanel:destroyChildren()
	if not ProgressiveTasks.playersActiveTasks then
		return
	end

	for _, taskId in ipairs(ProgressiveTasks.playersActiveTasks) do
		local taskConfig = ProgressiveTasks.tasksConfig[taskId]
		if taskConfig then
			local trackerEntry = g_ui.createWidget("ProgressiveTaskTrackerEntry", trackerPanel)
			trackerEntry:setId("trackerTask_" .. taskId)
			trackerEntry.taskName:setText(taskConfig.name)

			ProgressiveTasks.populateKillsRequirements(trackerEntry, taskId, taskConfig)
			ProgressiveTasks.populateItemsRequirements(trackerEntry, taskConfig)
			ProgressiveTasks.setupToggleButtons(trackerEntry)
		end
	end
end

function ProgressiveTasks.addTrackerTask(taskId)
	local taskConfig = ProgressiveTasks.tasksConfig[taskId]
	if not taskConfig then
		return
	end

	local trackerPanel = ProgressiveTasks.trackerWindow.contentsPanel.trackedTasksPanel
	if not trackerPanel then
		return
	end

	local existingEntry = trackerPanel:getChildById("trackerTask_" .. taskId)
	if existingEntry then
		return
	end

	local trackerEntry = g_ui.createWidget("ProgressiveTaskTrackerEntry", trackerPanel)
	trackerEntry:setId("trackerTask_" .. taskId)

	trackerEntry.taskName:setText(taskConfig.name)
	ProgressiveTasks.populateKillsRequirements(trackerEntry, taskId, taskConfig)
	ProgressiveTasks.populateItemsRequirements(trackerEntry, taskConfig)
	ProgressiveTasks.setupToggleButtons(trackerEntry)
end

function ProgressiveTasks.removeTrackerTask(taskId)
	local trackerPanel = ProgressiveTasks.trackerWindow.contentsPanel.trackedTasksPanel
	if not trackerPanel then
		return
	end

	local existingEntry = trackerPanel:getChildById("trackerTask_" .. taskId)
	if existingEntry then
		existingEntry:destroy()
	end
end

function ProgressiveTasks.populateKillsRequirements(trackerEntry, taskId, taskConfig)
	local killsPanel = trackerEntry.killsRequirmentsPanel
	for subTaskIndex, subTask in ipairs(taskConfig.task) do
		if subTask.type == "kills" then
			local required = subTask.amount

			local killsDone = 0
			if ProgressiveTasks.killsProgress and ProgressiveTasks.killsProgress[tostring(taskId)] then
				killsDone = ProgressiveTasks.killsProgress[tostring(taskId)][tostring(subTaskIndex)] or 0
			end

			local percent = math.floor((killsDone / required) * 100)
			percent = math.max(0, math.min(100, percent))

			if #subTask.monsters > 1 then
				local multiKillEntry = g_ui.createWidget("ProgressiveTaskTrackerKillsEntry", killsPanel)
				multiKillEntry:setId("trackerTask_" .. taskId .. "_kills_" .. subTaskIndex)
				local creaturePanel = multiKillEntry.creaturesPanel

				for _, monsterName in ipairs(subTask.monsters) do
					local monsterOutfitData = ProgressiveTasks.cacheMonstersOutfits[monsterName]
					if monsterOutfitData then
						local creatureWidget = g_ui.createWidget("ProgressiveTaskTrackerCreature", creaturePanel)
						ProgressiveTasks.setOutfit(creatureWidget, monsterOutfitData)
						creatureWidget:setTooltip(monsterName)
					end
				end
				creaturePanel:setWidth(creaturePanel:getChildCount() * 40)
				multiKillEntry:setWidth(creaturePanel:getChildCount() * 40)

				multiKillEntry.progressBar:setPercent(percent)
				multiKillEntry.percentProgressLabel:setText(percent .. "%")
				multiKillEntry.rawProgressLabel:setText(string.format("%d/%d", killsDone, required))
			else
				local singleKillEntry = g_ui.createWidget("ProgressiveTaskTrackerKillsEntry", killsPanel)
				singleKillEntry:setId("trackerTask_" .. taskId .. "_kills_" .. subTaskIndex)
				local monsterName = subTask.monsters[1]
				local monsterOutfitData = ProgressiveTasks.cacheMonstersOutfits[monsterName]
				if monsterOutfitData then
					local creatureWidget =
						g_ui.createWidget("ProgressiveTaskTrackerCreature", singleKillEntry.creaturesPanel)
					ProgressiveTasks.setOutfit(creatureWidget, monsterOutfitData)
					creatureWidget:setTooltip(monsterName)
				end

				singleKillEntry.progressBar:setPercent(percent)
				singleKillEntry.percentProgressLabel:setText(percent .. "%")
				singleKillEntry.rawProgressLabel:setText(string.format("%d/%d", killsDone, required))
			end
		end
	end
end

function ProgressiveTasks.updateTrackerKillProgress(taskId, subTaskIndex, newCount)
	local trackerPanel = ProgressiveTasks.trackerWindow.contentsPanel.trackedTasksPanel
	if not trackerPanel then
		return
	end

	local trackerEntry = trackerPanel:getChildById("trackerTask_" .. taskId)
	if not trackerEntry then
		return
	end

	local killsPanel = trackerEntry.killsRequirmentsPanel
	if not killsPanel then
		return
	end

	local subtaskWidget = killsPanel:getChildById("trackerTask_" .. taskId .. "_kills_" .. subTaskIndex)
	if not subtaskWidget then
		return
	end

	local taskConfig = ProgressiveTasks.tasksConfig[taskId]
	if not taskConfig or not taskConfig.task[subTaskIndex] then
		return
	end

	local required = taskConfig.task[subTaskIndex].amount or 1
	local percent = math.floor((newCount / required) * 100)
	percent = math.max(0, math.min(100, percent))

	subtaskWidget.progressBar:setPercent(percent)
	subtaskWidget.percentProgressLabel:setText(percent .. "%")
	subtaskWidget.rawProgressLabel:setText(string.format("%d/%d", newCount, required))
end

function ProgressiveTasks.populateItemsRequirements(trackerEntry, taskConfig)
	local itemsContainer = g_ui.createWidget("ProgressiveTaskTrackerItemsEntry", trackerEntry.itemsRequirmentsPanel)
	local itemsPanel = itemsContainer.itemsPanel

	for _, subTask in ipairs(taskConfig.task) do
		if subTask.type == "items" then
			local items = subTask.itemsIds
			if #items > 1 then
				local multiItemEntry = g_ui.createWidget("MultipleItemTrackerEntry", itemsPanel)
				local itemPanel = multiItemEntry.item
				for _, itemStrId in ipairs(items) do
					local itemInfo = ProgressiveTasks.getCachedItemInfo(itemStrId)
					if itemInfo and itemInfo.itemId then
						local itemWidget = g_ui.createWidget("ProgressiveTaskTrackerItem", itemPanel)
						itemWidget:setItemId(itemInfo.itemId)
						itemWidget:setTooltip(itemInfo.name)
						itemWidget:addAnchor(AnchorTop, "parent", AnchorTop)
						if itemPanel:getChildCount() == 1 then
							itemWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
						else
							itemWidget:addAnchor(AnchorLeft, "prev", AnchorRight)
						end
					end
				end
				itemPanel:setWidth(itemPanel:getChildCount() * 32)
				multiItemEntry:setWidth(itemPanel:getChildCount() * 32)
				multiItemEntry.info:setText(tostring(subTask.amount) .. "x")
			else
				local singleItemEntry = g_ui.createWidget("SingleItemTrackerEntry", itemsPanel)
				local itemStrId = items[1]
				local itemInfo = ProgressiveTasks.getCachedItemInfo(itemStrId)
				if itemInfo and itemInfo.itemId then
					singleItemEntry.item:setItemId(itemInfo.itemId)
					singleItemEntry.info:setText(tostring(subTask.amount) .. "x")
					singleItemEntry.item:setTooltip(itemInfo.name)
					singleItemEntry:setTooltip(itemInfo.name)
				end
			end
		end
	end
end

function ProgressiveTasks.setupToggleButtons(trackerEntry)
	trackerEntry.toggleDisplayPanel.toggleKills.onClick = function()
		if trackerEntry.killsRequirmentsPanel:isVisible() then
			trackerEntry.killsRequirmentsPanel:setVisible(false)
		else
			trackerEntry.killsRequirmentsPanel:setVisible(true)
		end
	end

	trackerEntry.toggleDisplayPanel.toggleItems.onClick = function()
		if trackerEntry.itemsRequirmentsPanel:isVisible() then
			trackerEntry.itemsRequirmentsPanel:setVisible(false)
		else
			trackerEntry.itemsRequirmentsPanel:setVisible(true)
		end
	end
end

function ProgressiveTasks.buildTaskList()
	local tasksPanel = ProgressiveTasks.UI.tasksPanel
	tasksPanel:destroyChildren()

	local playerTaskProgressLevel = math.max(1, ProgressiveTasks.progressLevel)
	ProgressiveTasks.UI.topInfoPanel.progressLevelPanel:setText("Progress Level: " .. playerTaskProgressLevel)

	local option = ProgressiveTasks.currentSortingOption or "Highest level first"

	local tasksArray = {}
	for taskId, taskConfig in ipairs(ProgressiveTasks.tasksConfig) do
		table.insert(tasksArray, {id = taskId, config = taskConfig})
	end

	if option == "Highest level first" then
		table.sort(
			tasksArray,
			function(a, b)
				return a.id > b.id
			end
		)
	else
		table.sort(
			tasksArray,
			function(a, b)
				return a.id < b.id
			end
		)
	end

	for _, data in ipairs(tasksArray) do
		local taskId = data.id
		local taskConfig = data.config

		if taskId > playerTaskProgressLevel then
			-- skip
		else
			local taskEntry = g_ui.createWidget("TaskEntry", tasksPanel)
			taskEntry:setId(taskId)

			local isActive = ProgressiveTasks.isTaskActive(taskId)
			ProgressiveTasks.setTaskButtonState(taskEntry, isActive)

			local remainingCD =
				ProgressiveTasks.playersTasksCooldowns and ProgressiveTasks.playersTasksCooldowns[tostring(taskId)]
			if remainingCD then
				taskEntry.taskCD:parseColoredText("Status: ", "#edddc0")
				ProgressiveTasks.startCooldownTracking()
				taskEntry.taskButton:setEnabled(false)
			else
				taskEntry.taskCD:parseColoredText("Status: [color=#009688]Available[/color]", "#edddc0")
			end

			if (not taskConfig.repeatable) and (playerTaskProgressLevel > taskId) then
				taskEntry.taskButton:setEnabled(false)
				taskEntry.taskButton:setText("Task Completed")
				taskEntry.taskButton:setMarginLeft(70)
			end

			taskEntry.taskButton.onClick = function()
				local isActiveNow = ProgressiveTasks.isTaskActive(taskId)
				if isActiveNow then
					ProgressiveTasks.setupConfirmMessage(
						"Confirm Cancelling",
						"Are you sure you want to cancel this task?\n\nAll kills progress will be lost when a task is cancelled",
						function()
							ProgressiveTasks.sendOpcode({topic = "cancel-task-request", taskId = taskId})
						end
					)
				else
					if
						ProgressiveTasks.playersActiveTasks and
							#ProgressiveTasks.playersActiveTasks >= ProgressiveTasks.maxActiveTasks
					 then
						ProgressiveTasks.setupMessage(
							"Error",
							"You can have a maximum of " .. ProgressiveTasks.maxActiveTasks .. " tasks active"
						)
						return
					end
					ProgressiveTasks.sendOpcode({topic = "start-task-request", taskId = taskId})
				end
			end

			taskEntry.submitButton.onClick = function()
				ProgressiveTasks.sendOpcode({topic = "submit-task-request", taskId = taskId})
			end

			taskEntry.taskLevel:parseColoredText("Task - " .. taskId, "#edddc0")
			taskEntry.taskName:parseColoredText("[color=#ff7b00]" .. taskConfig.name .. "[/color]", "#edddc0")
			taskEntry.taskLevelReq:parseColoredText(
				"Level Requirement: [color=#ebcf34]" .. taskConfig.levelReq .. "[/color]",
				"#edddc0"
			)

			if taskConfig.repeatable then
				taskEntry.taskRepeatable:parseColoredText(
					"Cooldown: [color=#4bbf6b]" .. taskConfig.repeatableCD .. " minutes[/color]",
					"#edddc0"
				)
			else
				taskEntry.taskRepeatable:parseColoredText("[color=#a964cc]Non-Repeatable[/color]", "#edddc0")
				taskEntry.taskCD:setVisible(false)
			end

			if taskConfig.storagesReqs then
				local tooltipText = {}
				for _, storage in ipairs(taskConfig.storagesReqs) do
					table.insert(tooltipText, storage.name)
				end
				taskEntry.otherReqsTooltip:setTooltip(table.concat(tooltipText, "\n"))
			else
				taskEntry.otherReqsTooltip:setVisible(false)
				taskEntry.taskOtherReqs:setVisible(false)
				taskEntry.taskOtherReqs:setHeight(0)
				taskEntry.otherReqsTooltip:setHeight(0)
				taskEntry.taskLevel:setMarginTop(40)
			end

			for _, subTask in ipairs(taskConfig.task) do
				if subTask.type == "kills" then
					local monsters = subTask.monsters
					if #monsters > 1 then
						local multiCreatureEntry = g_ui.createWidget("MultipleCreatureEntry", taskEntry.taskPanel)
						local creaturePanel = multiCreatureEntry.creature

						for i, monsterName in ipairs(monsters) do
							local monsterOutfitData = ProgressiveTasks.cacheMonstersOutfits[monsterName]
							if monsterOutfitData then
								local monsterWidget = g_ui.createWidget("ProgressiveTaskCreature", creaturePanel)
								ProgressiveTasks.setOutfit(monsterWidget, monsterOutfitData)
								monsterWidget:setTooltip(monsterName)

								monsterWidget:addAnchor(AnchorTop, "parent", AnchorTop)
								if i == 1 then
									monsterWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
								else
									monsterWidget:addAnchor(AnchorLeft, "prev", AnchorRight)
								end
							end
						end
						creaturePanel:setWidth(creaturePanel:getChildCount() * 50)
						multiCreatureEntry:setWidth(creaturePanel:getChildCount() * 50 + 10)
						multiCreatureEntry.info:setText(tostring(subTask.amount))
					else
						local singleCreatureEntry = g_ui.createWidget("SingleCreatureEntry", taskEntry.taskPanel)
						local monsterName = monsters[1]
						local monsterOutfitData = ProgressiveTasks.cacheMonstersOutfits[monsterName]
						if monsterOutfitData then
							ProgressiveTasks.setOutfit(singleCreatureEntry.creature, monsterOutfitData)
							singleCreatureEntry.creature:setTooltip(monsterName)
							singleCreatureEntry.info:setTooltip(monsterName)
							singleCreatureEntry:setTooltip(monsterName)
						end
						singleCreatureEntry.info:setText(tostring(subTask.amount))
					end
				elseif subTask.type == "items" then
					local items = subTask.itemsIds
					if #items > 1 then
						local multiItemEntry = g_ui.createWidget("MultipleItemEntry", taskEntry.taskPanel)
						local itemPanel = multiItemEntry.item

						for i, itemStrId in ipairs(items) do
							local itemInfo = ProgressiveTasks.getCachedItemInfo(itemStrId)
							if itemInfo and itemInfo.itemId then
								local itemWidget = g_ui.createWidget("ProgressiveTaskItem", itemPanel)
								itemWidget:setItemId(itemInfo.itemId)
								itemWidget:setItemCount(subTask.amount)
								itemWidget:setShowCount(false)
								itemWidget:setTooltip(itemInfo.name)

								itemWidget:addAnchor(AnchorTop, "parent", AnchorTop)
								if i == 1 then
									itemWidget:addAnchor(AnchorLeft, "parent", AnchorLeft)
								else
									itemWidget:addAnchor(AnchorLeft, "prev", AnchorRight)
								end
							end
						end
						itemPanel:setWidth(itemPanel:getChildCount() * 50)
						multiItemEntry:setWidth(itemPanel:getChildCount() * 50 + 10)
						multiItemEntry.info:setText(tostring(subTask.amount) .. "x")
					else
						local singleItemEntry = g_ui.createWidget("SingleItemEntry", taskEntry.taskPanel)
						local itemStrId = items[1]
						local itemInfo = ProgressiveTasks.getCachedItemInfo(itemStrId)
						if itemInfo and itemInfo.itemId then
							singleItemEntry.item:setItemId(itemInfo.itemId)
							singleItemEntry.item:setItemCount(subTask.amount)
							singleItemEntry.item:setShowCount(false)
							singleItemEntry.item:setTooltip(itemInfo.name)
							singleItemEntry.info:setTooltip(itemInfo.name)
							singleItemEntry:setTooltip(itemInfo.name)
						end
						singleItemEntry.info:setText(tostring(subTask.amount) .. "x")
					end
				end
			end

			-- Rewards
			for _, reward in ipairs(taskConfig.rewards) do
				if reward.type == "items" then
					for _, itemData in ipairs(reward.items) do
						local singleItemEntry = g_ui.createWidget("SingleItemEntry", taskEntry.rewardsPanel)
						local itemStrId = tostring(itemData.id)
						local itemInfo = ProgressiveTasks.getCachedItemInfo(itemStrId)

						if itemInfo and itemInfo.itemId then
							singleItemEntry.item:setItemId(itemInfo.itemId)

							local displayCount
							if itemData.minAmount and itemData.maxAmount then
								displayCount = itemData.minAmount .. " - " .. itemData.maxAmount
							else
								displayCount = itemData.amount or 1
							end

							singleItemEntry.item:setItemCount(itemData.amount or itemData.maxAmount or 1)
							singleItemEntry.item:setShowCount(false)
							singleItemEntry.item:setTooltip(itemInfo.name)
							singleItemEntry.info:setTooltip(itemInfo.name)
							singleItemEntry:setTooltip(itemInfo.name)

							if itemData.chance then
								local chanceText = string.format("%.1f%%", itemData.chance / 100)
								singleItemEntry.item:setWidth(35)
								singleItemEntry.item:setHeight(35)
								singleItemEntry.info:setText(string.format("%sx\n%s", displayCount, chanceText))
							else
								singleItemEntry.info:setText(string.format("%sx", displayCount))
							end
						end
					end
				elseif reward.type == "storages" then
					for _, storageData in ipairs(reward.storages) do
						local rewardEntry = g_ui.createWidget("RewardEntry", taskEntry.rewardsPanel)
						local storageIcon =
							ProgressiveTasks.rewardIcons[storageData.name] or ProgressiveTasks.rewardIcons["Default"]
						rewardEntry.reward:setImageSource(storageIcon)
						rewardEntry:setTooltip(storageData.name)
						rewardEntry.reward:setTooltip(storageData.name)
						rewardEntry.info:setTooltip(storageData.name)

						local displayCount
						if storageData.minAmount and storageData.maxAmount then
							displayCount = storageData.minAmount .. " - " .. storageData.maxAmount
						else
							displayCount = storageData.amount or 1
						end

						if storageData.chance then
							local chanceText = string.format("%.1f%%", storageData.chance / 100)
							rewardEntry.reward:setWidth(35)
							rewardEntry.reward:setHeight(35)
							rewardEntry.info:setText(string.format("%sx\n%s", displayCount, chanceText))
						else
							rewardEntry.info:setText(string.format("%sx", displayCount))
						end
					end
				else
					-- (gold, exp, taskPrestigeExp) always full-chanced
					local rewardEntry = g_ui.createWidget("RewardEntry", taskEntry.rewardsPanel)
					local iconPath =
						ProgressiveTasks.rewardIcons[reward.type] or ProgressiveTasks.rewardIcons["Default"]
					rewardEntry.reward:setImageSource(iconPath)
					rewardEntry.info:setText(tostring(reward.amount))

					rewardEntry:setTooltip(reward.type)
					rewardEntry.reward:setTooltip(reward.type)
					rewardEntry.info:setTooltip(reward.type)
				end
			end
			ProgressiveTasks.applyTaskFilter(taskId, taskConfig, taskEntry)
		end -- end if (taskId <= progressLevel)
	end -- end for tasksArray
end

function ProgressiveTasks.setTaskButtonState(taskEntry, isActive)
	if isActive then
		taskEntry.taskButton:setText("Cancel Task")
		taskEntry.taskButton:setBorderWidthBottom(1)
		taskEntry.taskButton:setBorderColorBottom("red")
		taskEntry.submitButton:setVisible(true)
		taskEntry.taskButton:setMarginLeft(40)
	else
		taskEntry.taskButton:setText("Start Task")
		taskEntry.taskButton:setBorderWidthBottom(1)
		taskEntry.taskButton:setBorderColorBottom("green")
		taskEntry.submitButton:setVisible(false)
		taskEntry.taskButton:setMarginLeft(80)
	end
end

function ProgressiveTasks.updatePrestigeRankDisplay()
	local totalExp = ProgressiveTasks.taskPrestigeExp or 0
	if not ProgressiveTasks.taskPrestigeRankTable or #ProgressiveTasks.taskPrestigeRankTable == 0 then
		return
	end

	local currentRankIndex = 0
	for i = #ProgressiveTasks.taskPrestigeRankTable, 0, -1 do
		local rankData = ProgressiveTasks.taskPrestigeRankTable[i]
		if totalExp >= rankData.exp then
			currentRankIndex = i
			break
		end
	end

	local currentRankData = ProgressiveTasks.taskPrestigeRankTable[currentRankIndex]
	local currentRankName = currentRankData and currentRankData.name or "-"
	local currentRankExp = currentRankData and currentRankData.exp or 0

	local nextRankIndex = currentRankIndex + 1
	local nextRankData = ProgressiveTasks.taskPrestigeRankTable[nextRankIndex]
	local nextRankExp = (nextRankData and nextRankData.exp) or currentRankExp

	local partialExp = totalExp - currentRankExp
	local neededExp = nextRankExp - currentRankExp

	if neededExp < 1 then
		partialExp = neededExp
	end

	local percent = 100
	if neededExp > 0 then
		percent = math.floor((partialExp / neededExp) * 100)
	end
	percent = math.max(0, math.min(100, percent))

	if not ProgressiveTasks.UI or not ProgressiveTasks.UI.topInfoPanel then
		return
	end

	ProgressiveTasks.UI.topInfoPanel.prestigeRankPanel:setText("Prestige Rank: " .. currentRankName)

	local bar = ProgressiveTasks.UI.topInfoPanel.prestigeProgressBar.taskPrestigeUIProgressBar
	bar:setPercent(percent)
	bar:setText(percent .. "%")

	local currentExpPanel = ProgressiveTasks.UI.topInfoPanel.currentPrestigeExpPanel
	if neededExp <= 0 then
		currentExpPanel:setText(
			string.format("Current Prestige Experience: %d / %d (Max Rank)", partialExp, partialExp)
		)
	else
		currentExpPanel:setText(string.format("Current Prestige Experience: %d / %d", partialExp, neededExp))
	end

	ProgressiveTasks.UI.topInfoPanel.totalPrestigeExpPanel:setText("Total Prestige Experience: " .. totalExp)

	local rankIcon = ProgressiveTasks.UI.topInfoPanel.rankIcon
	if currentRankIndex == 0 then
		rankIcon:setVisible(false)
	else
		rankIcon:setVisible(true)
		local nameForFile = string.gsub(currentRankName, " ", "_") -- e.g. "Iron 1" => "Iron_1"
		local imagePath = "images/ui/ranks/" .. nameForFile .. "_Rank.png"
		rankIcon:setImageSource(imagePath)
	end
end


------ Task Actions & Communication

function ProgressiveTasks.onExtendedOpcode(protocol, opcode, data)
	local topic = data.topic

	if topic == "base-data-response" then
		ProgressiveTasks.cacheMonstersOutfits = data.cachedMonstersOutfits
		ProgressiveTasks.cachedItemsInfo = data.cachedItemsInfo
		ProgressiveTasks.progressLevel = data.progressLevel
		ProgressiveTasks.playersActiveTasks = data.activeTasks
		ProgressiveTasks.playersTasksCooldowns = data.tasksCooldowns
		ProgressiveTasks.taskPrestigeExp = data.taskPrestigeExp
		ProgressiveTasks.killsProgress = data.killsProgress
		ProgressiveTasks.updatePrestigeRankDisplay()
		ProgressiveTasks.buildTaskList()
		ProgressiveTasks.buildTrackerList()
		ProgressiveTasks.populateRankRewards()
	elseif topic == "submit-task-response" then
		local taskId = data.taskId
		ProgressiveTasks.progressLevel = data.progressLevel
		ProgressiveTasks.playersActiveTasks = data.activeTasks
		ProgressiveTasks.playersTasksCooldowns = data.tasksCooldowns
		ProgressiveTasks.taskPrestigeExp = data.taskPrestigeExp
		ProgressiveTasks.updatePrestigeRankDisplay()
		ProgressiveTasks.buildTaskList()
		ProgressiveTasks.removeTrackerTask(taskId)
		ProgressiveTasks.onFilteringOptionChange(ProgressiveTasks.UI.filteringComboBox:getText())
		if ProgressiveTasks.killsProgress[tostring(taskId)] then
			ProgressiveTasks.killsProgress[tostring(taskId)] = {}
		end
		ProgressiveTasks.setupMessage("Success", "Task submitted successfully.")
	elseif topic == "update-kill-progress" then
		local taskId = data.taskId
		local subTaskIndex = data.subTaskIndex
		local newCount = data.killCount
		if not ProgressiveTasks.killsProgress[tostring(taskId)] then
			ProgressiveTasks.killsProgress[tostring(taskId)] = {}
		end
		ProgressiveTasks.killsProgress[tostring(taskId)][tostring(subTaskIndex)] = newCount
		ProgressiveTasks.updateTrackerKillProgress(taskId, subTaskIndex, newCount)
	elseif topic == "start-task-response" then
		local taskId = data.taskId
		ProgressiveTasks.playersActiveTasks = ProgressiveTasks.playersActiveTasks or {}
		if not ProgressiveTasks.isTaskActive(taskId) then
			table.insert(ProgressiveTasks.playersActiveTasks, taskId)
		end
		if ProgressiveTasks.killsProgress[tostring(taskId)] then
			ProgressiveTasks.killsProgress[tostring(taskId)] = {}
		end
		ProgressiveTasks.addTrackerTask(taskId)
		ProgressiveTasks.onFilteringOptionChange(ProgressiveTasks.UI.filteringComboBox:getText())
		ProgressiveTasks.setTaskButtonState(ProgressiveTasks.UI.tasksPanel:getChildById(taskId), true)
	elseif topic == "cancel-task-response" then
		local taskId = data.taskId
		if ProgressiveTasks.playersActiveTasks then
			for i, activeId in ipairs(ProgressiveTasks.playersActiveTasks) do
				if activeId == taskId then
					table.remove(ProgressiveTasks.playersActiveTasks, i)
					break
				end
			end
		end
		if ProgressiveTasks.killsProgress[tostring(taskId)] then
			ProgressiveTasks.killsProgress[tostring(taskId)] = {}
		end
		ProgressiveTasks.removeTrackerTask(taskId)
		ProgressiveTasks.onFilteringOptionChange(ProgressiveTasks.UI.filteringComboBox:getText())
		ProgressiveTasks.setTaskButtonState(ProgressiveTasks.UI.tasksPanel:getChildById(taskId), false)
	elseif topic == "message" then
		ProgressiveTasks.setupMessage(data.title, data.message)
	elseif topic == "show-window" then
		ProgressiveTasks.show()
	elseif topic == "hide-window" then
		ProgressiveTasks.hide()
	end
end

function ProgressiveTasks.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(ProgressiveTasks.Opcode, data)
	end
end

function ProgressiveTasks.isTaskActive(taskId)
	if not ProgressiveTasks.playersActiveTasks then
		return false
	end
	for _, activeTaskId in ipairs(ProgressiveTasks.playersActiveTasks) do
		if activeTaskId == taskId then
			return true
		end
	end
	return false
end

function ProgressiveTasks.setOutfit(widget, monsterOutfitData)
	local outfitCreature = {
		["type"] = monsterOutfitData.type,
		["auxType"] = monsterOutfitData.typeex,
		["addons"] = monsterOutfitData.addons,
		["mount"] = monsterOutfitData.mount,
		["wings"] = monsterOutfitData.wings,
		["aura"] = monsterOutfitData.aura,
		["feet"] = monsterOutfitData.feet,
		["legs"] = monsterOutfitData.legs,
		["body"] = monsterOutfitData.body,
		["head"] = monsterOutfitData.head,
	}
	widget:setOutfit(outfitCreature)
end


------ Task Cooldown Tracking

function ProgressiveTasks.formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function ProgressiveTasks.updateCooldowns()
	if not next(ProgressiveTasks.playersTasksCooldowns) then
		removeEvent(ProgressiveTasks.cooldownEvent)
		ProgressiveTasks.cooldownEvent = nil
		return
	end

	for taskId, remaining in pairs(ProgressiveTasks.playersTasksCooldowns) do
		local taskEntry = ProgressiveTasks.UI.tasksPanel:getChildById(taskId)

		if remaining > 0 then
			if taskEntry and taskEntry.taskCD then
				taskEntry.taskCD:parseColoredText(
					string.format("Status: [color=#ff4b4b]%s[/color]", ProgressiveTasks.formatTime(remaining)),
					"#edddc0"
				)
				taskEntry.taskButton:setEnabled(false)
			end
			ProgressiveTasks.playersTasksCooldowns[taskId] = remaining - 1
		else
			if taskEntry and taskEntry.taskCD then
				taskEntry.taskCD:parseColoredText("Status: [color=#009688]Available[/color]", "#edddc0")
			end
			ProgressiveTasks.onFilteringOptionChange(ProgressiveTasks.UI.filteringComboBox:getText())
			if taskEntry and taskEntry.taskButton then
				taskEntry.taskButton:setEnabled(true)
			end
			ProgressiveTasks.playersTasksCooldowns[taskId] = nil
		end
	end

	if next(ProgressiveTasks.playersTasksCooldowns) then
		ProgressiveTasks.cooldownEvent = scheduleEvent(ProgressiveTasks.updateCooldowns, 1000)
	else
		ProgressiveTasks.cooldownEvent = nil
	end
end

function ProgressiveTasks.startCooldownTracking()
	if not ProgressiveTasks.cooldownEvent then
		ProgressiveTasks.cooldownEvent = scheduleEvent(ProgressiveTasks.updateCooldowns, 1000)
	end
end
