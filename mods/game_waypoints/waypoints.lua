Waypoints.opcode = 214
Waypoints.currentMapId = "riftborn"
Waypoints.currentNodeId = nil
Waypoints.discoveredMaps = {}
Waypoints.discoveredNodes = {}
Waypoints.markers = {}
Waypoints.entries = {}
Waypoints.categoryState = {}
Waypoints.currentEntry = nil

Waypoints.mapZoom = {
	default = 2,
	min = -3,
	max = 4,
}

local STATUS_LOCKED = 1
local STATUS_UNLOCKED = 2
local STATUS_CURRENT = 3
local statusColors = {
	[STATUS_LOCKED] = "alpha",
	[STATUS_UNLOCKED] = "#e8d0b3",
	[STATUS_CURRENT] = "green",
}
local listTextColors = {
	[STATUS_LOCKED] = "#8f8272",
	[STATUS_UNLOCKED] = "#e8d0b3",
	[STATUS_CURRENT] = "green",
}
local CATEGORY_SETTINGS_KEY = "waypoints_categories"

local function getRootPanel()
	return modules.game_interface.getRootPanel()
end

local function getWindowParent()
	return rootWidget or getRootPanel()
end

local function sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(Waypoints.opcode, data)
	end
end

local function getMapById(mapId)
	for mapIndex, mapConfig in ipairs(Waypoints.config) do
		if mapConfig.id == mapId then
			return mapConfig, mapIndex
		end
	end
	return nil
end

local function getNodeById(mapConfig, nodeId)
	if not mapConfig then
		return nil
	end

	for nodeIndex, node in ipairs(mapConfig.nodes or {}) do
		if node.id == nodeId then
			return node, nodeIndex
		end
	end
	return nil
end

local function getCategoryKey(mapConfig)
	return mapConfig.id
end

local function categoryHasCurrentNode(mapConfig)
	if not mapConfig or mapConfig.id ~= Waypoints.currentMapId then
		return false
	end

	for _, node in ipairs(mapConfig.nodes or {}) do
		if node.id == Waypoints.currentNodeId then
			return true
		end
	end
	return false
end

local function isCategoryExpanded(mapConfig)
	local key = getCategoryKey(mapConfig)
	if Waypoints.categoryState[key] == nil then
		return true
	end
	return Waypoints.categoryState[key] == true
end

local function saveCategoryState()
	g_settings.setNode(CATEGORY_SETTINGS_KEY, Waypoints.categoryState)
	g_settings.save()
end

local function loadCategoryState()
	Waypoints.categoryState = g_settings.getNode(CATEGORY_SETTINGS_KEY) or {}
end

local function isTruthy(value)
	return value == true or value == 1 or value == "1" or value == "true"
end

local function isNodeDiscovered(mapConfig, node)
	if not mapConfig or not node then
		return false
	end
	if node.discoverable == false then
		return true
	end
	return Waypoints.discoveredNodes[mapConfig.id] and isTruthy(Waypoints.discoveredNodes[mapConfig.id][node.id])
end

local function getNodeStatus(mapConfig, node)
	if node.id == Waypoints.currentNodeId and mapConfig.id == Waypoints.currentMapId then
		return STATUS_CURRENT
	end
	return isNodeDiscovered(mapConfig, node) and STATUS_UNLOCKED or STATUS_LOCKED
end

local function getNodeKey(mapConfig, node)
	return mapConfig.id .. ":" .. node.id
end

local function getCostText(node)
	local cost = tonumber(node.cost) or 0
	if cost > 0 then
		return cost .. " gold"
	end
	return ""
end

local function getNodeTooltip(mapConfig, node)
	if getNodeStatus(mapConfig, node) == STATUS_LOCKED then
		return nil
	end

	local lines = { node.name }
	local costText = getCostText(node)
	if costText ~= "" then
		table.insert(lines, costText)
	end
	return table.concat(lines, "\n")
end

local function getCurrentNodeName()
	local mapConfig = getMapById(Waypoints.currentMapId)
	local node = getNodeById(mapConfig, Waypoints.currentNodeId)
	return node and node.name or "-"
end

local function getWaypointMinimap()
	if Waypoints.UI and Waypoints.UI.mapHolder and Waypoints.UI.mapHolder.waypointMinimap then
		return Waypoints.UI.mapHolder.waypointMinimap
	end
	return nil
end

