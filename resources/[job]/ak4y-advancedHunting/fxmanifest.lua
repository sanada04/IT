fx_version 'cerulean'
game 'gta5'

dependencies {
    'qb-core',
    'oxmysql',
}

shared_script {
	"config.lua",
}

client_scripts {
	'client/main.lua',
	'client/aimblock.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	-- '@mysql-async/lib/MySQL.lua',
	'server_config.lua',
	'server/main.lua',
	'admin_commands.lua',
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/font/*.ttf',
	'html/font/*.otf',
	'html/css/*.css',
	'html/images/*.jpg',
	'html/images/*.png',
	'html/js/*.js',
}