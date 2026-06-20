fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Xelyos | Bobs&Co'
version '2.1.0'
description 'Game tablet'

ui_page 'nui/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua',
    'locales.lua',
    'locales/*.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'nui/index.html',
    'nui/assets/config.js',
    'nui/assets/index.js',
    'nui/assets/style.css',
    'nui/assets/color.css',
    'nui/img/*',
    'data/apps_data.json'
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'nui/assets/config.js',
    'nui/assets/color.css',
    'nui/img/*',
    'nui/index.html',
    'data/*'
}

dependency '/assetpacks'
