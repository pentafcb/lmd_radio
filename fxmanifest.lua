fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'LMD Group'
description 'Garage System'
version '1.0.0'
escrow_ignore {
    'custom/cl_edit.lua',
    'custom/sv_edit.lua',
    'locales/*.json',
    'config.lua',
    'readme.txt',
}
shared_scripts {
    '@ox_lib/init.lua',
    'init.lua',
    'config.lua'
}
client_scripts {
    'cl_utils.lua',
    'custom/cl_edit.lua',
    'client.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'sv_utils.lua',
    'custom/sv_edit.lua',
    'server.lua'
}
ui_page 'web/index.html'
files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/*.png',
    'web/locales/*.js',
    'locales/*.json'
}
dependencies {
    'oxmysql',
    'ox_lib',
}