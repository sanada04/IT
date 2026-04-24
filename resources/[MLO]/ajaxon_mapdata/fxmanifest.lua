fx_version 'cerulean'
game 'gta5'
description 'Mapdata'
version '1.0.2'
this_is_a_map 'yes'

replace_level_meta 'gta5'


data_file 'TIMECYCLEMOD_FILE' 'ajaxon_timecycle.xml'
data_file "AUDIO_GAMEDATA" "game.dat"


files {
    'ajaxon_timecycle.xml',
    'gta5.meta',
    'doortuning.ymt',
    'game.dat151.rel',
}

client_script {
    'ajaxon_entityset.lua',
}

