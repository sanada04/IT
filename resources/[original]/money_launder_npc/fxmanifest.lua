fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'custom'
description 'Money launder NPC'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_inventory',
    'qb-target'
}
