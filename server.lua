local ESX = nil
local customApps = {}

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
        print("^1[XelBob-tab] ERROR: ESX not found after 30 seconds^7")
        return
    end
    
    if Config.Item then
        ESX.RegisterUsableItem(Config.Item, function(source)
            TriggerClientEvent('xelbob-tab:client:useItem', source)
        end)
    end
    
    ESX.RegisterServerCallback('xelbob-tab:getJobApps', function(source, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        
        if not xPlayer then
            cb({apps = Config.DefaultSites, customApps = customApps})
            return
        end
        
        local job = xPlayer.getJob().name
        local filteredApps = filterAppsByJob(job)
        
        cb({apps = filteredApps, customApps = customApps})
    end)
    
    ESX.RegisterServerCallback('xelbob-tab:saveApp', function(source, data, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        
        if not xPlayer then
            cb({success = false, message = 'Player not found'})
            return
        end
        
        if validateAppData(data) then
            table.insert(customApps, data)
            saveAppsToFile(customApps)
            cb({success = true, message = 'App saved successfully'})
        else
            cb({success = false, message = 'Invalid app data'})
        end
    end)
    
    ESX.RegisterServerCallback('xelbob-tab:deleteApp', function(source, appName, cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        
        if not xPlayer then
            cb({success = false, message = 'Player not found'})
            return
        end
        
        for i, app in ipairs(customApps) do
            if app.name == appName then
                table.remove(customApps, i)
                saveAppsToFile(customApps)
                cb({success = true, message = 'App deleted successfully'})
                return
            end
        end
        
        cb({success = false, message = 'App not found'})
    end)
    
    validateConfiguration()
    loadAppsFromFile()
end)

function filterAppsByJob(job)
    local apps = {}
    
    for _, app in ipairs(Config.DefaultSites) do
        table.insert(apps, app)
    end
    
    if Config.jobSites then
        for _, jobSite in ipairs(Config.jobSites) do
            if jobSite.job_name == job then
                for _, app in ipairs(jobSite.sites) do
                    table.insert(apps, app)
                end
            end
        end
    end
    
    return apps
end

function validateAppData(data)
    if not data.name or data.name == '' then
        return false
    end
    
    if not data.icon or data.icon == '' then
        return false
    end
    
    if not data.url or data.url == '' then
        return false
    end
    
    if not isValidUrl(data.url) then
        return false
    end
    
    return true
end

function isValidUrl(url)
    if string.len(url) > 2048 then
        return false
    end
    
    if string.match(url, "^https?://") then
        return true
    end
    
    return false
end

function validateConfiguration()
    local errors = {}
    
    if not Config.Command and not Config.Item then
        table.insert(errors, "No access method (command or item) enabled")
    end
    
    if Config.easytime and GetResourceState('cd_easytime') ~= 'started' then
        Config.easytime = false
        print("^3[XelBob-tab] WARNING: cd_easytime not found, disabling weather^7")
    end
    
    if #errors > 0 then
        print("^1[XelBob-tab] Configuration Errors:^7")
        for _, err in ipairs(errors) do
            print("  - " .. err)
        end
    end
end

function loadAppsFromFile()
    local dataPath = 'resources/' .. GetCurrentResourceName() .. '/data/apps_data.json'
    
    if not io.open(dataPath, 'r') then
        customApps = {}
        return
    end
    
    local file = io.open(dataPath, 'r')
    local content = file:read('*a')
    file:close()
    
    local ok, decoded = pcall(json.decode, content)
    
    if ok and decoded then
        customApps = decoded
    else
        customApps = {}
    end
end

function saveAppsToFile(apps)
    local dataDir = 'resources/' .. GetCurrentResourceName() .. '/data'
    local dataPath = dataDir .. '/apps_data.json'
    
    if not io.open(dataDir, 'r') then
        os.execute('mkdir "' .. dataDir .. '"')
    end
    
    local file = io.open(dataPath, 'w')
    
    if file then
        file:write(json.encode(apps))
        file:close()
    end
end

RegisterNetEvent('xelbob-tab:server:close')
AddEventHandler('xelbob-tab:server:close', function()
end)
