fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Advanced Farming & Crafting System'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/recipes.lua'
}

client_scripts {
    'client/client.lua',
    'client/nuihandler.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/styles/*.css',
    'html/index.html',
    'html/script.js',
}

dependencies {
    'es_extended',
    'oxmysql'
}