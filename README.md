# 🎅 Christmas Airdrop Script for FiveM (QBX)

A fully synchronized Christmas event system where Santa flies across the map in a sleigh, dropping giant presents filled with randomized loot for players to collect!

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Ready-green.svg)
![QBX](https://img.shields.io/badge/Framework-QBX-red.svg)

## ✨ Features

- 🎄 **Automatic Midnight Trigger** - Event automatically starts at in-game midnight (configurable)
- 🛷 **Santa's Sleigh** - A helicopter flies across the map following a customizable route
- 🎁 **Giant Synced Presents** - Large present props (PLEASE SET OWN PROP)
- 🎲 **Randomized Loot** - Weighted loot pool system ensures different rewards every time
- 📍 **Map Blips** - Present locations marked on the map
- 🔔 **Sound Effects** - Optional sleigh bells and unwrapping sounds (requires sound files)
- ⏱️ **Progress Bar** - Animated opening sequence using ox_lib
- 🧹 **Auto-Cleanup** - Presents automatically despawn after configurable time
- 🎮 **Admin Commands** - Manual event triggering and time checking

## 📋 Dependencies

This script requires the following resources to be installed and running:

- **[qbx_core](https://github.com/Qbox-project/qbx_core)** - QBX Core Framework
- **[ox_lib](https://github.com/overextended/ox_lib)** - Overextended Library (UI, notifications, callbacks)
- **[ox_inventory](https://github.com/overextended/ox_inventory)** - Overextended Inventory System

## 📦 Installation

1. **Download** the latest release or clone this repository
2. **Extract** the folder to your server's `resources` directory
3. **Rename** the folder to `LPD-Xmasairdrop` (or your preferred name)
4. **Move** The Sleigh folder to where your vehicles are streamed (Optional)
5. **Add** the following to your `server.cfg`:
   ```cfg
   ensure LPD-Xmasairdrop
   ```
6. **Configure** the script in `config.lua` (see Configuration section below)
7. **Restart** your server or use `/refresh` and `/start LPD-Xmasairdrop`

## ⚙️ Configuration

### Basic Settings

Edit `config.lua` to customize the script:

```lua
-- When the event triggers
Config.TargetHour = 0          -- Hour (0-23, 0 = midnight)
Config.TargetMinute = 0        -- Minute (0-59)

-- Present settings
Config.NumberOfPresents = 3    -- How many presents drop per event
Config.DropInterval = 5000     -- Time between drops (milliseconds)
Config.PresentLifetime = 600000 -- How long presents stay (10 minutes)
Config.PresentScale = 4.0      -- Size multiplier (creates cluster effect)

-- Minimum players needed for event
Config.MinimumPlayerCount = 0  -- Set to 0 to always run
```

### Drop Zone Configuration

Customize where presents can land:

```lua
Config.DropZone = {
    center = vector3(0.0, 0.0, 0.0),  -- Center point (map coordinates)
    minRadius = 500.0,                 -- Minimum distance from center
    maxRadius = 2000.0                 -- Maximum distance from center
}
```

**Example locations:**
- Los Santos City Center: `vector3(200.0, -900.0, 30.0)`
- Sandy Shores: `vector3(1850.0, 3700.0, 30.0)`
- Paleto Bay: `vector3(-100.0, 6400.0, 30.0)`

### Loot Pool Configuration

Customize what items players can receive. Each item has:
- `item` - Item spawn name
- `minAmount` / `maxAmount` - Quantity range
- `weight` - Drop chance (higher = more common)

```lua
Config.LootPool = {
    {item = 'weapon_pistol', minAmount = 1, maxAmount = 1, weight = 5},
    {item = 'money', minAmount = 5000, maxAmount = 25000, weight = 20},
    -- Add your custom items here
}
```

### Sleigh Route

Customize the flight path:

```lua
Config.SleighRoute = {
    vector3(-1000.0, -1000.0, 150.0),  -- Start point
    vector3(0.0, 0.0, 150.0),          -- Middle waypoint
    vector3(1000.0, 1000.0, 150.0),    -- End point
}

## 🎮 Commands

### Player Commands
- `/checktime` - Check the current in-game time

### Admin Commands
- `/santaevent` - Manually trigger the Christmas event (requires admin permission)

## 🔧 Customization

### Change Present Prop

To use a different present model:

```lua
Config.PresentProp = 'prop_xmas_present_01'  -- Change to any valid prop
```

### Change Sleigh Model

To use a different vehicle as the sleigh:

```lua
Config.SleighModel = 'volatus'  -- Any helicopter or aircraft model
Config.SleighSpeed = 50.0       -- Adjust flight speed
```

### Adjust Interaction

```lua
Config.InteractionDistance = 3.0  -- How close players must be
Config.OpenTime = 5000            -- Time to open present (ms)
```

## 🐛 Troubleshooting

### Event not triggering
- Check in-game time with `/checktime`
- Ensure `Config.MinimumPlayerCount` requirement is met
- Check server console for debug messages (enable with `Config.Debug = true`)

### Presents not appearing
- Verify `Config.PresentProp` model exists on your server
- Check F8 client console for errors
- Ensure ox_lib is properly installed

### Loot not given
- Verify item names match your `ox_inventory` items exactly
- Check server console for errors
- Ensure qbx_core is running properly

### Sounds not playing
- Verify sound files are in `.ogg` format
- Check file names match config exactly (`sleigh_bells.ogg`, `unwrap_present.ogg`)
- Ensure `html/index.html` exists
- Set `Config.PlaySounds = true`

## 📝 Debug Mode

Enable detailed console logging:

```lua
Config.Debug = true
```

This will print detailed information about:
- Event triggers
- Present creation
- Loot generation
- Player interactions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 💖 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Enable debug mode for detailed logs

## 🎄 Credits

- Script created for the FiveM/QBX community
- Uses ox_lib by Overextended
- Compatible with QBX Core Framework

## 🎁 Changelog

### Version 1.0.0 (Initial Release)
- ✅ Automatic midnight event trigger
- ✅ Flying sleigh with customizable route
- ✅ Randomized weighted loot system
- ✅ Progress bar interactions
- ✅ Map blips for presents
- ✅ Optional sound effects
- ✅ Admin commands
- ✅ Configurable drop zones
- ✅ Auto-cleanup system

---

**Enjoy your Christmas events! 🎅🎄🎁**
