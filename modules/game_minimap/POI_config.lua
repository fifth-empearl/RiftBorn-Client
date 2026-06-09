POI = POI or {}

POI.initialized = false
POI.hideEmptyCategory = false
POI.maxSearchResults = 50
POI.categoryOrder = { "General", "NPCs", "Hunts", "Quests", "Dungeons" }
POI.mapZoom = {
    default = 2,
    min = -3,
    max = 3
}

local poiImagePath = "/game_minimap/images/"
local poiBannersPath = poiImagePath .. "banners/"
local poiMarkersPath = "/images/rpgicons/"

-- Legacy category data

POI.config = {
    NPCs = {
        defaultWidth = 300,
        defaultHeight = 100,
        defaultBackground = poiImagePath .. "panel",
        defaultFlagImage = poiMarkersPath .. "Bag_0",
        nodes = {
            {
                name = "Eryn",
                POIId = 1,
                position = { x = 1019, y = 1073, z = 7 },
                locationName = "Windshore Temple",
                allowSearchByLocationName = true,
                parentId = 7,
                tooltipInfo = {
                    outfit = { type = 1024, head = 114, body = 84, legs = 49, feet = 114, addons = 3 },
                    description = { text = "Sells runes and potions.", descBackground = true },
                    backgroundOpacity = 0.9
                }
            },
            {
                POIId = 101,
                name = "Eryn",
                position = { x = 32367, y = 32240, z = 7 },
                locationName = "RiftBorn Temple",
                allowSearchByLocationName = true,
                parentId = 100,
                tooltipInfo = {
                    outfit = { type = 1024, head = 114, body = 84, legs = 49, feet = 114, addons = 3 },
                    description = { text = "Placeholder supplies NPC near Position: (32369, 32241, 7).", descBackground = true },
                    backgroundOpacity = 0.9
                }
            },
            {
                POIId = 102,
                name = "Thalen",
                position = { x = 32372, y = 32239, z = 7 },
                locationName = "RiftBorn Market",
                allowSearchByLocationName = true,
                parentId = 104,
                tooltipInfo = {
                    outfit = { type = 1056, head = 78, body = 69, legs = 58, feet = 76, addons = 1 },
                    description = { text = "Placeholder equipment and repair NPC.", descBackground = true },
                    backgroundOpacity = 0.9
                }
            }
        }
    },
    Hunts = {
        defaultWidth = 300,
        defaultHeight = 100,
        defaultBackground = poiImagePath .. "panel",
        defaultFlagImage = poiMarkersPath .. "Skull_0",
        nodes = {
            {
                name = "Demon",
                POIId = 2,
                flagImage = poiMarkersPath .. "Sword_0",
                position = { x = 1019, y = 1083, z = 7 },
                locationName = "Rifts Dungeon",
                parentId = 6,
                displayInNavigatorPanel = false,
                tooltipInfo = {
                    background = poiBannersPath .. "demon",
                    outfit = { type = 542 },
                    description = { text = "Level: 100-120" },
                    border = { width = 2, color = "#000000" }
                }
            },
            {
                name = "Blood Knight",
                POIId = 3,
                position = { x = 1032, y = 1083, z = 7 },
                locationName = "Rifts Dungeon",
                parentId = 6,
                displayInNavigatorPanel = false,
                tooltipInfo = {
                    background = poiBannersPath .. "demon",
                    outfit = { type = 1714 },
                    description = { text = "Level: 100-120" },
                    border = { width = 2, color = "#000000" }
                }
            },
            {
                name = "Demon",
                POIId = 4,
                position = { x = 1119, y = 1083, z = 7 },
                locationName = "South-West Windshore",
                tooltipInfo = {
                    background = poiBannersPath .. "demon",
                    outfit = { type = 542 },
                    description = { text = "Level: 100-120" },
                    border = { width = 2, color = "#000000" }
                }
            },
            {
                POIId = 110,
                name = "Rotworm Tunnels",
                position = { x = 32355, y = 32249, z = 8 },
                locationName = "Below RiftBorn",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "rifts_dungeon",
                    outfit = { type = 574 },
                    description = { text = "Level: 8-20" },
                    border = { width = 2, color = "#000000" }
                }
            },
            {
                POIId = 111,
                name = "Goblin Ridge",
                position = { x = 32386, y = 32231, z = 7 },
                locationName = "North-East RiftBorn",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "windshore",
                    outfit = { type = 684 },
                    description = { text = "Level: 15-35" },
                    border = { width = 2, color = "#000000" }
                }
            },
            {
                POIId = 112,
                name = "Forgotten Crypt",
                position = { x = 32346, y = 32262, z = 8 },
                locationName = "South-West RiftBorn",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "rifts_dungeon",
                    outfit = { type = 1271 },
                    description = { text = "Level: 35-60" },
                    border = { width = 2, color = "#000000" }
                }
            }
        }
    },
    Quests = {
        defaultWidth = 360,
        defaultHeight = 110,
        defaultBackground = poiImagePath .. "panel",
        defaultFlagImage = poiMarkersPath .. "Book_0",
        nodes = {
            {
                name = "Frozen Knight Quest",
                POIId = 5,
                position = { x = 1049, y = 1083, z = 7 },
                tooltipInfo = {
                    background = poiBannersPath .. "frozen_knight_quest",
                    border = { width = 2, color = "#000000" },
                    description = { text = "Level: 200-220", descBackground = true },
                    rewards = {
                        { itemId = 7449, border = { width = 2, color = "#5bf5f5" } },
                        { itemId = 3420 },
                        { itemId = 3386 },
                        { itemId = 3392 },
                        { itemId = 3079 },
                        { itemId = 3041 },
                        { itemId = 7643 },
                        { itemId = 3043, count = 100 }
                    }
                }
            },
            {
                POIId = 120,
                name = "First Rift Quest",
                position = { x = 32363, y = 32237, z = 7 },
                locationName = "RiftBorn Temple",
                allowSearchByLocationName = true,
                parentId = 100,
                tooltipInfo = {
                    background = poiBannersPath .. "windshore",
                    border = { width = 2, color = "#000000" },
                    description = { text = "Placeholder quest starter near Position: (32369, 32241, 7).", descBackground = true },
                    rewards = {
                        { itemId = 3031, count = 100 },
                        { itemId = 3035, count = 10 }
                    }
                }
            },
            {
                POIId = 121,
                name = "Merchant's Missing Crate",
                position = { x = 32375, y = 32247, z = 7 },
                locationName = "Riftborn Market",
                allowSearchByLocationName = true,
                parentId = 104,
                tooltipInfo = {
                    background = poiBannersPath .. "marapur",
                    border = { width = 2, color = "#000000" },
                    description = { text = "Placeholder city errand quest.", descBackground = true },
                    rewards = {
                        { itemId = 3035, count = 5 },
                        { itemId = 3043, count = 1 }
                    }
                }
            }
        }
    },
    Dungeons = {
        defaultWidth = 360,
        defaultHeight = 110,
        defaultBackground = poiImagePath .. "panel",
        defaultFlagImage = poiMarkersPath .. "Chest_0",
        nodes = {
            {
                name = "Rifts Dungeon",
                POIId = 6,
                position = { x = 1029, y = 1083, z = 8 },
                locationName = "North-East Windshore Underground",
                extraTooltip = "This Dungeon has X boss and Demons, Blood Knights, etc",
                tooltipInfo = {
                    background = poiBannersPath .. "rifts_dungeon",
                    border = { width = 2, color = "#000000" },
                    description = { text = "Level: 80-100", descBackground = true },
                    creatures = {
                        { outfit = { type = 542 }, border = { width = 2, color = "#fcba03" } },
                        { outfit = { type = 1714 } },
                        { outfit = { type = 289, body = 80, legs = 95, feet = 115 } },
                        { outfit = { type = 1244, head = 58, body = 94, legs = 132, feet = 76, addons = 3 } },
                        { outfit = { type = 1069 } },
                        { outfit = { type = 1490 } },
                        { outfit = { type = 1808 } },
                        { outfit = { type = 1282 } }
                    }
                }
            },
            {
                POIId = 130,
                name = "Riftborn Catacombs",
                position = { x = 32351, y = 32258, z = 9 },
                locationName = "Under the old quarter",
                extraTooltip = "Placeholder dungeon entrance. Recommended level: 60-90.",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "rifts_dungeon",
                    border = { width = 2, color = "#000000" },
                    description = { text = "Level: 60-90", descBackground = true },
                    creatures = {
                        { outfit = { type = 1271 } },
                        { outfit = { type = 1323 } },
                        { outfit = { type = 1663 } }
                    }
                }
            },
            {
                POIId = 131,
                name = "Crystal Hollow",
                position = { x = 32392, y = 32250, z = 8 },
                locationName = "Eastern caverns",
                extraTooltip = "Placeholder dungeon entrance. Recommended level: 90-120.",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "frozen_knight_quest",
                    border = { width = 2, color = "#000000" },
                    description = { text = "Level: 90-120", descBackground = true },
                    creatures = {
                        { outfit = { type = 852 } },
                        { outfit = { type = 1613 } },
                        { outfit = { type = 1861 } }
                    }
                }
            }
        }
    },
    General = {
        defaultWidth = 300,
        defaultHeight = 100,
        defaultBackground = poiImagePath .. "panel",
        defaultFlagImage = poiMarkersPath .. "Anchor_0",
        nodes = {
            {
                name = "Windshore",
                POIId = 7,
                position = { x = 1040, y = 1073, z = 7 },
                tooltipInfo = {
                    background = poiBannersPath .. "windshore",
                    height = 110,
                    width = 320,
                    border = { width = 2, color = "#000000" }
                }
            },
            {
                POIId = 100,
                name = "RiftBorn Temple",
                position = { x = 32369, y = 32241, z = 7 },
                locationName = "Central RiftBorn",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "windshore",
                    height = 110,
                    width = 320,
                    border = { width = 2, color = "#000000" },
                    description = { text = "Main placeholder POI around Position: (32369, 32241, 7).", descBackground = true }
                }
            },
            {
                POIId = 104,
                name = "Riftborn Market",
                position = { x = 32373, y = 32243, z = 7 },
                locationName = "East of the temple",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "marapur",
                    height = 110,
                    width = 320,
                    border = { width = 2, color = "#000000" },
                    description = { text = "Placeholder marketplace and depot services.", descBackground = true }
                }
            },
            {
                POIId = 105,
                name = "North Gate",
                position = { x = 32369, y = 32233, z = 7 },
                locationName = "North RiftBorn",
                allowSearchByLocationName = true,
                tooltipInfo = {
                    background = poiBannersPath .. "noran",
                    height = 110,
                    width = 320,
                    border = { width = 2, color = "#000000" },
                    description = { text = "Placeholder city exit for nearby hunts.", descBackground = true }
                }
            }
        }
    }
}

