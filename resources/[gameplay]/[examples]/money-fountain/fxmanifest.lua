-- This resource is part of the default FiveM/RedM resource pack (aka cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
description 'An example money system client containing a money fountain.'
repository 'https://github.com/citizenfx/cfx-server-data'
author 'The CitizenFX Collective'

fx_version 'bodacious'
game 'gta5'

client_script 'client.lua'
server_script 'server.lua'

shared_script 'mapdata.lua'

dependencies {
    'mapmanager',
    'money'
}

lua54 'yes'