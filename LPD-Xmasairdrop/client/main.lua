local activePresents = {}
local sleighVehicle = nil
local sleighPed = nil

-- Debug print function
local function DebugPrint(msg)
    if Config.Debug then
        print('[Christmas Airdrop Client] ' .. msg)
    end
end

-- Play sound function
local function PlaySound(soundName, volume)
    if not Config.PlaySounds then return end
    
    volume = volume or 0.5
    SendNUIMessage({
        type = 'playSound',
        sound = soundName,
        volume = volume
    })
end

-- Load model
local function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    return HasModelLoaded(hash)
end

-- Create and fly the sleigh
local function CreateSleigh()
    if sleighVehicle then return end
    
    DebugPrint('Creating sleigh')
    
    if not LoadModel(Config.SleighModel) then
        DebugPrint('Failed to load sleigh model')
        return
    end
    
    -- Get start position
    local startPos = Config.SleighRoute[1]
    
    -- Create the sleigh vehicle
    sleighVehicle = CreateVehicle(GetHashKey(Config.SleighModel), startPos.x, startPos.y, startPos.z, 0.0, false, false)
    
    if not DoesEntityExist(sleighVehicle) then
        DebugPrint('Failed to create sleigh vehicle')
        return
    end
    
    -- Set vehicle properties
    SetEntityInvincible(sleighVehicle, true)
    SetEntityCollision(sleighVehicle, false, false)
    FreezeEntityPosition(sleighVehicle, false)
    SetVehicleEngineOn(sleighVehicle, true, true, false)
    
    -- Create Santa driver
    if LoadModel('s_m_m_pilot_01') then
        sleighPed = CreatePedInsideVehicle(sleighVehicle, 4, GetHashKey('s_m_m_pilot_01'), -1, true, false)
        SetEntityInvincible(sleighPed, true)
        SetBlockingOfNonTemporaryEvents(sleighPed, true)
    end
    
    -- Fly the sleigh along the route
    CreateThread(function()
        for i = 2, #Config.SleighRoute do
            local targetPos = Config.SleighRoute[i]
            TaskVehicleDriveToCoord(sleighPed, sleighVehicle, targetPos.x, targetPos.y, targetPos.z, Config.SleighSpeed, 0, GetHashKey(Config.SleighModel), 262144, 15.0, -1.0)
            
            -- Wait until close to waypoint
            while #(GetEntityCoords(sleighVehicle) - targetPos) > 100.0 do
                Wait(1000)
                if not DoesEntityExist(sleighVehicle) then break end
            end
        end
        
        -- Delete sleigh after route
        Wait(5000)
        if DoesEntityExist(sleighVehicle) then
            DeleteEntity(sleighVehicle)
        end
        if DoesEntityExist(sleighPed) then
            DeleteEntity(sleighPed)
        end
        sleighVehicle = nil
        sleighPed = nil
        DebugPrint('Sleigh deleted')
    end)
end

-- Drop a present
local function DropPresent(loot)
    -- Get a random drop location (near player or random on map)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Random offset from player (within 500m radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.random(100, 500)
    local dropX = playerCoords.x + math.cos(angle) * distance
    local dropY = playerCoords.y + math.sin(angle) * distance
    
    -- Get ground Z coordinate
    local foundGround, groundZ = GetGroundZFor_3dCoord(dropX, dropY, 1000.0, false)
    if not foundGround then
        groundZ = playerCoords.z
    end
    
    -- Start from high in the sky
    local startZ = groundZ + 200.0
    
    DebugPrint('Dropping present at ' .. dropX .. ', ' .. dropY .. ', ' .. groundZ)
    
    -- Load present model
    if not LoadModel(Config.PresentProp) then
        DebugPrint('Failed to load present model')
        return
    end
    
    -- Create present object (spawn multiple to simulate larger size)
    local presents = {}
    local mainPresent = CreateObject(GetHashKey(Config.PresentProp), dropX, dropY, startZ, false, false, false)
    
    if not DoesEntityExist(mainPresent) then
        DebugPrint('Failed to create present object')
        return
    end
    
    table.insert(presents, mainPresent)
    
    -- Create additional presents around it for a "larger" effect
    if Config.PresentScale > 1 then
        local offsets = {
            {x = 1.0, y = 0.0, z = 0.0},
            {x = -1.0, y = 0.0, z = 0.0},
            {x = 0.0, y = 1.0, z = 0.0},
            {x = 0.0, y = -1.0, z = 0.0},
            {x = 0.0, y = 0.0, z = 1.0}
        }
        
        for _, offset in ipairs(offsets) do
            local extraPresent = CreateObject(GetHashKey(Config.PresentProp), 
                dropX + offset.x, 
                dropY + offset.y, 
                startZ + offset.z, 
                false, false, false)
            table.insert(presents, extraPresent)
        end
    end
    
    -- Generate unique ID for this present
    local presentId = 'present_' .. math.random(10000, 99999) .. '_' .. GetGameTimer()
    
    -- Set present properties for all objects
    for _, present in ipairs(presents) do
        SetEntityCollision(present, false, false)
        FreezeEntityPosition(present, true)
        SetEntityAlpha(present, 255, false)
    end
    
    -- Store present data
    activePresents[presentId] = {
        objects = presents,  -- Changed from 'object' to 'objects' array
        coords = vector3(dropX, dropY, groundZ),
        loot = loot,
        blip = nil
    }
    
    -- Animate the fall
    CreateThread(function()
        local currentZ = startZ
        local targetZ = groundZ + 1.0
        
        while currentZ > targetZ do
            currentZ = currentZ - Config.PresentFallSpeed
            if currentZ < targetZ then
                currentZ = targetZ
            end
            
            -- Move all present objects together
            for i, present in ipairs(presents) do
                local offset = {x = 0, y = 0, z = 0}
                if i > 1 then
                    -- Apply offsets to extra presents
                    local offsets = {
                        {x = 1.0, y = 0.0, z = 0.0},
                        {x = -1.0, y = 0.0, z = 0.0},
                        {x = 0.0, y = 1.0, z = 0.0},
                        {x = 0.0, y = -1.0, z = 0.0},
                        {x = 0.0, y = 0.0, z = 1.0}
                    }
                    offset = offsets[i - 1] or offset
                end
                SetEntityCoords(present, dropX + offset.x, dropY + offset.y, currentZ + offset.z, false, false, false, false)
            end
            Wait(50)
        end
        
        -- Present has landed - freeze all objects
        for _, present in ipairs(presents) do
            FreezeEntityPosition(present, true)
            SetEntityCollision(present, true, true)
        end
        
        -- Create blip
        local blip = AddBlipForCoord(dropX, dropY, groundZ)
        SetBlipSprite(blip, Config.PresentBlip.sprite)
        SetBlipColour(blip, Config.PresentBlip.color)
        SetBlipScale(blip, Config.PresentBlip.scale)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.PresentBlip.label)
        EndTextCommandSetBlipName(blip)
        
        activePresents[presentId].blip = blip
        
        -- Register present on server
        TriggerServerEvent('xmas_airdrop:server:registerPresent', presentId, loot)
        
        -- Notify nearby players
        lib.notify(Config.Notifications.present_dropped)
        
        DebugPrint('Present ' .. presentId .. ' landed')
    end)