-- Card presets

POI.cardPresets = {
    General = {
        template = "POITooltipCard",
        width = 300,
        height = 100,
        background = poiImagePath .. "panel",
        marker = poiMarkersPath .. "Anchor_0"
    },
    NPCs = {
        template = "POITooltipCard",
        width = 300,
        height = 100,
        background = poiImagePath .. "panel",
        marker = poiMarkersPath .. "Bag_0"
    },
    Hunts = {
        template = "POITooltipCard",
        width = 300,
        height = 100,
        background = poiImagePath .. "panel",
        marker = poiMarkersPath .. "Skull_0"
    },
    Quests = {
        template = "POITooltipCard",
        width = 360,
        height = 110,
        background = poiImagePath .. "panel",
        marker = poiMarkersPath .. "Book_0"
    },
    Dungeons = {
        template = "POITooltipCard",
        width = 360,
        height = 110,
        background = poiImagePath .. "panel",
        marker = poiMarkersPath .. "Chest_0"
    }
}

local function getLegacyDescription(node)
    if node.description then
        return node.description
    end
    if node.extraTooltip then
        return node.extraTooltip
    end
    if node.tooltipInfo and node.tooltipInfo.description then
        return node.tooltipInfo.description.text
    end
    return nil
end

local function createCardSections(node)
    local sections = {
        { type = "title", text = "$name" }
    }

    if node.locationName then
        table.insert(sections, { type = "subtitle", text = "$locationName" })
    end

    local tooltipInfo = node.tooltipInfo or {}
    if tooltipInfo.outfit then
        table.insert(sections, { type = "outfit", outfit = tooltipInfo.outfit })
    end

    local description = getLegacyDescription(node)
    if description then
        table.insert(sections, { type = "text", text = description, background = tooltipInfo.description and tooltipInfo.description.descBackground })
    end

    if tooltipInfo.creatures then
        table.insert(sections, { type = "creatures", creatures = tooltipInfo.creatures })
    end

    if tooltipInfo.rewards then
        table.insert(sections, { type = "items", items = tooltipInfo.rewards })
    end

    return sections
