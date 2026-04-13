fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'it_drugs'
description 'Simple drug gather/process/sell script for QBCore'
author 'IT Server'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_inventory'
}
