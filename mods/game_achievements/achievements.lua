Achievements = Achievements or {}

Achievements.opcode = 72

local AchievementsData = ACHIEVEMENTS or {}
local mainWindow
local windowButton
local selectedFilter = "all"
local selectedGrade = "all"
local selectedSort = 5
local searchText = ""
local completedIds = {}
local progressById = {}
local completedCount = 0
local totalCount = 0
local renderedEntries = {}
local renderedEntryCount = 0
local isAppendingEntries = false

local INITIAL_RENDER_COUNT = 30
local APPEND_RENDER_COUNT = 15
local APPEND_SCROLL_THRESHOLD = 200

local function orderedAchievementIds()
	local ids = {}
	for id in pairs(AchievementsData or {}) do
		if type(id) == "number" then
			ids[#ids + 1] = id
		end
	end
	table.sort(ids)
	return ids
end

local allIds = orderedAchievementIds()

local function isCompleted(id)
	return completedIds[tonumber(id)] == true
end

local function formatNumber(value)
	local number = math.floor(tonumber(value) or 0)
	local sign = number < 0 and "-" or ""
	local text = tostring(math.abs(number))
	local reversed = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	reversed = reversed:gsub("^,", "")
	return sign .. reversed
end

local function formatRewards(rewards)
	if type(rewards) == "string" then
		return rewards
	end

	if type(rewards) ~= "table" then
		return ""
	end

	local values = {}
	if rewards.experience then
		values[#values + 1] = formatNumber(rewards.experience) .. " experience"
	end
	if rewards.gold then
		values[#values + 1] = formatNumber(rewards.gold) .. " gold"
	end
	for _, item in ipairs(rewards.items or {}) do
		values[#values + 1] = string.format("%sx %s", formatNumber(item.count or item.amount or item[2] or 1), item.name or ("item " .. tostring(item.id or item.itemId or item[1])))
	end
	for _, storage in ipairs(rewards.storages or rewards.storage or {}) do
		values[#values + 1] = string.format("%+d %s", tonumber(storage.value or storage.amount or storage[2]) or 0, storage.name or "storage reward")
	end
	for _, buff in ipairs(rewards.buffs or {}) do
		local parts = {}
		for _, param in ipairs(buff.params or {}) do
			parts[#parts + 1] = param.label or tostring(param.param)
		end
		if #parts > 0 then
			values[#values + 1] = string.format("%s (%s)", buff.name or "Buff", table.concat(parts, ", "))
		else
			values[#values + 1] = buff.name or "Buff"
		end
	end

	return table.concat(values, ", ")
end

local function formatRewardDetails(rewards)
	if type(rewards) == "string" then
		return rewards
	end

	if type(rewards) ~= "table" then
		return ""
	end

	local values = {}
	for _, item in ipairs(rewards.items or {}) do
		values[#values + 1] = string.format("%sx %s", formatNumber(item.count or item.amount or item[2] or 1), item.name or ("item " .. tostring(item.id or item.itemId or item[1])))
	end
	for _, storage in ipairs(rewards.storages or rewards.storage or {}) do
		values[#values + 1] = string.format("%+d %s", tonumber(storage.value or storage.amount or storage[2]) or 0, storage.name or "storage reward")
	end
	for _, buff in ipairs(rewards.buffs or {}) do
		local parts = {}
		for _, param in ipairs(buff.params or {}) do
			parts[#parts + 1] = param.label or tostring(param.param)
		end
		if #parts > 0 then
			values[#values + 1] = string.format("%s (%s)", buff.name or "Buff", table.concat(parts, ", "))
		else
			values[#values + 1] = buff.name or "Buff"
		end
	end

	return table.concat(values, ", ")
end

local function getRewardText(id, data)
	local rewards = nil
	if not rewards then
		rewards = AchievementsRewardConfig.byAchievementId and AchievementsRewardConfig.byAchievementId[id]
	end
	if not rewards then
		local grade = math.min(math.max(tonumber(data.grade) or 1, 1), 4)
		rewards = AchievementsRewardConfig.defaultRewardsByGrade[grade]
	end

	if rewards and rewards.extraRewardsDesc then
		return rewards.extraRewardsDesc
	end

	return formatRewards(rewards)
end

local function getRewards(id, data)
	local rewards = AchievementsRewardConfig.byAchievementId and AchievementsRewardConfig.byAchievementId[id]
	if rewards then
		return rewards
	end

	local grade = math.min(math.max(tonumber(data.grade) or 1, 1), 4)
	return AchievementsRewardConfig.defaultRewardsByGrade[grade]
end

local function hasBuffRewards(id, data)
	local rewards = getRewards(id, data)
	return type(rewards) == "table" and type(rewards.buffs) == "table" and #rewards.buffs > 0
end

local function hasAnyReward(id, data)
	return formatRewards(getRewards(id, data)) ~= ""
end

local function passesFilter(id, data)
	local completed = isCompleted(id)
	local secret = data.secret == true
	if secret and not completed then
		return false
	end

	if searchText ~= "" and not data.name:lower():find(searchText, 1, true) then
		return false
	end

	local grade = math.min(math.max(tonumber(data.grade) or 1, 1), 4)
	if selectedGrade ~= "all" and grade ~= tonumber(selectedGrade) then
		return false
	end

	if selectedFilter == "locked" then
		return not completed and not secret
	elseif selectedFilter == "accomplished" then
		return completed
	elseif selectedFilter == "secret" then
		return secret and completed
	elseif selectedFilter == "inprogress" then
		local progressTarget = tonumber(data.progressPoints) or 0
		local progress = tonumber(progressById[id]) or 0
		return progressTarget > 0 and progress > 0 and not completed
	elseif selectedFilter == "rewards" then
		return hasAnyReward(id, data)
	elseif selectedFilter == "buffs" then
		return hasBuffRewards(id, data)
	end
	return true
end

local function sortEntries(entries)
	if selectedSort == 1 then
		table.sort(entries, function(a, b)
			return a.name < b.name
		end)
	elseif selectedSort == 2 then
		table.sort(entries, function(a, b)
			if a.grade == b.grade then
				return a.name < b.name
			end
			return a.grade > b.grade
		end)
	elseif selectedSort == 5 then
		table.sort(entries, function(a, b)
			return a.id < b.id
		end)
	else
		table.sort(entries, function(a, b)
			if selectedSort == 4 then
				local aRatio = a.progressTarget > 0 and (a.progress / a.progressTarget) or -1
				local bRatio = b.progressTarget > 0 and (b.progress / b.progressTarget) or -1
				if aRatio ~= bRatio then
					return aRatio > bRatio
				end
			end
			if a.completed ~= b.completed then
				return a.completed
			end
			return a.name < b.name
		end)
	end
end

local function getEntries()
	local entries = {}
	for _, id in ipairs(allIds) do
		local data = AchievementsData[id]
		if type(data) == "table" and data.name and data.description and passesFilter(id, data) then
			entries[#entries + 1] = {
				id = id,
				name = data.name,
				description = data.description,
				grade = math.min(math.max(tonumber(data.grade) or 1, 1), 4),
				points = tonumber(data.points) or 0,
				secret = data.secret == true,
				completed = isCompleted(id),
				progress = tonumber(progressById[id]) or 0,
				progressTarget = tonumber(data.progressPoints) or 0,
				rewards = getRewardText(id, data),
				rewardTable = getRewards(id, data)
			}
		end
	end
	sortEntries(entries)
	return entries
end

local function child(widget, id)
	return widget and widget:getChildById(id)
end

local function estimateWrappedHeight(text, charsPerLine, lineHeight, minHeight)
	text = tostring(text or "")
	local lines = 0
	for line in (text .. "\n"):gmatch("(.-)\n") do
		lines = lines + math.max(1, math.ceil(#line / charsPerLine))
	end
	return math.max(minHeight, lines * lineHeight)
end

local function measuredTextHeight(widget, text, charsPerLine, lineHeight, minHeight)
	if not widget then
		return estimateWrappedHeight(text, charsPerLine, lineHeight, minHeight)
	end

	local textSize = widget:getTextSize()
	if textSize and textSize.height and textSize.height > 0 then
		return math.max(minHeight, textSize.height)
	end

	return estimateWrappedHeight(text, charsPerLine, lineHeight, minHeight)
end

local function setRewardTooltip(widget, tooltip)
	if not widget then
		return
	end
	widget:setTooltip(tooltip)
	local icon = child(widget, "icon")
	local value = child(widget, "value")
	if icon then
		icon:setTooltip(tooltip)
	end
	if value then
		value:setTooltip(tooltip)
	end
end

local function positionSecretIcon(title, secretIcon, visible)
	if not secretIcon then
		return
	end

	secretIcon:setVisible(visible)
	if not visible or not title then
		return
	end

	secretIcon:setTooltip("Secret achievement")
end

local function tintReward(widget, unlocked)
	if not widget then
		return
	end

	local color = unlocked and "#FFFFFF" or "#777777"
	local labelColor = unlocked and "#AFAFAF" or "#777777"
	local icon = child(widget, "icon")
	local value = child(widget, "value")
	if icon then
		icon:setImageColor(color)
	end
	if value then
		value:setColor(labelColor)
	end
end

local function combineClientParam(bucket, paramName, value)
	value = tonumber(value) or 0
	if paramName == "CONDITION_PARAM_HEALTHTICKS" or paramName == "CONDITION_PARAM_MANATICKS" then
		local current = bucket.params[paramName]
		if not current or current <= 0 or (value > 0 and value < current) then
			bucket.params[paramName] = value
		end
	elseif paramName:find("PERCENT", 1, true) and value > 100 then
		bucket.params[paramName] = (bucket.params[paramName] or 100) + (value - 100)
	else
		bucket.params[paramName] = (bucket.params[paramName] or 0) + value
	end
end

local function addRewardsToBuffBuckets(buckets, rewards)
	for _, buff in ipairs((rewards and rewards.buffs) or {}) do
		local key = buff.conditionType or "CONDITION_ATTRIBUTES"
		local bucket = buckets[key]
		if not bucket then
			bucket = { params = {}, haste = 0 }
			buckets[key] = bucket
		end
		for _, param in ipairs(buff.params or {}) do
			if param.param and param.value ~= nil then
				combineClientParam(bucket, param.param, param.value)
			end
		end
		if buff.haste then
			bucket.haste = bucket.haste + (tonumber(buff.haste) or 0)
		end
	end
end

local function describeCombinedParam(paramName, value)
	if paramName == "CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT" then
		return string.format("+%d%% maximum health", math.max(0, value - 100))
	elseif paramName == "CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT" then
		return string.format("+%d%% maximum mana", math.max(0, value - 100))
	elseif paramName == "CONDITION_PARAM_SKILL_CRITICAL_HIT_CHANCE" then
		return string.format("+%d critical chance", value)
	elseif paramName == "CONDITION_PARAM_SKILL_CRITICAL_HIT_DAMAGE" then
		return string.format("+%d critical damage", value)
	elseif paramName == "CONDITION_PARAM_HEALTHGAIN" then
		return string.format("+%d health regeneration", value)
	elseif paramName == "CONDITION_PARAM_MANAGAIN" then
		return string.format("+%d mana regeneration", value)
	elseif paramName == "CONDITION_PARAM_HEALTHTICKS" then
		return string.format("health regen every %.1fs", value / 1000)
	elseif paramName == "CONDITION_PARAM_MANATICKS" then
		return string.format("mana regen every %.1fs", value / 1000)
	end
	return string.format("%s: %s", paramName, tostring(value))
end

local function getCombinedBuffText()
	local buckets = {}
	local publicCompleted = 0
	local secretCompleted = 0

	for _, id in ipairs(allIds) do
		if isCompleted(id) then
			local data = AchievementsData[id]
			if data and data.secret then
				secretCompleted = secretCompleted + 1
			else
				publicCompleted = publicCompleted + 1
			end
			addRewardsToBuffBuckets(buckets, getRewards(id, data or {}))
		end
	end

	local lines = {
		string.format("Public achievements gathered: %d", publicCompleted),
		string.format("Secret achievements gathered: %d", secretCompleted),
		"",
	}

	local hasBuffs = false
	for conditionType, bucket in pairs(buckets) do
		hasBuffs = true
		lines[#lines + 1] = conditionType:gsub("CONDITION_", ""):lower()
		for paramName, value in pairs(bucket.params) do
			lines[#lines + 1] = "  " .. describeCombinedParam(paramName, value)
		end
		if bucket.haste ~= 0 then
			lines[#lines + 1] = "  +" .. bucket.haste .. " speed"
		end
	end

	if not hasBuffs then
		lines[#lines + 1] = "No achievement buffs gathered yet."
	end

	return table.concat(lines, "\n")
end

function Achievements.showCombinedBuffs()
	displayInfoBox("Achievement Buffs", getCombinedBuffText())
end

local function createAchievementEntry(data)
	local widget = g_ui.createWidget("AchievementEntry", mainWindow.ListBase.List)
	widget:setId(data.id)
	local header = child(widget, "header")
	local gradeBox = child(header, "grade")
	local stars = child(gradeBox, "stars")
	local title = child(header, "title")
	local secretIcon = child(header, "secretIcon")
	local progressBox = child(header, "progressBox")
	local descriptionBox = child(widget, "descriptionBox")
	local description = child(descriptionBox, "description")
	local rewardsBox = child(widget, "rewardsBox")
	local detailIcon = child(rewardsBox, "detailIcon")
	local experienceReward = child(rewardsBox, "experienceReward")
	local goldReward = child(rewardsBox, "goldReward")
	local pointsReward = child(rewardsBox, "pointsReward")
	local rewardDetailsLabel = child(rewardsBox, "rewardDetails")
	local pointsIcon = child(pointsReward, "icon")
	local pointsValue = child(pointsReward, "value")
	local experienceIcon = child(experienceReward, "icon")
	local experienceValue = child(experienceReward, "value")
	local goldIcon = child(goldReward, "icon")
	local goldValue = child(goldReward, "value")

	title:setText(data.name)
	description:setText(data.description)
	stars:setWidth(11 * data.grade)
	positionSecretIcon(title, secretIcon, data.secret == true)

	local rewards = data.rewardTable
	local rewardDetails = formatRewardDetails(rewards)
	local hasExperience = type(rewards) == "table" and rewards.experience
	local hasGold = type(rewards) == "table" and rewards.gold
	local hasRewardDetails = rewardDetails ~= ""
	pointsIcon:setImageSource("/game_achievements/achievementsPointsIcon")
	experienceIcon:setImageSource("/game_achievements/exp")
	goldIcon:setImageSource("/game_achievements/gold")
	pointsValue:setText(formatNumber(data.points))
	experienceReward:setVisible(hasExperience ~= nil)
	goldReward:setVisible(hasGold ~= nil)
	detailIcon:setVisible(hasRewardDetails)
	setRewardTooltip(pointsReward, string.format("%s achievement points", formatNumber(data.points)))
	if hasExperience then
		experienceValue:setText(formatNumber(rewards.experience))
		setRewardTooltip(experienceReward, string.format("%s experience", formatNumber(rewards.experience)))
	end
	if hasGold then
		goldValue:setText(formatNumber(rewards.gold))
		setRewardTooltip(goldReward, string.format("%s gold", formatNumber(rewards.gold)))
	end
	rewardDetailsLabel:setText(rewardDetails)
	if hasRewardDetails then
		detailIcon:setTooltip(rewardDetails)
		rewardDetailsLabel:setTooltip(rewardDetails)
	else
		rewardDetailsLabel:setTooltip("")
	end
	tintReward(pointsReward, data.completed)
	tintReward(experienceReward, data.completed)
	tintReward(goldReward, data.completed)

	local progressTarget = math.max(tonumber(data.progressTarget) or 0, 0)
	local progressCurrent = data.completed and progressTarget or math.max(tonumber(data.progress) or 0, 0)
	if progressTarget > 0 then
		local progressPercent = data.completed and 100 or 0
		progressPercent = math.floor((math.min(progressCurrent, progressTarget) / progressTarget) * 100)
		progressBox:setVisible(true)
		progressBox:setWidth(92)
		progressBox:setPercent(progressPercent)
		progressBox:setText(string.format("%d/%d", progressCurrent, progressTarget))
	else
		progressBox:setWidth(0)
		progressBox:setVisible(false)
	end

	if data.completed then
		title:setColor("#909090")
		description:setColor("#C0C0C0")
	else
		title:setColor("#777777")
		stars:setImageColor("#777777")
		description:setColor("#777777")
		detailIcon:setImageColor("#777777")
		rewardDetailsLabel:setColor("#777777")
	end

	local descriptionHeight = measuredTextHeight(description, data.description, 84, 13, 39) + 16
	local rewardDetailsHeight = rewardDetails ~= "" and measuredTextHeight(rewardDetailsLabel, rewardDetails, 84, 13, 13) or 0
	local rewardsHeight = rewardDetails ~= "" and math.max(42, rewardDetailsHeight + 42) or 28

	descriptionBox:setHeight(descriptionHeight)
	rewardsBox:setHeight(rewardsHeight)
	widget:setHeight(22 + 5 + descriptionHeight + 5 + rewardsHeight + 6)
end

local function setProgressLine(widget, label, current, total)
	total = math.max(tonumber(total) or 0, 0)
	current = math.max(tonumber(current) or 0, 0)
	local percent = total > 0 and math.floor((current / total) * 100) or 0
	local labelWidget = child(widget, "label")
	local progressWidget = child(widget, "progress")
	labelWidget:setVisible(false)
	progressWidget:setPercent(percent)
	progressWidget:setText(string.format("%s  -  %d/%d", label, current, total))
end

local function appendAchievementEntries(count)
	if not mainWindow or isAppendingEntries then
		return
	end

	if renderedEntryCount >= #renderedEntries then
		return
	end

	isAppendingEntries = true
	local targetCount = math.min(#renderedEntries, renderedEntryCount + count)
	for index = renderedEntryCount + 1, targetCount do
		createAchievementEntry(renderedEntries[index])
	end
	renderedEntryCount = targetCount
	isAppendingEntries = false
end

local function appendEntriesNearScrollEnd(scrollbar, value)
	if not scrollbar or renderedEntryCount >= #renderedEntries then
		return
	end

	local maximum = scrollbar:getMaximum()
	if maximum and value >= maximum - APPEND_SCROLL_THRESHOLD then
		appendAchievementEntries(APPEND_RENDER_COUNT)
	end
end

function Achievements.render()
	if not mainWindow then
		return
	end

	mainWindow.ListBase.List:destroyChildren()
	renderedEntries = {}
	renderedEntryCount = 0

	local scrollbar = child(mainWindow.ListBase, "ListScrollbar")
	if scrollbar then
		scrollbar:setValue(scrollbar:getMinimum())
	end

	local secretCompleted = 0
	local secretTotal = 0
	local publicCompleted = 0
	local publicTotal = 0

	for _, id in ipairs(allIds) do
		local data = AchievementsData[id]
		if type(data) == "table" then
			if data.secret then
				secretTotal = secretTotal + 1
				if isCompleted(id) then
					secretCompleted = secretCompleted + 1
				end
			else
				publicTotal = publicTotal + 1
				if isCompleted(id) then
					publicCompleted = publicCompleted + 1
				end
			end
		end
	end

	setProgressLine(mainWindow.progressAll, "Total", publicCompleted + secretCompleted, publicTotal + secretTotal)
	setProgressLine(mainWindow.progressSecret, "Secret", secretCompleted, secretTotal)
	local totalPointsText = "Achievements Points: " .. formatNumber(Achievements.points or 0)
	child(mainWindow.totalPoints, "value"):setText(totalPointsText)
	mainWindow.totalPoints:setTooltip("Total earned achievement points")
	child(mainWindow.totalPoints, "icon"):setTooltip("Total earned achievement points")
	child(mainWindow.totalPoints, "value"):setTooltip("Total earned achievement points")

	renderedEntries = getEntries()
	appendAchievementEntries(INITIAL_RENDER_COUNT)
end

function Achievements.onExtendedOpcode(protocol, opcode, data)
	if type(data) ~= "table" or data.topic ~= "state-response" then
		return
	end

	completedIds = {}
	progressById = {}
	for _, id in ipairs(data.completedIds or {}) do
		completedIds[tonumber(id)] = true
	end
	for id, progress in pairs(data.progressById or {}) do
		progressById[tonumber(id)] = progress
	end

	Achievements.points = tonumber(data.points) or 0
	completedCount = tonumber(data.completedCount) or 0
	totalCount = tonumber(data.totalCount) or #allIds
	Achievements.render()
end

function Achievements.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(Achievements.opcode, data)
	end
end

function Achievements.toggle()
	if not mainWindow then
		return
	end

	if mainWindow:isVisible() then
		mainWindow:hide()
		return
	end

	Achievements.sendOpcode({ topic = "request-state" })
	mainWindow:show()
	mainWindow:focus()
end

function Achievements.onStart()
	if mainWindow then
		return
	end

	windowButton = modules.client_topmenu.addRightGameToggleButton("Achievements", tr("Achievements"), "/images/options/button_achievements", Achievements.toggle)
	g_ui.importStyle("achievements.otui")
	mainWindow = g_ui.createWidget("AchievementsWindow", modules.game_interface.gameRootPanel)
	mainWindow:hide()

	mainWindow.search.onTextChange = function(widget, text)
		searchText = (text or ""):lower()
		Achievements.render()
	end

	mainWindow.buffSummary.onClick = Achievements.showCombinedBuffs
	mainWindow.closeWindowButton.onClick = function()
		mainWindow:hide()
	end

	child(mainWindow.progressAll, "label"):setText("Total")
	child(mainWindow.progressSecret, "label"):setText("Secret")
	mainWindow.progressAll:setWidth(420)
	child(mainWindow.progressAll, "progress"):setWidth(420)
	mainWindow.progressSecret:setWidth(260)
	child(mainWindow.progressSecret, "progress"):setWidth(260)

	mainWindow.filterCombo:addOption("All", "all", true)
	mainWindow.filterCombo:addOption("Locked", "locked", true)
	mainWindow.filterCombo:addOption("Accomplished", "accomplished", true)
	mainWindow.filterCombo:addOption("Secret", "secret", true)
	mainWindow.filterCombo:addOption("In Progress", "inprogress", true)
	mainWindow.filterCombo:addOption("Rewards", "rewards", true)
	mainWindow.filterCombo:addOption("Buffs", "buffs", true)
	mainWindow.filterCombo.onOptionChange = function(widget)
		selectedFilter = widget:getCurrentOption().data
		Achievements.render()
	end

	mainWindow.gradeCombo:addOption("All Grades", "all", true)
	mainWindow.gradeCombo:addOption("Grade 1", "1", true)
	mainWindow.gradeCombo:addOption("Grade 2", "2", true)
	mainWindow.gradeCombo:addOption("Grade 3", "3", true)
	mainWindow.gradeCombo:addOption("Grade 4", "4", true)
	mainWindow.gradeCombo.onOptionChange = function(widget)
		selectedGrade = widget:getCurrentOption().data
		Achievements.render()
	end

	mainWindow.sort:addOption("In Order", 5, true)
	mainWindow.sort:addOption("Alphabetically", 1, true)
	mainWindow.sort:addOption("By Grade", 2, true)
	mainWindow.sort:addOption("Completed First", 3, true)
	mainWindow.sort:addOption("Closest to Complete", 4, true)
	mainWindow.sort.onOptionChange = function(widget)
		selectedSort = widget:getCurrentOption().data
		Achievements.render()
	end

	local listScrollbar = child(mainWindow.ListBase, "ListScrollbar")
	if listScrollbar then
		listScrollbar.onValueChange = function(scrollbar, value)
			appendEntriesNearScrollEnd(scrollbar, value)
		end
	end

	Achievements.render()
end

function Achievements.onEnd()
	if mainWindow then
		mainWindow:destroy()
		mainWindow = nil
	end
	if windowButton then
		windowButton:destroy()
		windowButton = nil
	end
	completedIds = {}
	progressById = {}
	renderedEntries = {}
	renderedEntryCount = 0
	isAppendingEntries = false
end

function Achievements.init()
	ProtocolGame.registerExtendedJSONOpcode(Achievements.opcode, Achievements.onExtendedOpcode)
	connect(g_game, { onGameStart = Achievements.onStart, onGameEnd = Achievements.onEnd })
	if g_game.isOnline() then
		Achievements.onStart()
	end
end

function Achievements.terminate()
	ProtocolGame.unregisterExtendedJSONOpcode(Achievements.opcode)
	disconnect(g_game, { onGameStart = Achievements.onStart, onGameEnd = Achievements.onEnd })
	Achievements.onEnd()
end
