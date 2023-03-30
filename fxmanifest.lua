fx_version 'cerulean'
game 'gta5'

description 'QB-Apartments'
version '2.1.0'

shared_scripts {
    '@qbx-core/shared/locale.lua',
    '@ox_lib/init.lua',
    'config.lua',
    'locales/en.lua',
    'locales/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/gui.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx-core',
    'qbx-interior',
    'qbx-clothing',
    'qbx-weathersync',
}

lua54 'yes'
