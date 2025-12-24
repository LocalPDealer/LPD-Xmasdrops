fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Local'
description 'Christmas Airdrops'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

files {
    'html/index.html',
    'html/sounds/*.ogg'
}

ui_page 'html/index.html'

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory'
}