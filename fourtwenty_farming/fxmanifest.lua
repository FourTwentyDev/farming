fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Advanced Farming & Processing System'
version '1.0.0'

shared_scripts {
    'shared/configs/*.lua',
    'shared/locales/*.lua',
    'shared/locale.lua',
    'shared/config_validator.lua',
    'shared/recipes.lua'
}

client_scripts {
    '@es_extended/imports.lua',
    'client/modules/state.lua',
    'client/modules/animations.lua',
    'client/modules/blips.lua',
    'client/modules/static_farming.lua',
    'client/modules/dynamic_farming.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/database.lua',
    'server/modules/rewards.lua',
    'server/modules/orders.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/styles/*.css',
    'html/js/*.js',
    'html/index.html'
}

dependencies {
    'es_extended',
    'oxmysql'
}

lua54 'yes'