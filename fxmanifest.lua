fx_version 'cerulean'
game 'gta5'

description 'QBX_Apartments'
repository 'https://github.com/Qbox-project/qbx_apartments'
version '2.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/utils.lua',
    '@qbx_core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'qbx_core',
    'qbx_interior',
    'Renewed-Weathersync',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
