function ExtendedModals.init()
	ProtocolGame.registerExtendedOpcode(ExtendedModals.opcode, ExtendedModals.onExtendedOpcode)
	connect(g_game, { onGameStart = ExtendedModals.onStart, onGameEnd = ExtendedModals.onEnd })

	if g_game.isOnline() then
		ExtendedModals.onStart()
	end
end

function ExtendedModals.terminate()
	ProtocolGame.unregisterExtendedOpcode(ExtendedModals.opcode, ExtendedModals.onExtendedOpcode)
	disconnect(g_game, { onGameStart = ExtendedModals.onStart, onGameEnd = ExtendedModals.onEnd })
	ExtendedModals.onEnd()
end

function ExtendedModals.onStart()
	if not ExtendedModals.UI then
		ExtendedModals.UI = g_ui.displayUI("extendedModals")
	end

	ExtendedModals.UI:hide()
	ExtendedModals.currentModalId = nil
	ExtendedModals.selectedChoiceIds = {}
	ExtendedModals.sendOpcode({ topic = "items-cache-request" })

	ExtendedModals.UI.bottomPanel.enterButton.onClick = function()
		if ExtendedModals.currentModalId then
			ExtendedModals.sendOpcode({
				topic = "confirm-modal-request",
				modalId = ExtendedModals.currentModalId,
				selectedChoiceIds = ExtendedModals.selectedChoiceIds or {},
			})
		end
	end
end

function ExtendedModals.onEnd()
	if ExtendedModals.UI then
		ExtendedModals.UI:destroy()
		ExtendedModals.UI = nil
	end
end

local function asset(path)
	if type(path) ~= "string" then
		return ""
	end
	if path:sub(1, 1) == "/" then
		return path
	end
	return "/game_extendedModals/" .. path
end

local function formatAmount(data, suffix)
	local text = data.amount and tostring(data.amount) or ""
	if data.minAmount and data.maxAmount then
		text = tostring(data.minAmount) .. "-" .. tostring(data.maxAmount)
	end
	if suffix and text ~= "" then
		text = text .. suffix
	end
	if data.chance then
		text = text .. "\n" .. tostring(data.chance) .. "%"
	end
	return text
end

local function getItemRequirements(modalConfig)
	return modalConfig.itemRequirements or {}
end

local function countLines(text)
	if type(text) ~= "string" or text == "" then
		return 0
	end

	local _, count = text:gsub("\n", "")
	return count + 1
end

local function computeDetailsHeight(modalConfig)
	if modalConfig.detailsHeight then
		return modalConfig.detailsHeight
	end

	local requirementLines = countLines(modalConfig.requirementsInfoPanel)
	local requirementHeight = math.max(92, requirementLines * 18 + 44)
	if #getItemRequirements(modalConfig) > 0 then
		requirementHeight = requirementHeight + 76
	end

	local rewardCount = #(modalConfig.rewards or {}) + #(modalConfig.itemRewards or {})
	local rewardRows = math.max(1, math.ceil(rewardCount / 5))
	local rewardHeight = rewardRows * 63 + 42

	return math.min(250, math.max(125, requirementHeight, rewardHeight))
end

local function getOptionsGrid(modalConfig)
	return modalConfig.optionsGrid or modalConfig.selectionModal
end

