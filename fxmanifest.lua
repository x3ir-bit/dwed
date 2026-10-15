fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'qb-chopshop'
description 'Chopshop mod for QBCore with ox_inventory and ox_target'
author 'x3ir'
version '1.0.0'

ui_page 'web/index.html' 

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/images/*.png',
}