end

-- Remove a present
local function RemovePresent(presentId)
    local present = activePresents[presentId]
    if present then
        -- Delete all present objects
        if present.objects then
            for _, obj in ipairs(present.objects) do
                if DoesEntityExist(obj) then
                    DeleteEntity(obj)
                end
            end
        end
        if present.blip then
            RemoveBlip(present.blip)
        end
        activePresents[presentId] = nil
        DebugPrint('Removed present ' .. presentId)
    end
end

-- Open present interaction
local function OpenPresent(presentId)
    local present = activePresents[presentId]
    if not present then return end
    
    -- Show progress bar
    if lib.progressCircle({
        duration = Config.OpenTime,
        label = 'Opening Present...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer'
        }
    }) then
        -- Play unwrap sound
        PlaySound(Config.Sounds.present_open, 0.5)
        
        -- Request loot from server
        local success = lib.callback.await('xmas_airdrop:server:openPresent', false, presentId)
        
        if success then
            -- Remove the present
            RemovePresent(presentId)
        else
            lib.notify({
                title = 'Error',
                description = 'Could not open present',
                type = 'error'
            })
        end
    end
end

-- Check for nearby presents
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for presentId, present in pairs(activePresents) do
            local distance = #(playerCoords - present.coords)
            
            if distance < Config.InteractionDistance then
                sleep = 0
                
                -- Draw 3D text
                lib.showTextUI('[E] Open Christmas Present', {
                    position = "top-center",
                    icon = 'gift',
                })
                
                -- Check for key press
                if IsControlJustReleased(0, 38) then -- E key
                    lib.hideTextUI()
                    OpenPresent(presentId)
                end
            elseif distance < Config.InteractionDistance + 1.0 then
                lib.hideTextUI()
            end
        end
        
        Wait(sleep)
    end
end)

-- Network events
RegisterNetEvent('xmas_airdrop:client:notifyAll', function(notification)
    lib.notify(notification)
end)

RegisterNetEvent('xmas_airdrop:client:startSleigh', function()
    DebugPrint('Starting sleigh flight')
    PlaySound(Config.Sounds.sleigh_horn, 0.3)
    CreateSleigh()
end)

RegisterNetEvent('xmas_airdrop:client:dropPresent', function(loot)
    DebugPrint('Dropping present')
    DropPresent(loot)
end)

RegisterNetEvent('xmas_airdrop:client:removePresent', function(presentId)
    RemovePresent(presentId)
end)

-- Handle time check request from server
RegisterNetEvent('xmas_airdrop:client:checkTime', function()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    TriggerServerEvent('xmas_airdrop:server:timeCheck', hour, minute)
end)

-- Handle manual time check command
RegisterNetEvent('xmas_airdrop:client:getTime', function()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    lib.notify({
        title = 'Time Check',
        description = 'Current time: ' .. hour .. ':' .. string.format('%02d', minute),
        type = 'info'
    })
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Delete sleigh
    if DoesEntityExist(sleighVehicle) then
        DeleteEntity(sleighVehicle)
    end
    if DoesEntityExist(sleighPed) then
        DeleteEntity(sleighPed)
    end
    
    -- Delete all presents
    for presentId, present in pairs(activePresents) do
        if present.objects then
            for _, obj in ipairs(present.objects) do
                if DoesEntityExist(obj) then
                    DeleteEntity(obj)
                end
            end
        end
        if present.blip then
            RemoveBlip(present.blip)
        end
    end
    
    -- Hide any text UI
    lib.hideTextUI()
end)