local function destroyMarkers()
	for _, marker in pairs(Waypoints.markers or {}) do
		marker:destroy()
	end
	Waypoints.markers = {}
end

local function setMarkerHover(mapConfig, node, hovered)
	local marker = Waypoints.markers[getNodeKey(mapConfig, node)]
	if not marker or not marker.inside then
		return
	end

	if hovered then
		marker.inside:setImageColor("white")
		if marker.inside.icon then
			marker.inside.icon:show()
		end
	else
		local color = statusColors[marker.status] or statusColors[STATUS_LOCKED]
		marker.inside:setImageColor(color)
		if marker.inside.icon then
			marker.inside.icon:setImageColor(color)
			marker.inside.icon:hide()
		end
	end
end

local function applyMapSettings()
	local minimap = getWaypointMinimap()
	if not minimap then
		return
	end

	minimap.standardMarkers = false
	minimap.autowalk = false
	minimap.walkable = false
	minimap.fullMapView = true
	minimap.alternatives = minimap.alternatives or {}
	minimap:setPhantom(false)
	minimap.onMouseRelease = function()
		return true
	end

	if minimap.setMixZoom then
		minimap:setMixZoom(Waypoints.mapZoom.min)
	elseif minimap.setMinZoom then
		minimap:setMinZoom(Waypoints.mapZoom.min)
	end
	if minimap.setMaxZoom then
		minimap:setMaxZoom(Waypoints.mapZoom.max)
	end
	minimap:setZoom(Waypoints.mapZoom.default)

	local floorUpButton = minimap:getChildById("floorUpButton")
	local floorDownButton = minimap:getChildById("floorDownButton")
	local zoomInButton = minimap:getChildById("zoomInButton")
	local zoomOutButton = minimap:getChildById("zoomOutButton")
	local resetButton = minimap:getChildById("resetButton")

	if floorUpButton then floorUpButton:hide() end
	if floorDownButton then floorDownButton:hide() end
	if zoomInButton then zoomInButton:hide() end
	if zoomOutButton then zoomOutButton:hide() end
	if resetButton then resetButton:hide() end
end

local function focusNode(node)
	local minimap = getWaypointMinimap()
	if minimap and node and node.position then
		minimap:setCameraPosition(node.position)
		minimap:setCrossPosition(node.position)
	end
end

local function requestTravel(mapConfig, node)
	if not mapConfig or not node then
		return
	end
	if node.id == Waypoints.currentNodeId and mapConfig.id == Waypoints.currentMapId then
		return
	end
	if not isNodeDiscovered(mapConfig, node) then
		return
	end

	sendOpcode({
		topic = "travel",
		mapId = mapConfig.id,
		nodeId = node.id,
	})
end

local function setEntryState(entry, mapConfig, node)
	local status = getNodeStatus(mapConfig, node)
	local discovered = status ~= STATUS_LOCKED
	local current = status == STATUS_CURRENT
	local tooltip = getNodeTooltip(mapConfig, node)

	entry.name:setText(discovered and node.name or "Undiscovered")
	entry.cost:setText(discovered and getCostText(node) or "")
	entry.name:setMarginTop(discovered and getCostText(node) ~= "" and 4 or 0)
	entry.name:setColor(listTextColors[status] or "#8f8272")
	entry.cost:setColor(current and "green" or "#e8d0b3")
	entry:setEnabled(true)
	entry:setPhantom(false)
	entry:setOpacity(discovered and 1 or 0.55)
	entry:setTooltip(tooltip)
	entry.name:setTooltip(tooltip)
	entry.cost:setTooltip(tooltip)

	if discovered and not current then
		entry.onClick = function()
			requestTravel(mapConfig, node)
		end
	else
		entry.onClick = nil
	end

	entry.onHoverChange = function(widget, hovered)
		if hovered then
			focusNode(node)
		end
		setMarkerHover(mapConfig, node, hovered)
	end
end

