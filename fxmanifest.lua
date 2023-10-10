fx_version 'cerulean'
game 'gta5'

description 'QBX-Apartments'
repository 'https://github.com/Qbox-project/qbx_apartments'
version '2.1.0'

shared_scripts {
    '@qbx_core/shared/locale.lua',
    '@ox_lib/init.lua',
    '@qbx_core/import.lua',
    'config.lua',
    'locales/en.lua',
    'locales/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

modules {
    'qbx_core:playerdata',
    'qbx_core:utils'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core',
    'qbx_interior',
    'qbx_weathersync',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'