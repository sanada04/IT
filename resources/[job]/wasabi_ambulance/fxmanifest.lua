-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Wasabi ESX Ambulance Job Replacement'
author 'wasabirobby#5110'
version '1.0.8'

client_scripts {
  'client/client.lua',
  'client/functions.lua',
  'death_reasons.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua'
}

shared_scripts {
  '@ox_lib/init.lua',
  'strings.lua',
  'config.lua'
}

dependencies {
	'ox_lib',
  'oxmysql'
}

provides {
  'esx_ambulancejob'
}

escrow_ignore {
  'config.lua',
  'strings.lua',
  'death_reasons.lua',
  'client/*.lua',
  'server/*.lua'
}