fx_version 'cerulean'
game 'gta5'

name 'metal_detector'
description '金属探知機で宝探し・お金稼ぎ'
author 'Sanada Sayo'
version '1.0.0'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/script.js'
}

shared_script 'config.lua'
shared_script 'shared/locale.lua'

client_scripts {
  'client/client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/server.lua'
}
