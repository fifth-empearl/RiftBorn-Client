Notifications = {}

Notifications.notificationsWindow = nil
Notifications.notificationList = nil
Notifications.categoryCombo = nil
Notifications.notificationsButton = nil

Notifications.history = {}
Notifications.currentName = nil
Notifications.pendingPopups = {}
Notifications.activePopups = {}




------ Config
Notifications.opCode = 198
Notifications.maxPopups = 3
Notifications.topMarginStart = 150
Notifications.maxHistoryPerPlayer = 100

Notifications.buttonIconEmpty = "/images/options/button_notifications"
Notifications.buttonIconFilled = "/images/options/button_notifications"

Notifications.notificationCallbacks = {
	-- [1] = function()
		-- local protocol = g_game.getProtocolGame()
		-- if protocol then
			-- protocol:sendExtendedJSONOpcode(12, {action = "joinPvPEvent"})
		-- end
	-- end,
	-- [2] = function()
		-- local protocol = g_game.getProtocolGame()
		-- if protocol then
			-- protocol:sendExtendedJSONOpcode(13, {action = "ClaimOnlineGift"})
		-- end
	-- end,
	-- [3] = function()
		-- modules.game_viplist:toggle()
		-- g_modules.getModule("game_notifications")Notifications.toggle()
	-- end
}

Notifications.iconIdPath = {
	[1] = "/images/topbuttons/motd",
	[2] = "/images/topbuttons/motd"
}

Notifications.soundIdPath = {
	[1] = "/sounds/alarm",
	[2] = "/sounds/Player_Attack"
}




function Notifications.playSound(soundId)
	if not g_sounds then
		return
	end
	local soundPath = Notifications.soundIdPath[soundId]
	if not soundPath then
		return
	end
	g_sounds.getChannel(SoundChannels.Effect):play(soundPath, 0, 1.0)
end

function Notifications.updateButtonIcon()
	if not Notifications.notificationsButton then
		return
	end
	local hasNotifications = false
	if Notifications.currentName then
		local records = Notifications.history[Notifications.currentName]
		hasNotifications = records and #records > 0
	end
	-- if hasNotifications then
		-- Notifications.notificationsButton.icon:setIcon(Notifications.buttonIconFilled)
	-- else
		-- Notifications.notificationsButton.icon:setIcon(Notifications.buttonIconEmpty)
	-- end
end

function Notifications.refreshCategories()
	Notifications.categoryCombo:clearOptions()
	Notifications.categoryCombo:addOption("All")
	if not Notifications.currentName or not Notifications.history[Notifications.currentName] then
		Notifications.categoryCombo:setCurrentOption("All")
		return
	end
	local added = {}
	for _, info in ipairs(Notifications.history[Notifications.currentName]) do
		if info.category and not added[info.category] then
			Notifications.categoryCombo:addOption(info.category)
			added[info.category] = true
		end
	end
	Notifications.categoryCombo:setCurrentOption("All")
end

function Notifications.refreshList()
	Notifications.notificationList:destroyChildren()
	if not Notifications.currentName then
		Notifications.updateButtonIcon()
		return
	end
	local records = Notifications.history[Notifications.currentName] or {}
	local filter = Notifications.categoryCombo:getCurrentOption()
	filter = filter and filter.text or "All"
	for index, info in ipairs(records) do
		if filter == "All" or info.category == filter then
			local label = g_ui.createWidget("NotificationListLabel", Notifications.notificationList)
			local title = label:getChildById("title")
			local message = label:getChildById("message")
			local time = label:getChildById("time")
			title:setText("[" .. info.category .. "] " .. (info.title or ""))
			message:setText(info.message)
			time:setText(os.date("%H:%M", info.timestamp))
			label:setTooltip(info.message)
			local icon = label:getChildById("icon")
			local itemIcon = label:getChildById("itemIcon")
			local iconWidth = 0
			if info.itemId then
				itemIcon:setItemId(info.itemId)
				itemIcon:setVisible(true)
				icon:setVisible(false)
				icon:setWidth(0)
				iconWidth = itemIcon:getWidth() + 4
				title:setMarginLeft(iconWidth)
				message:setMarginLeft(iconWidth)
			elseif info.iconId then
				icon:setImageSource(Notifications.iconIdPath[info.iconId])
				icon:setVisible(true)
				itemIcon:setVisible(false)
				iconWidth = icon:getWidth()
				title:setMarginLeft(iconWidth)
				message:setMarginLeft(iconWidth)
			else
				icon:setVisible(false)
				icon:setWidth(0)
				itemIcon:setVisible(false)
				title:setMarginLeft(0)
				message:setMarginLeft(0)
			end

			local titleSize = title:getTextSize()
			local messageSize = message:getTextSize()
			label:setHeight(
				titleSize.height + message:getMarginTop() + messageSize.height + label:getPaddingTop() +
					label:getPaddingBottom()
			)
			label.notificationIndex = index
			label.onMousePress = function(widget, pos, button)
				if button == MouseLeftButton then
					if info.callbackId then
						Notifications.notificationsCallback(info.callbackId)
					end
					for i, popup in ipairs(Notifications.activePopups) do
						if popup.data == info then
							Notifications.fadeDestroy(popup)
							break
						end
					end
					local queue = Notifications.pendingPopups[Notifications.currentName]
					if queue then
						for i = #queue, 1, -1 do
							if queue[i] == info then
								table.remove(queue, i)
								break
							end
						end
					end
					table.remove(records, widget.notificationIndex)
					Notifications.refreshCategories()
					Notifications.refreshList()
					return true
				end
				return false
			end
		end
	end
	Notifications.updateButtonIcon()
