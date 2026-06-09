POI = POI or {}

-- Constants

local POI_KEYBIND_CATEGORY = "Windows"
local POI_KEYBIND_ACTION = "Show/hide extended minimap"
local POI_LEGEND_VISIBLE_ROWS = 5
local POI_LEGEND_ROW_HEIGHT = 32
local POI_LEGEND_EXTRA_HEIGHT = 70
local POI_CARD_GRID_CELL_SIZE = 40
local POI_CARD_GRID_CELL_SPACING = 8
local POI_CARD_GRID_ROW_SPACING = 4

-- State

local poiTooltip = nil
local keybindRegistered = false

-- Widget access

local function trimText(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function getMinimapWidget()
    if modules.game_minimap and modules.game_minimap.getMiniMapUi then
        return modules.game_minimap.getMiniMapUi()
    end
    return nil
end

local function getPOIMinimapWidget()
    if POI.window and POI.window.mapHolder and POI.window.mapHolder.poiMinimap then
        return POI.window.mapHolder.poiMinimap
    end
    return nil
end

local function getRootPanel()
    return modules.game_interface.getRootPanel()
end

local function getPOIParent()
    return rootWidget or getRootPanel()
end

local function isWindowVisible()
    return POI.window and POI.window:isVisible()
end

local function getSearchPanel()
    return POI.POIPanel and POI.POIPanel.POISearchResults
end

local function getSearchScrollBar()
    return POI.POIPanel and POI.POIPanel.POISearchScrollBar
end

local function setSearchResultsEnabled(enabled)
    local resultsPanel = getSearchPanel()
    local scrollBar = getSearchScrollBar()
    if resultsPanel then
        resultsPanel:setEnabled(enabled)
        resultsPanel:setText(enabled and "" or "Search results")
    end
    if scrollBar then
        scrollBar:setEnabled(enabled)
    end
end

-- POI data helpers

local function getPOIDescription(poi)
    if poi.card and poi.card.sections then
        for _, section in ipairs(poi.card.sections) do
            if section.type == "text" and section.text then
                return section.text
            end
        end
    end

    if poi.description then
        return poi.description
    end
    if poi.extraTooltip then
        return poi.extraTooltip
    end
    if poi.tooltipInfo and poi.tooltipInfo.description then
        return poi.tooltipInfo.description.text
    end
    return nil
end

local function getPOITooltip(poi)
    local lines = { poi.name }
    if poi.locationName then
        table.insert(lines, poi.locationName)
    end
    local description = getPOIDescription(poi)
    if description then
        table.insert(lines, "")
        table.insert(lines, description)
    end
    return table.concat(lines, "\n")
end

local function getEntryTextTarget(widget)
    return widget and (widget.entryLabel or widget)
end

local function setPoiEntryText(widget, poi, locationColor)
    local target = getEntryTextTarget(widget)
    if poi.locationName then
        target:parseColoredText(string.format("%s: [color=%s]%s[/color]", poi.name, locationColor, poi.locationName))
    else
        target:setText(poi.name)
    end
end

local function resolveCardText(text, poi)
    if not text then
        return ""
    end

    return text
        :gsub("%$name", poi.name or "")
        :gsub("%$locationName", poi.locationName or "")
end

local function getCategoryData(categoryName)
    if POI.categories and POI.categories[categoryName] then
        return POI.categories[categoryName]
    end
    return POI.config and POI.config[categoryName]
end

local function getPoiCategoryData(poi)
    return poi and getCategoryData(poi.category or poi.poiType)
end

local function getCategoryPoints(categoryName)
    local points = {}
    for _, poi in ipairs(POI.points or {}) do
        if (poi.category or poi.poiType) == categoryName then
            table.insert(points, poi)
        end
    end

    if #points > 0 then
        return points
    end

    local categoryData = POI.config and POI.config[categoryName]
    return categoryData and categoryData.nodes or {}
end

local function getCategoryMarker(categoryName)
    local categoryData = getCategoryData(categoryName)
    return categoryData and (categoryData.marker or categoryData.defaultFlagImage)
end

local function destroyWindow()
    if POI.window then
        POI.window:destroy()
        POI.window = nil
    end
    POI.POIPanel = nil
    POI.legendPanel = nil
end

local function getPOIMapZoomConfig()
    local config = POI.mapZoom or {}
    return {
        default = config.default or 0,
        min = config.min or -5,
        max = config.max or 5
    }
end

local function applyPOIMapZoomConfig(poiMinimap)
    local zoom = getPOIMapZoomConfig()

    if poiMinimap.setMixZoom then
        poiMinimap:setMixZoom(zoom.min)
    elseif poiMinimap.setMinZoom then
        poiMinimap:setMinZoom(zoom.min)
    end

    if poiMinimap.setMaxZoom then
        poiMinimap:setMaxZoom(zoom.max)
    end

    poiMinimap:setZoom(zoom.default)
end

local function getDefaultMapPosition()
    local player = g_game.getLocalPlayer()
    if player then
        return player:getPosition()
    end

    for _, poi in ipairs(POI.POIsMap or {}) do
        if poi.position then
            return poi.position
        end
    end

    return nil
end

local function setupPOIMinimap()
    local poiMinimap = getPOIMinimapWidget()
    if not poiMinimap then
        return
    end

    poiMinimap.standardMarkers = false
    poiMinimap.autowalk = false
    poiMinimap.walkable = false
    poiMinimap.fullMapView = true
    poiMinimap:setPhantom(false)
    applyPOIMapZoomConfig(poiMinimap)

    local floorUpButton = poiMinimap:getChildById("floorUpButton")
    local floorDownButton = poiMinimap:getChildById("floorDownButton")
    local zoomInButton = poiMinimap:getChildById("zoomInButton")
    local zoomOutButton = poiMinimap:getChildById("zoomOutButton")
    local resetButton = poiMinimap:getChildById("resetButton")

    if floorUpButton then floorUpButton:hide() end
    if floorDownButton then floorDownButton:hide() end
    if zoomInButton then zoomInButton:hide() end
    if zoomOutButton then zoomOutButton:hide() end
    if resetButton then resetButton:hide() end

    local position = getDefaultMapPosition()
    if position then
        poiMinimap:setCameraPosition(position)
        poiMinimap:setCrossPosition(position)
    end
end

-- Lifecycle

function POI.init()
    if not keybindRegistered then
        Keybind.new(POI_KEYBIND_CATEGORY, POI_KEYBIND_ACTION, "Ctrl+Shift+M", "")
        keybindRegistered = true
    end
	if not POI.Button then
		POI.Button = modules.client_topmenu.addRightGameToggleButton("POIButton", tr("Points of Interest"), "/images/options/button_POI", POI.toggle)
	end
end

function POI.initializePOI()
    if POI.initialized then
        return
    end

    POI.buildPOILookups()
    POI.createPOIPanel()
    POI.loadLegendSettings()
    POI.createPOIsMinimapFlags()
    POI.refreshMinimapPOIFlagsVisibility()
    POI.initialized = true
end

function POI.buildPOILookups()
    POI.POIsMap = {}
    POI.POIsParentMap = {}
    POI.POIsParentList = {}
    POI.POIsById = {}

    for _, poi in ipairs(POI.points or {}) do
        poi.poiType = poi.category or poi.poiType
        table.insert(POI.POIsMap, poi)
        if poi.POIId then
            POI.POIsById[poi.POIId] = poi
        end
    end

    if #POI.POIsMap == 0 then
        for _, categoryName in ipairs(POI.categoryOrder) do
            for _, node in ipairs(getCategoryPoints(categoryName)) do
                node.poiType = categoryName
                table.insert(POI.POIsMap, node)
                if node.POIId then
                    POI.POIsById[node.POIId] = node
                end
            end
        end
    end

    for _, poi in ipairs(POI.POIsMap) do
        local parentId = poi.parentId
        if parentId then
            local parentPoi = POI.POIsById[parentId]
            if parentPoi then
                local parentKey = parentPoi.name
                if not POI.POIsParentMap[parentKey] then
                    POI.POIsParentMap[parentKey] = { parentPoi = parentPoi, children = {} }
                    table.insert(POI.POIsParentList, POI.POIsParentMap[parentKey])
                end
                table.insert(POI.POIsParentMap[parentKey].children, poi)
            end
        else
            if not POI.POIsParentMap[poi.name] then
                POI.POIsParentMap[poi.name] = { parentPoi = poi, children = {} }
                table.insert(POI.POIsParentList, POI.POIsParentMap[poi.name])
            else
                POI.POIsParentMap[poi.name].parentPoi = poi
            end
        end
    end
end

local function destroyPOIMarkers(poi)
    for _, node in pairs(poi.nodes or {}) do
        if node then
            node:destroy()
        end
    end
    poi.nodes = nil
end

local function createPOIMarker(minimapWidget, mapKey, poi, index)
    if not minimapWidget then
        return nil
    end

    local categoryData = getPoiCategoryData(poi)
    if not categoryData then
        return nil
    end

    local finalFlagImage = (poi.marker and poi.marker.image) or poi.flagImage or categoryData.marker or categoryData.defaultFlagImage or "/images/game/minimap/flag0"
    local poiNode = g_ui.createWidget("POIMarker", minimapWidget)
    poiNode:setId("MinimapPOINode" .. mapKey .. index)
    poiNode:setImageSource(finalFlagImage)
    poiNode:setTooltip(getPOITooltip(poi))
    poiNode:setPhantom(false)
    poiNode:setVisible((POI.poiDisplayFilters or {})[poi.poiType] ~= false)
    minimapWidget:centerInPosition(poiNode, poi.position)
    poiNode:raise()

    poiNode.onClick = function()
        POI.selectPOI(poi, 5, true)
    end

    poiNode.onHoverChange = function(widget, hovered)
        if hovered then
            POI.applyPOITooltip(poi)
            connect(rootWidget, { onMouseMove = POI.movePOITooltip })
        else
            POI.destroyPOITooltip()
        end
    end

    return poiNode
end

function POI.createPOIsMinimapFlags()
    local minimaps = {
        main = getMinimapWidget(),
        poi = getPOIMinimapWidget()
    }

    for index, poi in ipairs(POI.POIsMap) do
        destroyPOIMarkers(poi)
        poi.nodes = {}

        for mapKey, minimapWidget in pairs(minimaps) do
            local marker = createPOIMarker(minimapWidget, mapKey, poi, index)
            if marker then
                poi.nodes[mapKey] = marker
            end
        end
    end
end

-- Main window setup

local function resetPoiPanels()
    if POI.POIPanel then
        POI.POIPanel.POINavigator:destroyChildren()
        POI.POIPanel.POISearchResults:destroyChildren()
    end
    if POI.legendPanel then
        POI.legendPanel.legendsPanel:destroyChildren()
    end
end

local function setupSearchControls()
    local panel = POI.POIPanel
    if not panel then
        return
    end

    local combo = panel.POISearchComboBox
    combo:clearOptions()
    combo:addOption("All")
    for _, categoryName in ipairs(POI.categoryOrder) do
        if getCategoryData(categoryName) then
            combo:addOption(categoryName)
        end
    end

    combo.onOptionChange = function()
        POI.onPOISearch(panel.POISearch, panel.POISearch:getText())
    end

    setSearchResultsEnabled(false)
    panel.POISearch.onTextChange = function(widget, text)
        POI.onPOISearch(widget, text)
    end
    panel.exactNameCheckBox.onCheckChange = function()
        POI.onPOISearch(panel.POISearch, panel.POISearch:getText())
    end
end

local function createWindow()
    local parent = getPOIParent()
    if not parent then
        return nil
    end

    if not POI.window then
        POI.window = g_ui.displayUI("POI", parent)
        POI.window:setId("POI")
        POI.window:hide()
    elseif POI.window:getParent() ~= parent then
        POI.window:setParent(parent)
    end

    POI.window.onEscape = POI.close
    POI.window.onMouseRelease = function()
        return true
    end
    setupPOIMinimap()
    return POI.window
end

function POI.createPOIPanel()
    local window = createWindow()
    if not window then
        return
    end

    POI.POIPanel = POI.window.POIPanel
    POI.legendPanel = POI.window.legendPanel
    if not POI.POIPanel or not POI.legendPanel then
        return
    end

    resetPoiPanels()
    setupSearchControls()
    POI.createPOIsNavigator()
    POI.createPOILegend()
end

function POI.createPOIsNavigator()
    for _, categoryName in ipairs(POI.categoryOrder) do
        local categoryPoints = getCategoryPoints(categoryName)
        if #categoryPoints > 0 then
            local categoryWidget = g_ui.createWidget("POINavigatorCategory", POI.POIPanel.POINavigator)
            categoryWidget.poiListing:setText(string.upper(categoryName))

            local dropDownHeight = 0
            local entryCount = 0

            for _, poi in ipairs(categoryPoints) do
                if poi.displayInNavigatorPanel ~= false then
                    local poiEntry = g_ui.createWidget("POIEntry", categoryWidget.dropDownList)
                    poiEntry.onClick = function()
                        POI.selectPOI(poi, 5, true)
                    end

                    entryCount = entryCount + 1
                    setPoiEntryText(poiEntry, poi, "#cc9999")
                    poiEntry:setTooltip(getPOITooltip(poi))
                    dropDownHeight = dropDownHeight + poiEntry:getHeight()
                end
            end

            if entryCount == 0 and POI.hideEmptyCategory then
                categoryWidget:setVisible(false)
            end

            local defaultCategoryHeight = 40
            categoryWidget:setHeight(defaultCategoryHeight)
            categoryWidget.dropDownList:setHeight(dropDownHeight)
            categoryWidget.dropDownList:setVisible(false)

            local function toggleDropDown()
                local isVisible = categoryWidget.dropDownList:isVisible()
                categoryWidget.dropDownList:setVisible(not isVisible)
                if isVisible then
                    categoryWidget:setHeight(defaultCategoryHeight)
                    categoryWidget.poiListing.dropDownButton:setImageSource("/game_minimap/images/downButton")
                else
                    categoryWidget:setHeight(defaultCategoryHeight + dropDownHeight + 5)
                    categoryWidget.poiListing.dropDownButton:setImageSource("/game_minimap/images/upButton")
                end
            end

            categoryWidget.poiListing.onClick = toggleDropDown
            categoryWidget.poiListing.dropDownButton.onClick = toggleDropDown
        end
    end
end

function POI.createPOILegend()
    for _, categoryName in ipairs(POI.categoryOrder) do
        local finalFlag = getCategoryMarker(categoryName)
        if finalFlag then
            local legendEntry = g_ui.createWidget("LegendEntry", POI.legendPanel.legendsPanel)
            legendEntry.flagIcon:setImageSource(finalFlag)
            legendEntry.flagName:setText(categoryName)
            legendEntry.filterCheckBox:setChecked(true)
            legendEntry.filterCheckBox.onCheckChange = function(widget, checked)
                POI.setPOICategoryVisibility(categoryName, checked)
            end
        end
    end

    POI.legendPanel:setHeight((POI_LEGEND_VISIBLE_ROWS * POI_LEGEND_ROW_HEIGHT) + POI_LEGEND_EXTRA_HEIGHT)
    POI.legendPanel.displayAllFilterButton.onClick = function()
        for _, categoryName in ipairs(POI.categoryOrder) do
            POI.setPOICategoryVisibility(categoryName, true)
        end
    end
    POI.legendPanel.displayNoneFilterButton.onClick = function()
        for _, categoryName in ipairs(POI.categoryOrder) do
            POI.setPOICategoryVisibility(categoryName, false)
        end
    end
    if POI.window and POI.window.closeButton then
        POI.window.closeButton.onClick = POI.close
    end
end

function POI.open()
    POI.init()
    POI.initializePOI()
    if not POI.window or not POI.POIPanel or not POI.legendPanel then
        POI.createPOIPanel()
        POI.createPOIsMinimapFlags()
        POI.refreshMinimapPOIFlagsVisibility()
    end

    if not POI.window then
        return
    end

    setupPOIMinimap()
    POI.window:show()
    POI.window:raise()
    POI.window:focus()
end

function POI.close()
    if not isWindowVisible() then
        return
    end

    POI.destroyPOITooltip()
    if POI.window then
        POI.window:hide()
    end
end

function POI.toggle()
    if isWindowVisible() then
        POI.close()
    else
        POI.open()
    end
end

function POI.saveLegendSettings()
    local config = g_configs.create("/poi_settings.otml")
    config:setNode("poiDisplayFilters", POI.poiDisplayFilters)
    config:save()
end

function POI.loadLegendSettings()
    local config = g_configs.create("/poi_settings.otml")
    local savedFilters = config:getNode("poiDisplayFilters")

    if not savedFilters then
        savedFilters = {}
        for _, categoryName in ipairs(POI.categoryOrder) do
            savedFilters[categoryName] = true
        end
        config:setNode("poiDisplayFilters", savedFilters)
        config:save()
    end

    POI.poiDisplayFilters = savedFilters
    for _, categoryName in ipairs(POI.categoryOrder) do
        if POI.poiDisplayFilters[categoryName] == nil then
            POI.poiDisplayFilters[categoryName] = true
        end
    end
    POI.updateLegendAndFlagsVisibility()
end

function POI.updateLegendAndFlagsVisibility()
    POI.refreshMinimapPOIFlagsVisibility()

    if POI.legendPanel and POI.legendPanel.legendsPanel then
        for _, legendChild in ipairs(POI.legendPanel.legendsPanel:getChildren()) do
            local categoryName = legendChild.flagName:getText()
            local checkBox = legendChild.filterCheckBox
            if checkBox and POI.poiDisplayFilters[categoryName] ~= nil then
                checkBox:setChecked(POI.poiDisplayFilters[categoryName])
            end
        end
    end
end

function POI.setPOICategoryVisibility(categoryName, isEnabled)
    POI.poiDisplayFilters[categoryName] = isEnabled
    POI.saveLegendSettings()
    POI.updateLegendAndFlagsVisibility()
end

function POI.refreshMinimapPOIFlagsVisibility()
    for _, poi in ipairs(POI.POIsMap or {}) do
        for _, node in pairs(poi.nodes or {}) do
            node:setVisible(POI.poiDisplayFilters[poi.poiType] ~= false)
        end
    end
end

function POI.matchesSearch(str, query, wholeWord)
    if not str then
        return false
    end

    str = str:lower()
    query = query:lower()
    if wholeWord then
        return str == query
    end
    return str:find(query, 1, true) ~= nil
end

local function poiMatchesSearch(poi, query, exact)
    if poi.search and poi.search.aliases then
        for _, alias in ipairs(poi.search.aliases) do
            if POI.matchesSearch(alias, query, exact) then
                return true
            end
        end
    end

    if poi.card and poi.card.sections then
        for _, section in ipairs(poi.card.sections) do
            if section.text and POI.matchesSearch(resolveCardText(section.text, poi), query, exact) then
                return true
            end
        end
    end

    return POI.matchesSearch(poi.name, query, exact) or
        ((poi.search and poi.search.includeLocation) and POI.matchesSearch(poi.locationName, query, exact)) or
        POI.matchesSearch(getPOIDescription(poi), query, exact)
end

local function poiMatchesCategory(poi, selectedType)
    return selectedType == "All" or poi.poiType == selectedType
end

local function createSearchParentEntry(searchResultsPanel, poi)
    local parentWidget = g_ui.createWidget("POIEntry", searchResultsPanel)
    parentWidget.onClick = function()
        POI.focusPOI(poi, 5)
    end
    setPoiEntryText(parentWidget, poi, "#7bcc6e")
    parentWidget:setTooltip(getPOITooltip(poi))
end

local function createSearchChildEntry(searchResultsPanel, poi)
    local childWidget = g_ui.createWidget("POIEntryChild", searchResultsPanel)
    childWidget.entry.onClick = function()
        POI.focusPOI(poi, 5)
    end
    setPoiEntryText(childWidget.entry, poi, "#cc9999")
    childWidget.entry:setTooltip(getPOITooltip(poi))
end

local function applyItemWidgetData(widget, itemData)
    widget:setSize({ width = POI_CARD_GRID_CELL_SIZE, height = POI_CARD_GRID_CELL_SIZE })
    widget:setText("")
    if widget.setVirtual then
        widget:setVirtual(true)
    end
    if widget.setShowCount then
        widget:setShowCount(true)
    end

    if itemData.itemId then
        widget:setItemId(itemData.itemId)
    end

    if itemData.count then
        if widget.setItemCount then
            widget:setItemCount(itemData.count)
        end
    end

    widget:setBorderWidth((itemData.border and itemData.border.width) or 1)
    widget:setBorderColor((itemData.border and itemData.border.color) or "white")
end

local function renderCardTextSection(parent, section, poi, styleName)
    local label = g_ui.createWidget(styleName, parent)
    label:setText(resolveCardText(section.text, poi))
    if section.background == false and label.setImageSource then
        label:setImageSource("")
    end
    return label
end

local function centerBoxLayoutChild(widget, containerWidth, childWidth)
    if not containerWidth or not childWidth then
        return
    end

    widget:setMarginLeft(math.max(0, math.floor((containerWidth - childWidth) / 2)) + childWidth)
end

local function renderCardOutfitSection(parent, section, contentWidth)
    local creature = g_ui.createWidget("POICardOutfit", parent)
    local size = section.size or 96
    creature:setSize({ width = size, height = size })
    creature:setCreatureSize(size)
    centerBoxLayoutChild(creature, contentWidth, size)

    if section.outfit then
        creature:setOutfit(section.outfit)
    end
    return creature
end

local function getGridColumns(section)
    return math.max(1, math.min(section.columns or 5, 5))
end

local function createCardGrid(parent, count, columns, contentWidth)
    local grid = g_ui.createWidget("POICardGrid", parent)
    local rows = math.max(1, math.ceil(count / columns))
    grid:setHeight((rows * POI_CARD_GRID_CELL_SIZE) + ((rows - 1) * POI_CARD_GRID_ROW_SPACING))
    grid:setWidth(contentWidth)
    return grid
end

local function createCardGridRow(grid, cellCount, contentWidth)
    local row = g_ui.createWidget("POICardGridRow", grid)
    local rowWidth = (cellCount * POI_CARD_GRID_CELL_SIZE) + (math.max(0, cellCount - 1) * POI_CARD_GRID_CELL_SPACING)
    row:setWidth(rowWidth)
	centerBoxLayoutChild(row, contentWidth, rowWidth)
    return row
end

local function renderCardCreaturesSection(parent, section, contentWidth)
    local creatures = section.creatures or {}
    local columns = getGridColumns(section)
    local grid = createCardGrid(parent, #creatures, columns, contentWidth)
    local rows = {}

    for index, creatureData in ipairs(creatures) do
        local rowIndex = math.floor((index - 1) / columns)
        local firstIndex = (rowIndex * columns) + 1
        local rowCellCount = math.min(columns, #creatures - firstIndex + 1)
        rows[rowIndex] = rows[rowIndex] or createCardGridRow(grid, rowCellCount, contentWidth)
        local row = rows[rowIndex]
        local creature = g_ui.createWidget("POICardCreature", row)
        if creatureData.outfit then
            creature:setOutfit(creatureData.outfit)
        end
        if creatureData.size then
            creature:setSize({ width = creatureData.size, height = creatureData.size })
            creature:setCreatureSize(creatureData.size)
        end
        creature:setBorderWidth((creatureData.border and creatureData.border.width) or 1)
        creature:setBorderColor((creatureData.border and creatureData.border.color) or "white")
    end

    return grid
end

local function renderCardItemsSection(parent, section, contentWidth)
    local items = section.items or {}
    local columns = getGridColumns(section)
    local grid = createCardGrid(parent, #items, columns, contentWidth)
    local rows = {}

    for index, itemData in ipairs(items) do
        local rowIndex = math.floor((index - 1) / columns)
        local firstIndex = (rowIndex * columns) + 1
        local rowCellCount = math.min(columns, #items - firstIndex + 1)
        rows[rowIndex] = rows[rowIndex] or createCardGridRow(grid, rowCellCount, contentWidth)
        local row = rows[rowIndex]
        local item = g_ui.createWidget("POICardItem", row)
        applyItemWidgetData(item, itemData)
    end

    return grid
end

local function renderCardSection(parent, section, poi, contentWidth)
    if section.type == "title" then
        return renderCardTextSection(parent, section, poi, "POICardTitle")
    elseif section.type == "subtitle" then
        return renderCardTextSection(parent, section, poi, "POICardSubtitle")
    elseif section.type == "text" then
        return renderCardTextSection(parent, section, poi, "POICardSectionText")
    elseif section.type == "outfit" then
        return renderCardOutfitSection(parent, section, contentWidth)
    elseif section.type == "creatures" then
        return renderCardCreaturesSection(parent, section, contentWidth)
    elseif section.type == "items" then
        return renderCardItemsSection(parent, section, contentWidth)
    end
    return nil
end

function POI.selectPOI(poi, flashes, updateSearch)
    POI.focusPOI(poi, flashes or 5)

    if not updateSearch or not poi or not POI.POIPanel then
        return
    end

    local searchPoi = poi
    if poi.parentId then
        searchPoi = POI.POIsById[poi.parentId] or poi
    end

    local searchText = searchPoi.name or poi.name
    if not searchText or searchText == "" then
        return
    end

    if POI.POIPanel.POISearchComboBox then
        POI.POIPanel.POISearchComboBox:setOption("All")
    end

    local search = POI.POIPanel.POISearch
    if search then
        search:setText(searchText)
        POI.onPOISearch(search, searchText)
        POI.POIPanel:focus()
        search:focus()
        search:setCursorPos(-1)
    end
end

function POI.onPOISearch(widget, text)
    local searchResultsPanel = getSearchPanel()
    if not searchResultsPanel or not POI.POIPanel then
        return
    end

    searchResultsPanel:destroyChildren()

    text = trimText(text):lower()
    if text:len() < 1 then
        setSearchResultsEnabled(false)
        return
    end

    local selectedType = POI.POIPanel.POISearchComboBox:getText()
    local exact = POI.POIPanel.exactNameCheckBox:isChecked()
    setSearchResultsEnabled(true)

    local resultsCount = 0
    for _, entry in ipairs(POI.POIsParentList or {}) do
        if resultsCount >= POI.maxSearchResults then
            break
        end

        local parentPoi = entry.parentPoi
        local childList = entry.children
        if parentPoi then
            local parentMatches = poiMatchesCategory(parentPoi, selectedType) and poiMatchesSearch(parentPoi, text, exact)
            local childrenToShow = {}

            for _, childPoi in ipairs(childList) do
                if poiMatchesCategory(childPoi, selectedType) and (parentMatches or poiMatchesSearch(childPoi, text, exact)) then
                    table.insert(childrenToShow, childPoi)
                end
            end

            if parentMatches or #childrenToShow > 0 then
                resultsCount = resultsCount + 1
                createSearchParentEntry(searchResultsPanel, parentPoi)

                for _, childPoi in ipairs(childrenToShow) do
                    if resultsCount >= POI.maxSearchResults then
                        break
                    end

                    resultsCount = resultsCount + 1
                    createSearchChildEntry(searchResultsPanel, childPoi)
                end
            end
        end
    end

    if resultsCount == 0 then
        local noResultsLabel = g_ui.createWidget("POIEntry", searchResultsPanel)
        local target = getEntryTextTarget(noResultsLabel)
        target:setTextAlign(AlignLeftCenter)
        target:setText("No Results")
        target:setColor("yellow")
    end
end

local function estimateTextSectionHeight(section, poi, width)
    local text = resolveCardText(section.text, poi)
    local textLength = text:len()
    local charsPerLine = math.max(20, math.floor((width - 24) / 7))
    local lines = math.max(1, math.ceil(textLength / charsPerLine))
    return math.max(section.height or 24, (lines * 14) + 12)
end

local function estimateGridSectionHeight(section, itemCount)
    local columns = getGridColumns(section)
    local rows = math.max(1, math.ceil(itemCount / columns))
    return (rows * POI_CARD_GRID_CELL_SIZE) + ((rows - 1) * POI_CARD_GRID_ROW_SPACING)
end

local function getTooltipContentHeight(card, poi, width)
    local contentHeight = 16
    local sectionCount = 0

    for _, section in ipairs(card.sections or {}) do
        local sectionHeight = 0
        if section.type == "title" or section.type == "subtitle" or section.type == "text" then
            sectionHeight = estimateTextSectionHeight(section, poi, width)
        elseif section.type == "outfit" then
            sectionHeight = section.size or 96
        elseif section.type == "creatures" then
            sectionHeight = estimateGridSectionHeight(section, #(section.creatures or {}))
        elseif section.type == "items" then
            sectionHeight = estimateGridSectionHeight(section, #(section.items or {}))
        end

        if sectionHeight > 0 then
            sectionCount = sectionCount + 1
            contentHeight = contentHeight + sectionHeight
        end
    end

    if sectionCount > 1 then
        contentHeight = contentHeight + ((sectionCount - 1) * 4)
    end

    return contentHeight
end

local function resizeTooltipToContent(tooltip, card, categoryData, poi)
    local width = card.width or categoryData.width or categoryData.defaultWidth or 300
    local minHeight = card.height or categoryData.height or categoryData.defaultHeight or 100
    local maxHeight = card.maxHeight or 420
    local contentHeight = getTooltipContentHeight(card, poi, width)

    tooltip:setSize({
        width = width,
        height = math.min(maxHeight, math.max(minHeight, contentHeight))
    })
end

function POI.applyPOITooltip(poi)
    POI.destroyPOITooltip()

    local categoryData = getPoiCategoryData(poi)
    local card = poi.card
    if not categoryData or not card then
        return
    end

    local widgetClass = card.template or "POITooltipCard"
    poiTooltip = g_ui.createWidget(widgetClass, getPOIParent())
    poiTooltip:raise()

    poiTooltip:setSize({
        width = card.width or categoryData.width or categoryData.defaultWidth or 300,
        height = card.height or categoryData.height or categoryData.defaultHeight or 100
    })

    if poiTooltip.background then
        if card.background then
            poiTooltip.background:setImageSource(card.background)
            if card.background:find("panel", 1, true) then
                poiTooltip.background:setImageBorder(3)
            end
        elseif categoryData.background or categoryData.defaultBackground then
            poiTooltip.background:setImageSource(categoryData.background or categoryData.defaultBackground)
            poiTooltip.background:setImageBorder(3)
        end
        poiTooltip.background:setOpacity(card.backgroundOpacity or 1)
    end

    if card.border then
        poiTooltip:setBorderWidth(card.border.width)
        poiTooltip:setBorderColor(card.border.color)
        if poiTooltip.background then
            poiTooltip.background:setMargin(card.border.width)
        end
    end

    local content = poiTooltip.content or poiTooltip
    if content.destroyChildren then
        content:destroyChildren()
    end

    local contentWidth = (card.width or categoryData.width or categoryData.defaultWidth or 300) - 16
    for _, section in ipairs(card.sections or {}) do
        renderCardSection(content, section, poi, contentWidth)
    end
    resizeTooltipToContent(poiTooltip, card, categoryData, poi)

    POI.movePOITooltip()
    poiTooltip:show()
    poiTooltip:raise()
end

function POI.movePOITooltip()
    if not poiTooltip or not poiTooltip:isVisible() then
        return
    end

    local mousePos = g_window.getMousePosition()
    local windowSize = g_window.getSize()
    local tipSize = poiTooltip:getSize()
    mousePos.x = mousePos.x + 10
    mousePos.y = mousePos.y + 10

    if windowSize.width - (mousePos.x + tipSize.width) < 10 then
        mousePos.x = mousePos.x - tipSize.width - 3
    end
    if windowSize.height - (mousePos.y + tipSize.height) < 10 then
        mousePos.y = mousePos.y - tipSize.height - 3
    end

    poiTooltip:setPosition(mousePos)
    poiTooltip:raise()
end

function POI.destroyPOITooltip()
    disconnect(rootWidget, { onMouseMove = POI.movePOITooltip })
    if poiTooltip then
        poiTooltip:destroy()
        poiTooltip = nil
    end
end

function POI.focusPOI(poi, flashes)
    local minimapWidget = (POI.window and POI.window:isVisible() and getPOIMinimapWidget()) or getMinimapWidget()
    if not minimapWidget or not poi or not poi.position then
        return
    end
    minimapWidget:setCameraPosition(poi.position)
    POI.flashPOINode(poi, flashes or 5)
end

function POI.updateLocalPlayerPosition(pos)
    local poiMinimap = getPOIMinimapWidget()
    if not poiMinimap or not pos then
        return
    end

    poiMinimap:setCrossPosition(pos)
end

function POI.flashPOINode(poi, flashes)
    local nodes = poi.nodes or {}
    if not next(nodes) then
        return
    end

    local toggles = (flashes or 4) * 2
    local borderVisible = false
    local function toggleNext(count)
        if count <= 0 then
            for _, node in pairs(nodes) do
                node:setVisible(POI.poiDisplayFilters[poi.poiType] ~= false)
                node:setBorderWidth(0)
            end
            return
        end

        borderVisible = not borderVisible
        for _, node in pairs(nodes) do
            node:setVisible(POI.poiDisplayFilters[poi.poiType] ~= false)
            node:setBorderWidth(borderVisible and 2 or 0)
            node:setBorderColor("white")
        end
        scheduleEvent(function()
            toggleNext(count - 1)
        end, 200)
    end

    toggleNext(toggles)
end

function POI.findPOIById(id)
    return POI.POIsById and POI.POIsById[id]
end

function POI.goToPOIById(id, flashes)
    POI.open()
    local poi = POI.findPOIById(id)
    if poi then
        POI.focusPOI(poi, flashes or 5)
    end
end

function POI.clearPOIs()
    for _, poi in ipairs(POI.POIsMap or {}) do
        destroyPOIMarkers(poi)
    end
    POI.destroyPOITooltip()
end

function POI.onGameEnd()
    if isWindowVisible() then
        POI.close()
    end
    POI.clearPOIs()
    destroyWindow()
	if POI.Button then
		POI.Button:destroy()
		POI.Button = nil
	end
    POI.initialized = false
end

function POI.terminate()
    if isWindowVisible() then
        POI.close()
    end
    POI.clearPOIs()
    destroyWindow()
    if keybindRegistered then
        Keybind.delete(POI_KEYBIND_CATEGORY, POI_KEYBIND_ACTION)
        keybindRegistered = false
    end
    POI.initialized = false
end