local function getGridEntries(optionsGrid)
	if not optionsGrid then
		return {}
	end
	if optionsGrid.entries then
		return optionsGrid.entries
	end
	if not optionsGrid.tabs then
		return {}
	end

	local entries = {}
	for _, tab in ipairs(optionsGrid.tabs) do
		for _, entry in ipairs(tab.entries or {}) do
			entries[#entries + 1] = entry
		end
	end
	return entries
end

local function applyGridCellSize(gridWidget, cellSize)
	if type(cellSize) ~= "table" then
		return
	end

	local layout = gridWidget:getLayout()
	if not layout then
		return
	end

	if cellSize.width and layout.setCellWidth then
		layout:setCellWidth(cellSize.width)
	end
	if cellSize.height and layout.setCellHeight then
		layout:setCellHeight(cellSize.height)
	end
end

local function normalizeOutfit(outfit)
	if type(outfit) ~= "table" then
		return {}
	end
	return {
		type = outfit.type or outfit.lookType,
		auxType = outfit.auxType or outfit.typeex,
		addons = outfit.addons,
		mount = outfit.mountLookType or outfit.mountClientId or outfit.mount or outfit.lookMount,
		wings = outfit.wings,
		aura = outfit.aura,
		feet = outfit.feet,
		legs = outfit.legs,
		body = outfit.body,
		head = outfit.head,
	}
end

function ExtendedModals.getCachedItemInfo(itemId)
	if not ExtendedModals.cachedItemsInfo then
		return nil
	end
	return ExtendedModals.cachedItemsInfo[tostring(itemId)]
end

function ExtendedModals.toggle()
	if not ExtendedModals.UI then
		return
	end

	if ExtendedModals.UI:isVisible() then
		ExtendedModals.UI:hide()
	else
		ExtendedModals.UI:show()
		ExtendedModals.UI:raise()
		ExtendedModals.UI:focus()
	end
end

function ExtendedModals.renderBanner(parent, modalConfig, modalId)
	local bannerConfig = modalConfig.banner
	if not bannerConfig then
		return
	end

	local bannerPath
	local bannerHeight = ExtendedModals.defaultBannerHeight or 110
	if bannerConfig == true then
		bannerPath = "images/banners/" .. modalId
	elseif type(bannerConfig) == "string" then
		bannerPath = bannerConfig
	elseif type(bannerConfig) == "table" then
		bannerPath = bannerConfig.path or ("images/banners/" .. modalId)
		bannerHeight = bannerConfig.height or bannerHeight
	end

	local banner = g_ui.createWidget("ExtendedModalsBannerEntry", parent)
	banner:setImageSource(asset(bannerPath))
	banner:setHeight(bannerHeight)
end

function ExtendedModals.renderDetails(parent, modalConfig)
	if not modalConfig.requirementsInfoPanel and not modalConfig.rewards and not modalConfig.itemRewards and #getItemRequirements(modalConfig) == 0 then
		return
	end

	local mainPanel = g_ui.createWidget("ExtendedModalsMainPanelEntry", parent)
	mainPanel:setHeight(computeDetailsHeight(modalConfig))

	local requirementsText = modalConfig.requirementsInfoPanel
	if requirementsText then
		mainPanel.requirementsPanel.requirementsList.text:parseColoredText(requirementsText)
	else
		mainPanel.requirementsPanel.requirementsList.text:setText("No special requirements.")
	end

	local itemRequirements = getItemRequirements(modalConfig)
	if #itemRequirements == 0 then
		mainPanel.requirementsPanel.itemsRequirements:hide()
		mainPanel.requirementsPanel.itemsRequirements:setHeight(0)
	else
		mainPanel.requirementsPanel.itemsRequirements:show()
		mainPanel.requirementsPanel.itemsRequirements:setHeight(70)
		for _, requirement in ipairs(itemRequirements) do
			local itemInfo = ExtendedModals.getCachedItemInfo(requirement.itemId)
			if itemInfo and itemInfo.itemId then
				local entry = g_ui.createWidget("ExtendedModalsItemRewardEntry", mainPanel.requirementsPanel.itemsRequirements)
				entry.item:setItemId(itemInfo.itemId)
				entry.info:setText(tostring(requirement.amount or 1) .. "x")
				entry:setTooltip(itemInfo.name)
				entry.item:setTooltip(itemInfo.name)
				entry.info:setTooltip(itemInfo.name)
			end
		end
	end

	for _, reward in ipairs(modalConfig.rewards or {}) do
		local entry = g_ui.createWidget("ExtendedModalsRewardEntry", mainPanel.rewardsPanel)
		local rewardIcon = ExtendedModals.rewardIcons[reward.name] or ExtendedModals.rewardIcons.Default
		entry.reward:setImageSource(asset(rewardIcon))
		entry:setTooltip(reward.name or "Reward")
		entry.reward:setTooltip(reward.name or "Reward")
		entry.info:setTooltip(reward.name or "Reward")
		entry.reward:setWidth(reward.chance and 32 or 42)
		entry.reward:setHeight(reward.chance and 32 or 42)
		entry.info:setText(formatAmount(reward))
	end

	for _, reward in ipairs(modalConfig.itemRewards or {}) do
		local itemInfo = ExtendedModals.getCachedItemInfo(reward.itemId)
		if itemInfo and itemInfo.itemId then
			local entry = g_ui.createWidget("ExtendedModalsItemRewardEntry", mainPanel.rewardsPanel)
			entry.item:setItemId(itemInfo.itemId)
			entry:setTooltip(itemInfo.name)
			entry.item:setTooltip(itemInfo.name)
			entry.info:setTooltip(itemInfo.name)
			entry.item:setWidth(reward.chance and 32 or 42)
			entry.item:setHeight(reward.chance and 32 or 42)
			entry.info:setText(formatAmount(reward, "x"))
		end
	end
end

function ExtendedModals.renderDescription(parent, text)
	if not text or text == "" then
		return
	end

	local descLabel = g_ui.createWidget("ExtendedModalsLabelEntry", parent)
	descLabel:setText("Description")
	local descEntry = g_ui.createWidget("ExtendedModalsDescriptionEntry", parent)
	descEntry.scrollArea.text:setText(text)
end

function ExtendedModals.renderRewardGrid(parent, rewards, itemRewards)
	if (not rewards or #rewards == 0) and (not itemRewards or #itemRewards == 0) then
		return
	end

	local grid = g_ui.createWidget("ExtendedModalsRewardsGridEntry", parent)
	for _, reward in ipairs(rewards or {}) do
		local entry = g_ui.createWidget("ExtendedModalsRewardEntry", grid.rewards)
		local rewardIcon = ExtendedModals.rewardIcons[reward.name] or ExtendedModals.rewardIcons.Default
		entry.reward:setImageSource(asset(rewardIcon))
		entry:setTooltip(reward.name or "Reward")
		entry.reward:setTooltip(reward.name or "Reward")
		entry.info:setTooltip(reward.name or "Reward")
		entry.reward:setWidth(reward.chance and 32 or 42)
		entry.reward:setHeight(reward.chance and 32 or 42)
		entry.info:setText(formatAmount(reward))
	end

	for _, reward in ipairs(itemRewards or {}) do
		local itemInfo = ExtendedModals.getCachedItemInfo(reward.itemId)
		if itemInfo and itemInfo.itemId then
			local entry = g_ui.createWidget("ExtendedModalsItemRewardEntry", grid.rewards)
			entry.item:setItemId(itemInfo.itemId)
			entry:setTooltip(itemInfo.name)
			entry.item:setTooltip(itemInfo.name)
			entry.info:setTooltip(itemInfo.name)
			entry.item:setWidth(reward.chance and 32 or 42)
			entry.item:setHeight(reward.chance and 32 or 42)
			entry.info:setText(formatAmount(reward, "x"))
		end
	end
end

function ExtendedModals.setSelectedChoice(choiceId, mode, maxChoices)
	if not choiceId then
		return
	end

	mode = mode or "single"
	maxChoices = tonumber(maxChoices) or 1
	if mode == "multi" then
		ExtendedModals.selectedChoiceIds = ExtendedModals.selectedChoiceIds or {}
		for index, selectedChoiceId in ipairs(ExtendedModals.selectedChoiceIds) do
			if selectedChoiceId == choiceId then
				table.remove(ExtendedModals.selectedChoiceIds, index)
				return
			end
		end
		if #ExtendedModals.selectedChoiceIds < maxChoices then
			ExtendedModals.selectedChoiceIds[#ExtendedModals.selectedChoiceIds + 1] = choiceId
		end
	else
		ExtendedModals.selectedChoiceIds = {choiceId}
	end
end

function ExtendedModals.isChoiceSelected(choiceId)
	for _, selectedChoiceId in ipairs(ExtendedModals.selectedChoiceIds or {}) do
		if selectedChoiceId == choiceId then
			return true
		end
	end
	return false
end

function ExtendedModals.renderOptionPreview(entry, optionWidget)
	optionWidget.imagePreview:hide()
	optionWidget.itemPreview:hide()
	optionWidget.creaturePreview:hide()

	if entry.type == "item" and entry.itemId then
		local itemInfo = ExtendedModals.getCachedItemInfo(entry.itemId)
		optionWidget.itemPreview:show()
		optionWidget.itemPreview:setItemId(itemInfo and itemInfo.itemId or entry.itemId)
		optionWidget.amount:setText(entry.amount and tostring(entry.amount) .. "x" or "")
	elseif entry.type == "creature" then
		optionWidget.creaturePreview:show()
		optionWidget.creaturePreview:setOutfit(normalizeOutfit(entry.outfit))
		optionWidget.amount:setText("")
	else
		optionWidget.imagePreview:show()
		optionWidget.imagePreview:setImageSource(asset(entry.image or "images/rewards/default"))
		optionWidget.amount:setText("")
	end
end

function ExtendedModals.renderOptionsGrid(parent, modalConfig)
	local optionsGrid = getOptionsGrid(modalConfig)
	if not optionsGrid then
		return
	end

	local panel = g_ui.createWidget("ExtendedModalsOptionsGridEntry", parent)
	panel:setHeight(optionsGrid.height or ExtendedModals.defaultOptionsHeight or 300)
	panel.header.title:setText(optionsGrid.title or modalConfig.name or "Options")
	panel.header.subtitle:setText(optionsGrid.subtitle or "")

	local cellSize = optionsGrid.cellSize or {}
	applyGridCellSize(panel.options, cellSize)

	local mode = optionsGrid.mode or "single"
	local maxChoices = optionsGrid.maxChoices or 1
	for _, entry in ipairs(getGridEntries(optionsGrid)) do
		local optionWidget = g_ui.createWidget("ExtendedModalsOptionEntry", panel.options)
		if cellSize.width then
			optionWidget:setWidth(cellSize.width)
		end
		if cellSize.height then
			optionWidget:setHeight(cellSize.height)
		end
		optionWidget:setId(entry.choiceId or entry.label or "")
		optionWidget.title:setText(entry.label or entry.name or entry.choiceId or "")
		optionWidget.description:setText(entry.description or "")
		optionWidget:setTooltip(entry.tooltip or entry.description or entry.label or "")
		ExtendedModals.renderOptionPreview(entry, optionWidget)
		optionWidget.onClick = function(widget)
			ExtendedModals.setSelectedChoice(entry.choiceId, mode, maxChoices)
			for _, child in ipairs(panel.options:getChildren()) do
				child:setChecked(ExtendedModals.isChoiceSelected(child:getId()))
			end
			widget:setChecked(ExtendedModals.isChoiceSelected(entry.choiceId))
		end
	end
end

function ExtendedModals.renderSections(parent, modalConfig)
	for _, section in ipairs(modalConfig.sections or {}) do
		local sectionPanel = g_ui.createWidget("ExtendedModalsSectionEntry", parent)
		sectionPanel.title:setText(section.title or "")
		if section.text and section.text ~= "" then
			sectionPanel.text:parseColoredText(section.text)
		else
			sectionPanel.text:setText(section.subtitle or "")
		end

		ExtendedModals.renderRewardGrid(sectionPanel.content, section.rewards, section.itemRewards)
		ExtendedModals.renderOptionsGrid(sectionPanel.content, section)
	end
end

function ExtendedModals.resetWindowPosition(resetToken)
	if resetToken and resetToken ~= ExtendedModals.positionResetToken then
		return
	end

	local ui = ExtendedModals.UI
	if not ui then
		return
	end

	ui:updateLayout()
	ui:updateParentLayout()

	local parent = ui:getParent()
	if parent then
		local x = math.max(0, math.floor((parent:getWidth() - ui:getWidth()) / 2))
		local y = math.max(0, math.floor((parent:getHeight() - ui:getHeight()) / 2))
		ui:setX(x)
		ui:setY(y)
		ui:bindRectToParent()
	else
		ui:centerIn("parent")
	end

	ui:removeAnchor(AnchorHorizontalCenter)
	ui:removeAnchor(AnchorVerticalCenter)
end

function ExtendedModals.resetWindowPositionDeferred()
	ExtendedModals.positionResetToken = (ExtendedModals.positionResetToken or 0) + 1
	local resetToken = ExtendedModals.positionResetToken

	ExtendedModals.resetWindowPosition(resetToken)
	addEvent(function()
		ExtendedModals.resetWindowPosition(resetToken)
	end)
	scheduleEvent(function()
		ExtendedModals.resetWindowPosition(resetToken)
	end, 25)
	scheduleEvent(function()
		ExtendedModals.resetWindowPosition(resetToken)
		if resetToken == ExtendedModals.positionResetToken and ExtendedModals.UI then
			ExtendedModals.UI:setOpacity(1)
			ExtendedModals.UI:raise()
			ExtendedModals.UI:focus()
		end
	end, 75)
end

function ExtendedModals.launchModal(modalId)
	if not ExtendedModals.UI then
		ExtendedModals.onStart()
	end

	local modalConfig = ExtendedModals.windowsConfig[modalId]
	if not modalConfig then
		return
	end

	local ui = ExtendedModals.UI
	ui:hide()
	ui:setText(modalConfig.name or "Modal")
	ui:setWidth(modalConfig.width or ExtendedModals.defaultWindowWidth or 620)
	ui.contentPanel:destroyChildren()
	ExtendedModals.selectedChoiceIds = {}
	ExtendedModals.currentModalId = modalId

	local displayType = modalConfig.displayType or "details"
	ExtendedModals.renderBanner(ui.contentPanel, modalConfig, modalId)
	if displayType == "details" or displayType == "hybrid" then
		ExtendedModals.renderDetails(ui.contentPanel, modalConfig)
	end
	if displayType == "optionsGrid" or displayType == "hybrid" then
		ExtendedModals.renderOptionsGrid(ui.contentPanel, modalConfig)
	end
	if displayType == "sections" then
		ExtendedModals.renderSections(ui.contentPanel, modalConfig)
	end
	ExtendedModals.renderDescription(ui.contentPanel, modalConfig.descriptionPanel)

	ui.bottomPanel.enterButton:setText(modalConfig.confirmText or ExtendedModals.defaultConfirmText or "Confirm")
	ui.bottomPanel.closeButton:setText(modalConfig.closeText or ExtendedModals.defaultCloseText or "Close")
	ui:setOpacity(0)
	ui:show()
	ExtendedModals.resetWindowPositionDeferred()
	ui:raise()
	ui:focus()
end

function ExtendedModals.onExtendedOpcode(protocol, opcode, buffer)
	local ok, data = pcall(json.decode, buffer)
	if not ok or type(data) ~= "table" then
		return
	end

	if data.topic == "items-cache-reply" then
		ExtendedModals.cachedItemsInfo = data.cachedItemsInfo or {}
	elseif data.topic == "launch-extended-modal" then
		ExtendedModals.launchModal(data.modalId)
	elseif data.topic == "message-reply" then
		displayInfoBox(data.title or "Extended Modals", data.message or "")
	end
end

function ExtendedModals.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(ExtendedModals.opcode, data)
	end
end
