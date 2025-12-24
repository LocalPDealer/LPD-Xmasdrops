local eventTriggeredToday = false
local activePresents = {}

-- Get QBCore object (QBX uses a different method)
local QBX = exports.qbx_core

-- Debug print function
local function DebugPrint(msg)
    if Config.Debug then
        print('[Christmas Airdrop] ' .. msg)
    end
end

-- Check if enough players are online
local function HasEnoughPlayers()
    local playerCount = #GetPlayers()
    return playerCount >= Config.MinimumPlayerCount
end

-- Calculate total weight of loot pool
local function CalculateTotalWeight()
    local total = 0
    for _, item in ipairs(Config.LootPool) do
        total = total + item.weight
    end
    return total
end

-- Get random item from loot pool based on weights
local function GetRandomLoot()
    local totalWeight = CalculateTotalWeight()
    local random = math.random() * totalWeight
    local currentWeight = 0
    
    for _, item in ipairs(Config.LootPool) do
        currentWeight = currentWeight + item.weight
        if random <= currentWeight then
            local amount = math.random(item.minAmount, item.maxAmount)
            return {item = item.item, amount = amount}
        end
    end
    
    -- Fallback
    return {item = Config.LootPool[1].item, amount = Config.LootPool[1].minAmount}
end

-- Generate loot for a present
local function GeneratePresentLoot()
    local loot = {}
    local itemCount = math.random(Config.MinItemsPerPresent, Config.MaxItemsPerPresent)
    local usedItems = {}
    
    for i = 1, itemCount do
        local attempts = 0
        local lootItem = nil
        
        -- Try to get unique items (max 50 attempts to avoid infinite loop)
        repeat
            lootItem = GetRandomLoot()
            attempts = attempts + 1
        until not usedItems[lootItem.item] or attempts >= 50
        
        usedItems[lootItem.item] = true
        table.insert(loot, lootItem)
    end
    
    DebugPrint('Generated loot with ' .. #loot .. ' items')
    return loot
end

-- Start the Christmas event
local function StartChristmasEvent()
    if not HasEnoughPlayers() then
        DebugPrint('Not enough players online for event')
        return
    end
    
    DebugPrint('Starting Christmas event!')
    
    -- Notify all players
    TriggerClientEvent('xmas_airdrop:client:notifyAll', -1, Config.Notifications.santa_coming)
    
    -- Start sleigh flight
    TriggerClientEvent('xmas_airdrop:client:startSleigh', -1)
    
    -- Schedule present drops
    for i = 1, Config.NumberOfPresents do
        SetTimeout(i * Config.DropInterval, function()
            local loot = GeneratePresentLoot()
            TriggerClientEvent('xmas_airdrop:client:dropPresent', -1, loot)
        end)
    end
end

-- Check if it's time for the event
local function CheckEventTime()
    -- Request time from a client (any player)
    local players = GetPlayers()
    if #players == 0 then return end
    
    -- Get time from first available player
    local source = tonumber(players[1])
    if source then
        TriggerClientEvent('xmas_airdrop:client:checkTime', source)
    end
end

-- Receive time check from client
RegisterNetEvent('xmas_airdrop:server:timeCheck', function(hour, minute)
    if hour == Config.TargetHour and minute == Config.TargetMinute then
        if not eventTriggeredToday then
            eventTriggeredToday = true
            StartChristmasEvent()
            DebugPrint('Event triggered at ' .. hour .. ':' .. minute)
            
            -- Reset flag after 2 minutes to prevent multiple triggers
            SetTimeout(120000, function()
                eventTriggeredToday = false
            end)
        end
    end
end)

-- Start time checker
CreateThread(function()
    while true do
        CheckEventTime()
        Wait(Config.CheckInterval)
    end
end)

-- Handle present opening
lib.callback.register('xmas_airdrop:server:openPresent', function(source, presentId)
    DebugPrint('Player ' .. source .. ' opening present ' .. presentId)
    
    if not activePresents[presentId] then
        DebugPrint('Present ' .. presentId .. ' not found or already opened')
        return false
    end
    
    local loot = activePresents[presentId]
    local Player = exports.qbx_core:GetPlayer(source)
    
    if not Player then
        return false
    end
    
    -- Give items to player
    for _, item in ipairs(loot) do
        if item.item == 'money' then
            exports.qbx_core:AddMoney(source, 'cash', item.amount)
        elseif item.item == 'black_money' then
            exports.qbx_core:AddMoney(source, 'black_money', item.amount)
        else
            exports.ox_inventory:AddItem(source, item.item, item.amount)
        end
        DebugPrint('Gave ' .. item.amount .. 'x ' .. item.item .. ' to player ' .. source)
    end
    
    -- Remove present from active list
    activePresents[presentId] = nil
    
    -- Notify player
    TriggerClientEvent('ox_lib:notify', source, Config.Notifications.present_opened)
    
    return true
end)

-- Register a new present
RegisterNetEvent('xmas_airdrop:server:registerPresent', function(presentId, loot)
    activePresents[presentId] = loot
    DebugPrint('Registered present ' .. presentId .. ' with ' .. #loot .. ' items')
    
    -- Remove present after lifetime expires
    SetTimeout(Config.PresentLifetime, function()
        if activePresents[presentId] then
            activePresents[presentId] = nil
            TriggerClientEvent('xmas_airdrop:client:removePresent', -1, presentId)
            DebugPrint('Present ' .. presentId .. ' expired')
        end
    end)
end)

-- Admin command to trigger event manually (for testing)
lib.addCommand('santaevent', {
    help = 'Manually trigger the Christmas event (Admin only)',
    restricted = 'group.admin'
}, function(source)
    StartChristmasEvent()
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Admin',
        description = 'Christmas event manually triggered',
        type = 'success'
    })
end)

-- Debug command to check time
lib.addCommand('checktime', {
    help = 'Check current in-game time',
    restricted = false
}, function(source)
    TriggerClientEvent('xmas_airdrop:client:getTime', source)
end)