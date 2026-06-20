local ESX = nil
local isTabletOpen = false
local tabletProp = nil
local weatherCache = {data = nil, time = 0}

local weatherHashMap = {}
local weatherNames = {
    'CLOUDS', 'RAIN', 'CLEAR', 'OVERCAST', 'EXTRASUNNY',
    'CLEARING', 'NEUTRAL', 'THUNDER', 'SMOG', 'FOGGY',
    'SNOWLIGHT', 'SNOW', 'BLIZZARD', 'XMAS', 'HALLOWEEN',
}

for _, name in ipairs(weatherNames) do
    weatherHashMap[GetHashKey(name)] = name
end

Citizen.CreateThread(function()
    local maxWait = 30000
    local elapsed = 0
    
    while ESX == nil and elapsed < maxWait do
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        
        if ok and obj then
            ESX = obj
            break
        end
        
        Citizen.Wait(100)
        elapsed = elapsed + 100
    end
    
    if ESX == nil then
        if Config.Debug then
            print("^1[XelBob-tab] ERROR: ESX not found after 30 seconds^7")
        end
    end
end)

local function log(msg)
    if Config.Debug then
        print("^2[XelBob-tab]^7 " .. msg)
    end
end

local function deleteProp()
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteObject(tabletProp)
    end
    tabletProp = nil
end

local function createProp(ped)
    local model = GetHashKey(Config.Prop)
    RequestModel(model)
    
    local timeout = Config.ModelLoadTimeout or 5000
    local start = GetGameTimer()
    
    while not HasModelLoaded(model) and (GetGameTimer() - start) < timeout do
        Citizen.Wait(10)
    end
    
    if not HasModelLoaded(model) then
        log("Model failed to load: " .. Config.Prop)
        SetModelAsNoLongerNeeded(model)
        return false
    end
    
    tabletProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
    
    AttachEntityToEntity(
        tabletProp, ped,
        GetPedBoneIndex(ped, Config.Bone),
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        true, true, false, true, 1, true
    )
    
    SetModelAsNoLongerNeeded(model)
    return true
end

local function buildWeatherPayload()
    local weatherKey = 'CLEAR'
    
    if Config.easytime then
        local ok, result = pcall(function()
            return exports['cd_easytime']:getWeather()
        end)
        if ok and result then
            weatherKey = tostring(result):upper()
        end
    else
        local hash = GetPrevWeatherTypeHashName()
        if hash and weatherHashMap[hash] then
            weatherKey = weatherHashMap[hash]
        end
    end
    
    if not Config.weatherIcons[weatherKey] then
        weatherKey = 'CLEAR'
    end
    
    local locale = Locales[Config.Locale] or Locales['en'] or {}
    local condition = locale[weatherKey] or weatherKey
    local icon = Config.weatherIcons[weatherKey]
    local background = Config.weatherGif[weatherKey] or ''
    
    local temp = '22'
    if Config.easytime then
        local ok2, t = pcall(function()
            return exports['cd_easytime']:getTemperature()
        end)
        if ok2 and t then
            temp = tostring(math.floor(tonumber(t) or 22))
        end
    end
    
    return {
        action = 'open',
        weather = condition,
        icon = icon,
        temp = temp,
        background = background,
        truefalse = Config.easytime and 'weather-widget' or 'weather-widgetb'
    }
end

local function getWeatherData()
    local now = GetGameTimer()
    local cacheTTL = Config.WeatherCacheTTL or 30000
    
    if weatherCache.data and (now - weatherCache.time) < cacheTTL then
        return weatherCache.data
    end
    
    weatherCache.data = buildWeatherPayload()
    weatherCache.time = now
    return weatherCache.data
end

local function openTablet()
    if isTabletOpen then return end
    isTabletOpen = true
    
    local ped = PlayerPedId()
    
    RequestAnimDict(Config.AnimDict)
    
    local animTimeout = Config.AnimLoadTimeout or 5000
    local animStart = GetGameTimer()
    
    while not HasAnimDictLoaded(Config.AnimDict) and (GetGameTimer() - animStart) < animTimeout do
        Citizen.Wait(10)
    end
    
    if not HasAnimDictLoaded(Config.AnimDict) then
        log("Animation dict failed to load: " .. Config.AnimDict)
        isTabletOpen = false
        return
    end
    
    TaskPlayAnim(ped, Config.AnimDict, 'base', 3.0, -3.0, -1, 49, 0, false, false, false)
    
    if not createProp(ped) then
        StopAnimTask(ped, Config.AnimDict, 'base', 3.0)
        isTabletOpen = false
        return
    end
    
    SetNuiFocus(true, true)
    
    ESX.TriggerServerCallback('xelbob-tab:getJobApps', function(result)
        local payload = getWeatherData()
        payload.apps = result.apps or Config.DefaultSites
        payload.customApps = result.customApps or {}
        SendNUIMessage(payload)
    end)
end

local function closeTablet()
    if not isTabletOpen then return end
    isTabletOpen = false
    
    local ped = PlayerPedId()
    
    StopAnimTask(ped, Config.AnimDict, 'base', 3.0)
    deleteProp()
    
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
    closeTablet()
    cb('ok')
end)

if Config.Command then
    RegisterCommand(Config.Command, function()
        Citizen.CreateThread(function()
            if isTabletOpen then
                closeTablet()
            else
                openTablet()
            end
        end)
    end, false)
    
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, Config.CommandDescription)
end

if Config.Item then
    RegisterNetEvent('xelbob-tab:client:useItem')
    AddEventHandler('xelbob-tab:client:useItem', function()
        Citizen.CreateThread(function()
            if isTabletOpen then
                closeTablet()
            else
                openTablet()
            end
        end)
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if isTabletOpen then
        closeTablet()
    end
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteObject(tabletProp)
    end
end)