end

function Notifications.clearNotifications()
	if Notifications.currentName then
		Notifications.history[Notifications.currentName] = {}
		Notifications.pendingPopups[Notifications.currentName] = {}
		for i = #Notifications.activePopups, 1, -1 do
			Notifications.fadeDestroy(Notifications.activePopups[i])
		end
		Notifications.activePopups = {}
	end
	Notifications.refreshCategories()
	Notifications.refreshList()
end

function Notifications.repositionPopups()
	local top = Notifications.topMarginStart
	for _, popup in ipairs(Notifications.activePopups) do
		popup:setMarginTop(top)
		top = top + popup:getHeight() + 4
	end
end

function Notifications.removeActivePopup(popup)
	for i, activePopup in ipairs(Notifications.activePopups) do
		if activePopup == popup then
			table.remove(Notifications.activePopups, i)
			return true
		end
	end
	return false
end

function Notifications.cleanupPopup(popup)
	if not popup then
		return
	end
	removeEvent(popup.progressEvent)
	popup.progressEvent = nil
	removeEvent(popup.destroyEvent)
	popup.destroyEvent = nil
	g_effects.cancelFade(popup)
	popup.onMousePress = nil
	popup.onDestroy = nil
	popup.data = nil
end

function Notifications.destroyPopup(popup, showNext)
	if not popup or popup:isDestroyed() then
		return
	end
	Notifications.removeActivePopup(popup)
	Notifications.cleanupPopup(popup)
	popup:destroy()
	Notifications.repositionPopups()
	if showNext ~= false then
		Notifications.showNextPopup()
	end
end

function Notifications.onPopupDestroy(popup)
	Notifications.removeActivePopup(popup)
	Notifications.cleanupPopup(popup)
	Notifications.repositionPopups()
	Notifications.showNextPopup()
end

function Notifications.fadeDestroy(popup, time)
	if not popup or popup.fading then
		return
	end
	popup.fading = true
	time = time or 250
	removeEvent(popup.progressEvent)
	popup.progressEvent = nil
	g_effects.fadeOut(popup, time)
	popup.destroyEvent = scheduleEvent(
		function()
			Notifications.destroyPopup(popup)
		end,
		time
	)
end

