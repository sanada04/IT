fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'custom'
description 'Humane Labs raid (quest + enemy spawn test)'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'qb-core',
    'qb-target',
    'ox_inventory',
    'ox_lib',
}