local function createMarker(mapConfig, node)
	local minimap = getWaypointMinimap()
	if not minimap then
		return
	end

	local status = getNodeStatus(mapConfig, node)
	local marker = g_ui.createWidget("WaypointMarker", minimap)
	local tooltip = getNodeTooltip(mapConfig, node)
	marker:setId("WaypointMarker_" .. mapConfig.id .. "_" .. node.id)
	marker:setTooltip(tooltip)
	marker:setText(status == STATUS_LOCKED and "?" or "")
	marker:setPhantom(false)
	marker.status = status
	if marker.inside then
		marker.inside:setTooltip(tooltip)
		local color = statusColors[status] or statusColors[STATUS_LOCKED]
		marker.inside:setImageColor(color)
		if marker.inside.icon then
			marker.inside.icon:setTooltip(tooltip)
			marker.inside.icon:setImageColor(color)
			marker.inside.icon:hide()
		end
	end

	minimap:centerInPosition(marker, node.position)
	marker:raise()

	if status == STATUS_UNLOCKED then
		marker.onClick = function()
			requestTravel(mapConfig, node)
		end
	else
		marker.onClick = nil
	end

	marker.onHoverChange = function(widget, hovered)
		if tooltip then
			if hovered and g_tooltip and not g_mouse.isPressed() then
				g_tooltip.display(tooltip)
			elseif g_tooltip then
				g_tooltip.hide()
			end
		end
		setMarkerHover(mapConfig, node, hovered)
	end

	Waypoints.markers[getNodeKey(mapConfig, node)] = marker
end

local function getOuterHeight(widget)
	if not widget then
		return 0
	end

	local marginTop = widget.getMarginTop and widget:getMarginTop() or 0
	local marginBottom = widget.getMarginBottom and widget:getMarginBottom() or 0
	return widget:getHeight() + marginTop + marginBottom
end

local function measureChildrenHeight(widget)
	if not widget then
		return 0
	end

	if widget.updateLayout then
		widget:updateLayout()
	end

	local children = widget:getChildren()
	if #children == 0 then
		return 0
	end

	local minY = nil
	local maxY = nil
	for _, child in ipairs(children) do
		local childY = child:getY()
		local childBottom = childY + getOuterHeight(child)
		minY = minY and math.min(minY, childY) or childY
		maxY = maxY and math.max(maxY, childBottom) or childBottom
	end

	return math.max(0, (maxY or 0) - (minY or 0))
end

local function applyCategoryState(categoryWidget, mapConfig, forceExpanded)
	local expanded = forceExpanded or isCategoryExpanded(mapConfig)

	if expanded then
		categoryWidget.dropDownList:show()
		categoryWidget.dropDownList:setHeight(measureChildrenHeight(categoryWidget.dropDownList))
		categoryWidget.header.dropDownButton:setImageSource("/game_minimap/images/upButton")
	else
		categoryWidget.dropDownList:hide()
		categoryWidget.dropDownList:setHeight(0)
		categoryWidget.header.dropDownButton:setImageSource("/game_minimap/images/downButton")
	end

	if categoryWidget.updateLayout then
		categoryWidget:updateLayout()
	end
	categoryWidget:setHeight(getOuterHeight(categoryWidget.header) + (expanded and getOuterHeight(categoryWidget.dropDownList) or 0))
	if Waypoints.UI and Waypoints.UI.sidePanel and Waypoints.UI.sidePanel.list and Waypoints.UI.sidePanel.list.updateLayout then
		Waypoints.UI.sidePanel.list:updateLayout()
	end
end

local function toggleCategory(categoryWidget, mapConfig)
	local key = getCategoryKey(mapConfig)
	if categoryHasCurrentNode(mapConfig) then
		Waypoints.categoryState[key] = true
		applyCategoryState(categoryWidget, mapConfig, true)
	else
		Waypoints.categoryState[key] = not isCategoryExpanded(mapConfig)
		applyCategoryState(categoryWidget, mapConfig)
	end
	saveCategoryState()
end

local function scrollListToCurrentNode()
	if not Waypoints.UI or not Waypoints.currentEntry then
		return
	end

	local list = Waypoints.UI.sidePanel.list
	local scrollbar = Waypoints.UI.sidePanel.listScrollBar
	if not list or not scrollbar then
		return
	end

	local listPos = list:getPosition()
	local entryPos = Waypoints.currentEntry:getPosition()
	local target = entryPos.y - listPos.y - math.floor(list:getHeight() / 2) + math.floor(Waypoints.currentEntry:getHeight() / 2)
	if target < 0 then
		target = 0
	end

	if scrollbar.setValue then
		scrollbar:setValue(target)
	elseif list.setVirtualOffset then
		list:setVirtualOffset({ x = 0, y = target })
	end
end

