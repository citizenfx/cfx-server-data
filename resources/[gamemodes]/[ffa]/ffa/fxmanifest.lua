-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'A Free For All gamemode for FiveM.'
repository 'https://github.com/citizenfx/cfx-server-data'

resource_type 'gametype' { name = 'FFA' }

dependencies {
  'baseevents'
}

client_script 'cl_mapmanager.lua'
client_script 'cl_ui.lua'

server_script 'sv_deathManager.lua'
