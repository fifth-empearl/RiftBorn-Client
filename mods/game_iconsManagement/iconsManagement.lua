local managedSettings = nil
local previousSettings = nil

local dynamicFillSettings = {
    { get = "getDynamicFillSpacingX", set = "setDynamicFillSpacingX", value = 12 },
    { get = "getDynamicFillSpacingY", set = "setDynamicFillSpacingY", value = 12 },
    { get = "getDynamicFillIconsPerRow", set = "setDynamicFillIconsPerRow", value = 3 },

    -- Base X/Y are the first grid-slot offsets from the creature info background.
    -- They affect dynamic-fill icons only; fixed icons use their own X/Y offsets.
    { get = "getDynamicFillBaseX", set = "setDynamicFillBaseX", value = 13.5 },
    { get = "getDynamicFillBaseY", set = "setDynamicFillBaseY", value = 8.0 }
}

local iconLayoutSettings = {
    {
        dynamicGetter = "isSkullDynamicFill", dynamicSetter = "setSkullDynamicFill", dynamic = true,
        xGetter = "getSkullXOffset", xSetter = "setSkullXOffset", x = 37,
        yGetter = "getSkullYOffset", ySetter = "setSkullYOffset", y = 11
    },
    {
        dynamicGetter = "isMonsterSkullDynamicFill", dynamicSetter = "setMonsterSkullDynamicFill", dynamic = false,
        xGetter = "getMonsterSkullXOffset", xSetter = "setMonsterSkullXOffset", x = 10,
        yGetter = "getMonsterSkullYOffset", ySetter = "setMonsterSkullYOffset", y = -30
    },
    {
        dynamicGetter = "isShieldDynamicFill", dynamicSetter = "setShieldDynamicFill", dynamic = true,
        xGetter = "getShieldXOffset", xSetter = "setShieldXOffset", x = -17.5,
        yGetter = "getShieldYOffset", ySetter = "setShieldYOffset", y = 10
    },
    {
        dynamicGetter = "isEmblemDynamicFill", dynamicSetter = "setEmblemDynamicFill", dynamic = true,
        xGetter = "getEmblemXOffset", xSetter = "setEmblemXOffset", x = -17.5,
        yGetter = "getEmblemYOffset", ySetter = "setEmblemYOffset", y = -3
    },
    {
        dynamicGetter = "isCreatureTypeDynamicFill", dynamicSetter = "setCreatureTypeDynamicFill", dynamic = true,
        xGetter = "getCreatureTypeXOffset", xSetter = "setCreatureTypeXOffset", x = 1.5,
        yGetter = "getCreatureTypeYOffset", ySetter = "setCreatureTypeYOffset", y = 1
    },
    {
        dynamicGetter = "isNpcIconDynamicFill", dynamicSetter = "setNpcIconDynamicFill", dynamic = true,
        xGetter = "getNpcIconXOffset", xSetter = "setNpcIconXOffset", x = 28.5,
        yGetter = "getNpcIconYOffset", ySetter = "setNpcIconYOffset", y = 4
    },
    {
        dynamicGetter = "isHonorDynamicFill", dynamicSetter = "setHonorDynamicFill", dynamic = false,
        xGetter = "getHonorXOffset", xSetter = "setHonorXOffset", x = 37.0,
        yGetter = "getHonorYOffset", ySetter = "setHonorYOffset", y = -12
    }
}

local function buildManagedSettings()
    local settings = {}

    for _, setting in ipairs(dynamicFillSettings) do
        table.insert(settings, setting)
    end

    for _, icon in ipairs(iconLayoutSettings) do
        table.insert(settings, { get = icon.dynamicGetter, set = icon.dynamicSetter, value = icon.dynamic })
        table.insert(settings, { get = icon.xGetter, set = icon.xSetter, value = icon.x })
        table.insert(settings, { get = icon.yGetter, set = icon.ySetter, value = icon.y })
    end

    return settings
end

local function readSettings(settings)
    local values = {}

    for _, setting in ipairs(settings) do
        values[setting.set] = g_game[setting.get]()
    end

    return values
end

local function applySettings(settings)
    for _, setting in ipairs(settings) do
        g_game[setting.set](setting.value)
    end
end

local function restoreSettings(settings, values)
    if not values then
        return
    end

    for _, setting in ipairs(settings) do
        local value = values[setting.set]
        if value ~= nil then
            g_game[setting.set](value)
        end
    end
end

function init()
    managedSettings = buildManagedSettings()
    previousSettings = readSettings(managedSettings)
    applySettings(managedSettings)
end

function terminate()
    restoreSettings(managedSettings or buildManagedSettings(), previousSettings)
    managedSettings = nil
    previousSettings = nil
end
