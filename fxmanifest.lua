fx_version 'cerulean'
game 'gta5'

ui_page 'client/nui/index.html'

files {
    'client/nui/assets/*.js',
    'client/nui/assets/*.css',
    'client/nui/index.html'
}

shared_scripts {
    '@vrp/lib/utils.lua',
    'config.lua',
    'framework.lua'
}

client_scripts { 
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}