local function createCategory(mapConfig)
	local categoryWidget = g_ui.createWidget("WaypointCategory", Waypoints.UI.sidePanel.list)
	local hasCurrentNode = false
	categoryWidget.header.title:setText(mapConfig.name)
	-- categoryWidget:setTooltip(mapConfig.name)
	-- categoryWidget.header:setTooltip(mapConfig.name)
	-- categoryWidget.header.title:setTooltip(mapConfig.name)
	categoryWidget.header.onClick = function()
		toggleCategory(categoryWidget, mapConfig)
	end

	for _, node in ipairs(mapConfig.nodes or {}) do
		createMarker(mapConfig, node)
		local entry = g_ui.createWidget("WaypointListEntry", categoryWidget.dropDownList)
		setEntryState(entry, mapConfig, node)
		if getNodeStatus(mapConfig, node) == STATUS_CURRENT then
			Waypoints.currentEntry = entry
			hasCurrentNode = true
		end
	end

	applyCategoryState(categoryWidget, mapConfig, hasCurrentNode)
	return categoryWidget
end

function Waypoints.createWindow()
	if Waypoints.UI then
		return
	end

	Waypoints.UI = g_ui.displayUI("waypoints", getWindowParent())
	Waypoints.UI:hide()
	Waypoints.UI.onEscape = Waypoints.hide
	Waypoints.UI.onMouseRelease = function()
		return true
	end
	Waypoints.UI.closeButton.onClick = Waypoints.hide
	applyMapSettings()
end

function Waypoints.refresh()
	if not Waypoints.UI then
		Waypoints.createWindow()
	end
	if not Waypoints.UI then
		return
	end

	applyMapSettings()
	destroyMarkers()
	Waypoints.UI.sidePanel.list:destroyChildren()
	Waypoints.currentEntry = nil
	Waypoints.UI.sidePanel.currentLabel:setText("Current: " .. getCurrentNodeName())

	for _, mapConfig in ipairs(Waypoints.config) do
		createCategory(mapConfig)
	end

	local currentMap = getMapById(Waypoints.currentMapId)
	local currentNode = getNodeById(currentMap, Waypoints.currentNodeId)
	if currentNode then
		focusNode(currentNode)
	else
		local player = g_game.getLocalPlayer()
		if player then
			focusNode({ position = player:getPosition() })
		end
	end
end

function Waypoints.show()
	Waypoints.createWindow()
	Waypoints.refresh()
	if Waypoints.UI then
		Waypoints.UI:show()
		Waypoints.UI:raise()
		Waypoints.UI:focus()
		scheduleEvent(scrollListToCurrentNode, 50)
	end
end

function Waypoints.hide()
	if Waypoints.UI then
		Waypoints.UI:hide()
	end
end

function Waypoints.onExtendedOpcode(protocol, opcode, data)
	if not data or not data.topic then
		return
	end

	if data.discoveredMaps then
		Waypoints.discoveredMaps = data.discoveredMaps
	end
	if data.discoveredNodes then
		Waypoints.discoveredNodes = data.discoveredNodes
	end
	if data.currentMap then
		Waypoints.currentMapId = data.currentMap
	end
	if data.currentNode then
		Waypoints.currentNodeId = data.currentNode
	end

	if data.topic == "open" then
		Waypoints.show()
	elseif data.topic == "state" then
		Waypoints.refresh()
	elseif data.topic == "close" then
		Waypoints.hide()
	elseif data.topic == "message" and data.message then
		displayInfoBox("Waypoints", data.message)
	end
end

function Waypoints.onGameStart()
	Waypoints.createWindow()
	sendOpcode({ topic = "request-state" })
end

function Waypoints.onGameEnd()
	destroyMarkers()
	if Waypoints.UI then
		Waypoints.UI:destroy()
		Waypoints.UI = nil
	end
	Waypoints.currentNodeId = nil
	Waypoints.discoveredMaps = {}
	Waypoints.discoveredNodes = {}
	Waypoints.currentEntry = nil
end

function Waypoints.init()
	loadCategoryState()
	connect(g_game, {
		onGameStart = Waypoints.onGameStart,
		onGameEnd = Waypoints.onGameEnd,
	})
	ProtocolGame.registerExtendedJSONOpcode(Waypoints.opcode, Waypoints.onExtendedOpcode)

	if g_game.isOnline() then
		Waypoints.onGameStart()
	end
end

function Waypoints.terminate()
	disconnect(g_game, {
		onGameStart = Waypoints.onGameStart,
		onGameEnd = Waypoints.onGameEnd,
	})
	ProtocolGame.unregisterExtendedJSONOpcode(Waypoints.opcode)
	Waypoints.onGameEnd()
end
