-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

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