function Notifications.createPopup(data)
	local duration = data.time or 5000
	local popup = g_ui.createWidget("NotificationPopup", rootWidget)
	popup.data = data
	popup.expires = g_clock.millis() + duration
	local titleWidget = popup:getChildById("title")
	local messageWidget = popup:getChildById("message")
	titleWidget:setText(data.title or "")
	messageWidget:setText(data.message)
	local iconWidget = popup:getChildById("icon")
	local itemIconWidget = popup:getChildById("itemIcon")
	if data.itemId then
		itemIconWidget:setItemId(data.itemId)
		itemIconWidget:setVisible(true)
		iconWidget:setVisible(false)
		local iconWidth = itemIconWidget:getWidth() + 4
		titleWidget:setMarginLeft(iconWidth)
		messageWidget:setMarginLeft(iconWidth)
	elseif data.iconId then
		iconWidget:setImageSource(Notifications.iconIdPath[data.iconId])
		iconWidget:setVisible(true)
		itemIconWidget:setVisible(false)
		local iconWidth = iconWidget:getWidth() + 4
		titleWidget:setMarginLeft(iconWidth)
		messageWidget:setMarginLeft(iconWidth)
	else
		iconWidget:setVisible(false)
		itemIconWidget:setVisible(false)
		titleWidget:setMarginLeft(0)
		messageWidget:setMarginLeft(0)
	end
	local progress = popup:getChildById("timeBar")
	popup.onMousePress = function(widget, pos, button)
		if button == MouseLeftButton then
			if widget.data.callbackId then
				Notifications.notificationsCallback(widget.data.callbackId)
			end
			local records = Notifications.history[Notifications.currentName] or {}
			for i, info in ipairs(records) do
				if info == widget.data then
					table.remove(records, i)
					break
				end
			end
			Notifications.refreshCategories()
			Notifications.refreshList()
			Notifications.fadeDestroy(widget)
			return true
		end
		return false
	end

	local titleSize = titleWidget:getTextSize()
	local messageSize = messageWidget:getTextSize()
	local extraWidth = 0
	local iconHeight = 0
	if data.itemId then
		extraWidth = itemIconWidget:getWidth() + 4
		iconHeight = itemIconWidget:getHeight()
	elseif data.iconId then
		extraWidth = iconWidget:getWidth() + 4
		iconHeight = iconWidget:getHeight()
	end
	local popupWidth = math.max(200, math.max(titleSize.width, messageSize.width) + extraWidth + 8)
	popup:setWidth(popupWidth)
	titleWidget:setWidth(popupWidth - extraWidth - 8)
	messageWidget:setWidth(popupWidth - extraWidth - 8)
	titleSize = titleWidget:getTextSize()
	messageSize = messageWidget:getTextSize()
	local progressHeight = progress and progress:getHeight() or 0
	local textHeight = titleSize.height + messageWidget:getMarginTop() + messageSize.height
	popup:setHeight(math.max(textHeight, iconHeight) + progressHeight + 8)
	table.insert(Notifications.activePopups, popup)
	Notifications.repositionPopups()
	if progress then
		progress:setPercent(100)
		local startTime = g_clock.millis()
		popup.progressEvent =
			cycleEvent(
			function()
				if not popup or popup:isDestroyed() then
					return
				end
				local progressBar = popup:getChildById("timeBar")
				if not progressBar then
					Notifications.destroyPopup(popup)
					return
				end
				local elapsed = g_clock.millis() - startTime
				local remain = duration - elapsed
				if remain <= 0 then
					Notifications.fadeDestroy(popup)
					return
				end
				progressBar:setPercent(remain / duration * 100)
			end,
			50
		)
		popup.onDestroy = Notifications.onPopupDestroy
	else
		popup.destroyEvent = scheduleEvent(
			function()
				Notifications.fadeDestroy(popup)
			end,
			duration
		)
		popup.onDestroy = Notifications.onPopupDestroy
	end
end

function Notifications.showNextPopup()
	if not Notifications.currentName then
		return
	end
	local queue = Notifications.pendingPopups[Notifications.currentName]
	if not queue or #queue == 0 then
		return
	end
	while #Notifications.activePopups < Notifications.maxPopups and #queue > 0 do
		local data = table.remove(queue, 1)
		Notifications.createPopup(data)
	end
end

function Notifications.enqueuePopup(data)
	if not Notifications.currentName then
		return
	end
	Notifications.pendingPopups[Notifications.currentName] =
		Notifications.pendingPopups[Notifications.currentName] or {}
	table.insert(Notifications.pendingPopups[Notifications.currentName], data)
	Notifications.showNextPopup()
end

function Notifications.notificationsCallback(id)
	local cb = Notifications.notificationCallbacks[id]
	if cb then
		cb()
	end
end

