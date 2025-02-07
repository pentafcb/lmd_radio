fx_version "cerulean"
game "gta5"
author 'LMD Group'
description 'Garage System https://lmdgroup.tebex.io'
lua54 'on'
shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}
client_script 'client.lua'
server_script 'server.lua'
ui_page 'web/index.html'
files {
    'web/index.html',
    'web/styles.css',
    'web/script.js',
    'web/images/*.png',
    'web/*.mp3',
}
