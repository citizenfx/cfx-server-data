fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Cfx.re <root@cfx.re>'
description 'Adds basic events for developers to use in their scripts. Some third party resources may depend on this resource.'
version '1.0.0'
repository 'https://github.com/citizenfx/cfx-server-data'

client_scripts {
    'vehiclechecker.lua',
    'deathevents.lua'
}

server_script 'server.lua'