end

POI.categories = {}
POI.points = {}

for _, categoryName in ipairs(POI.categoryOrder) do
    local categoryData = POI.config[categoryName]
    local preset = POI.cardPresets[categoryName]
    if categoryData and preset then
        POI.categories[categoryName] = {
            marker = categoryData.defaultFlagImage or preset.marker,
            preset = categoryName
        }

        for _, node in ipairs(categoryData.nodes) do
            local tooltipInfo = node.tooltipInfo or {}
            local marker = node.marker or {}
            local search = node.search or {}
            local card = node.card or {}

            node.category = categoryName
            node.poiType = categoryName
            marker.image = marker.image or node.flagImage or categoryData.defaultFlagImage or preset.marker
            node.marker = marker

            if search.includeLocation == nil then
                search.includeLocation = node.allowSearchByLocationName
            end
            node.search = search

            node.card = {
                preset = card.preset or categoryName,
                template = card.template or preset.template,
                width = card.width or tooltipInfo.width or categoryData.defaultWidth or preset.width,
                height = card.height or tooltipInfo.height or categoryData.defaultHeight or preset.height,
                background = card.background or tooltipInfo.background or categoryData.defaultBackground or preset.background,
                backgroundOpacity = card.backgroundOpacity or tooltipInfo.backgroundOpacity or 1,
                border = card.border or tooltipInfo.border,
                sections = card.sections or createCardSections(node)
            }

            if not node.card.width then
                node.card.width = categoryData.defaultWidth or preset.width
            end

            table.insert(POI.points, node)
        end
    end
end
