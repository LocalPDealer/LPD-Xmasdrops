Config = {}

-- General Settings
Config.Debug = false -- Enable debug prints
Config.CheckInterval = 60000 -- Check time every 60 seconds (1 minute)
Config.TargetHour = 0 -- Midnight (0-23)
Config.TargetMinute = 0 -- At exactly midnight

-- Present Settings
Config.PresentProp = 'bzzz_xmas23_convert_tree_gift' -- Present prop model
Config.PresentScale = 4.0 -- Scale multiplier (4x size)
Config.PresentFallSpeed = 2.0 -- How fast presents fall
Config.MinimumPlayerCount = 0 -- Minimum players online for event (0 = always run)

-- Sleigh Settings
Config.SleighModel = 'velum2' -- Helicopter model to use as sleigh
Config.SleighSpeed = 50.0 -- Speed of the sleigh
Config.SleighHeight = 150.0 -- Height above ground
Config.SleighDuration = 60000 -- How long sleigh flies (milliseconds)

-- Drop Settings
Config.NumberOfPresents = 1 -- How many presents to drop
Config.DropInterval = 5000 -- Time between drops in milliseconds
Config.PresentLifetime = 600000 -- How long presents stay (10 minutes)

-- Interaction Settings
Config.InteractionDistance = 3.0 -- Distance to interact with present
Config.OpenTime = 5000 -- Time to open present (milliseconds)

-- Notification Settings
Config.Notifications = {
    santa_coming = {
        title = '🎅 Santa Alert!',
        description = 'Santa Claus is flying over Los Santos! Look for falling presents!',
        type = 'success',
        duration = 10000
    },
    present_dropped = {
        title = '🎁 Present Dropped!',
        description = 'A giant Christmas present has landed nearby!',
        type = 'info',
        duration = 8000
    },
    opening_present = {
        title = '🎁 Opening Present',
        description = 'Unwrapping your gift...',
        type = 'info',
        duration = 5000
    },
    present_opened = {
        title = '🎁 Present Opened!',
        description = 'You received Christmas gifts!',
        type = 'success',
        duration = 5000
    }
}

-- Loot Pool Configuration
-- Each item has a weight (higher = more common) and quantity range
Config.LootPool = {
    -- Weapons (Rare)
    {item = 'bomb_c4', minAmount = 1, maxAmount = 1, weight = 5},
    {item = 'blue_keycard', minAmount = 1, maxAmount = 1, weight = 3},
    {item = 'large_backpack', minAmount = 1, maxAmount = 1, weight = 2},
    
    -- Ammo (Common)
    {item = 'ammo-9', minAmount = 10, maxAmount = 60, weight = 15},
    {item = 'ammo-45', minAmount = 10, maxAmount = 60, weight = 12},
    {item = 'ammo-44', minAmount = 10, maxAmount = 20, weight = 10},
    
    -- Money (Uncommon)
    {item = 'money', minAmount = 4500, maxAmount = 8000, weight = 20},
    {item = 'black_money', minAmount = 2000, maxAmount = 5000, weight = 8},
    
    -- Valuable Items (Rare)
    {item = 'diamond_necklace', minAmount = 1, maxAmount = 5, weight = 4},
    {item = 'thermite', minAmount = 1, maxAmount = 3, weight = 5},
    {item = 'rolex', minAmount = 1, maxAmount = 2, weight = 6},
    
    -- Consumables (Common)
    {item = 'gift_box', minAmount = 1, maxAmount = 4, weight = 25},
    {item = 'small_gift_box', minAmount = 2, maxAmount = 5, weight = 25},
    {item = 'gift_box', minAmount = 1, maxAmount = 5, weight = 20},
    {item = 'small_gift_box', minAmount = 2, maxAmount = 5, weight = 15},
    
    -- Special Items (Very Rare)
    {item = 'stancerkit', minAmount = 1, maxAmount = 1, weight = 3},
    {item = 'small_gift_box', minAmount = 1, maxAmount = 16, weight = 3},
    {item = 'christmas_tree', minAmount = 1, maxAmount = 1, weight = 7},
    
    -- Christmas Special Items (Uncommon)
    {item = 'standard_armour', minAmount = 1, maxAmount = 4, weight = 18},
    {item = 'charcoal', minAmount = 30, maxAmount = 60, weight = 18},
}

-- How many different items to give per present
Config.MinItemsPerPresent = 1
Config.MaxItemsPerPresent = 2

-- Sleigh Route (waypoints for sleigh to fly through)
-- The sleigh will fly from first point to last point
Config.SleighRoute = {
    vector3(-1000.0, -1000.0, Config.SleighHeight),
    vector3(0.0, 0.0, Config.SleighHeight),
    vector3(1000.0, 1000.0, Config.SleighHeight),
}

-- Blip Settings
Config.PresentBlip = {
    sprite = 478, -- Gift icon
    color = 1, -- Red
    scale = 1.2,
    label = '🎁 Christmas Present'
}

-- Sound Settings (optional - requires sound files)
Config.PlaySounds = true -- Set to true once you add sound files
Config.Sounds = {
    sleigh_horn = 'sleigh_bells',
    present_open = 'unwrap_present'
}