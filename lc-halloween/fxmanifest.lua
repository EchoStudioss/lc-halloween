fx_version 'cerulean'
game 'gta5'

author 'luacat'
description 'Halloween Trick or Treating Script'
version '1.0.1'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target'
}