function Notifications.onExtendedOpcode(protocol, opcode, data)
	if type(data) ~= "table" or not Notifications.currentName then
		return
	end

	data.category = tostring(data.category or "General"):sub(1, 32)
	data.message = tostring(data.message or ""):sub(1, 500)
	data.title = tostring(data.title or ""):sub(1, 80)
	data.time = math.min(math.max(tonumber(data.time) or 5000, 1000), 60000)
	data.iconId = tonumber(data.iconId)
	data.callbackId = tonumber(data.callbackId)
	data.soundId = tonumber(data.soundId)
	data.itemId = tonumber(data.itemId)
	data.timestamp = os.time()
	if data.soundId then
		Notifications.playSound(data.soundId)
	end
	Notifications.history[Notifications.currentName] = Notifications.history[Notifications.currentName] or {}
	table.insert(Notifications.history[Notifications.currentName], data)
	while #Notifications.history[Notifications.currentName] > Notifications.maxHistoryPerPlayer do
		table.remove(Notifications.history[Notifications.currentName], 1)
	end
	Notifications.refreshCategories()
	Notifications.refreshList()
	Notifications.enqueuePopup(data)
end

function Notifications.online()
	Notifications.currentName = g_game.getLocalPlayer():getName()
	Notifications.history[Notifications.currentName] = Notifications.history[Notifications.currentName] or {}
	Notifications.pendingPopups[Notifications.currentName] =
		Notifications.pendingPopups[Notifications.currentName] or {}
	Notifications.refreshCategories()
	Notifications.refreshList()
	Notifications.showNextPopup()
end

function Notifications.offline()
	Notifications.notificationsWindow:hide()
	local name = Notifications.currentName
	Notifications.currentName = nil
	Notifications.updateButtonIcon()
	if #Notifications.activePopups > 0 then
		if name then
			Notifications.pendingPopups[name] = Notifications.pendingPopups[name] or {}
			for i = #Notifications.activePopups, 1, -1 do
				local popup = Notifications.activePopups[i]
				if popup.data then
					local remain = (popup.expires or 0) - g_clock.millis()
					if remain > 0 then
						popup.data.time = remain
						table.insert(Notifications.pendingPopups[name], 1, popup.data)
					end
				end
				Notifications.destroyPopup(popup, false)
			end
		else
			for i = #Notifications.activePopups, 1, -1 do
				Notifications.destroyPopup(Notifications.activePopups[i], false)
			end
		end
	else
		local popup = rootWidget:getChildById("notificationPopup")
		if popup then
			Notifications.destroyPopup(popup, false)
		end
	end
end

function Notifications.toggle()
	if Notifications.notificationsWindow:isVisible() then
		Notifications.notificationsWindow:hide()
	else
		Notifications.refreshCategories()
		Notifications.refreshList()
		Notifications.notificationsWindow:show()
		Notifications.notificationsWindow:raise()
		Notifications.notificationsWindow:focus()
	end
end

function Notifications.init()
	Notifications.notificationsWindow = g_ui.displayUI("notifications")
	Notifications.notificationsWindow:setVisible(false)
	Notifications.notificationList = Notifications.notificationsWindow:getChildById("notificationList")
	Notifications.categoryCombo = Notifications.notificationsWindow:getChildById("categoryCombo")
	Notifications.categoryCombo.onOptionChange = function()
		Notifications.refreshList()
	end
	Notifications.notificationsWindow:getChildById("clearAllButton").onClick = Notifications.clearNotifications

	Notifications.notificationsButton =
		modules.client_topmenu.addRightGameToggleButton(
		"notificationsButton",
		tr("Notifications"),
		Notifications.buttonIconEmpty,
		Notifications.toggle
	)

	Notifications.notificationsButton:setOn(false)
	Notifications.updateButtonIcon()

	connect(g_game, {onGameStart = Notifications.online, onGameEnd = Notifications.offline})
	ProtocolGame.registerExtendedJSONOpcode(Notifications.opCode, Notifications.onExtendedOpcode)

	if g_game.isOnline() then
		Notifications.online()
	end
end

function Notifications.terminate()
	ProtocolGame.unregisterExtendedJSONOpcode(Notifications.opCode)
	disconnect(g_game, {onGameStart = Notifications.online, onGameEnd = Notifications.offline})
	if #Notifications.activePopups > 0 then
		for i = #Notifications.activePopups, 1, -1 do
			Notifications.destroyPopup(Notifications.activePopups[i], false)
		end
	else
		local popup = rootWidget:getChildById("notificationPopup")
		if popup then
			Notifications.destroyPopup(popup, false)
		end
	end
	if Notifications.notificationsButton then
		Notifications.notificationsButton:destroy()
		Notifications.notificationsButton = nil
	end
	if Notifications.notificationsWindow then
		Notifications.notificationsWindow:destroy()
		Notifications.notificationsWindow = nil
	end
end

return Notifications
