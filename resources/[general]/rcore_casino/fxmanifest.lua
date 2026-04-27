fx_version 'adamant'
game 'gta5'
description 'Lucky Wheel'
version '1.5.3'


server_scripts {
	'@mysql-async/lib/MySQL.lua',
    'locales/*.lua',
	'config.lua',
	'server.lua',
}

client_scripts {
    'locales/*.lua',
	'config.lua',
	'client.lua',
}

dependency 'qb-core'

















































