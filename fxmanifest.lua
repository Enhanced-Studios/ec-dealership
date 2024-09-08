fx_version 'cerulean'
games { 'gta5' }
author 'tacothedev'
description 'Dealership'
version '1.0.0'
lua54 'yes'

ui_page 'ui/ui.html'

files {
    'ui/ui.html',
    'ui/index.js',
}

shared_script 'config.lua'

client_scripts {
    'client.lua',
}

server_scripts {
 --   '@vrp/lib/utils.lua',
    '@oxmysql/lib/MySQL.lua', -- change if you dont use OX
    'server.lua'
}