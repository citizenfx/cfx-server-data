-- This resource is part of the default FiveM/RedM resource pack (aka cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
description 'A basic resource for displaying player names.'
author 'The CitizenFX Collective'
repository 'https://github.com/citizenfx/cfx-server-data'

-- add scripts
client_script 'playernames_api.lua'
server_script 'playernames_api.lua'

client_script 'playernames_cl.lua'
server_script 'playernames_sv.lua'

-- make exports
local exportList = {
    'setComponentColor',
    'setComponentAlpha',
    'setComponentVisibility',
    'setWantedLevel',
    'setHealthBarColor',
    'setNameTemplate'
}

exports(exportList)
server_exports(exportList)

-- add files
files {
    'template/template.lua'
}

-- support the latest resource manifest
fx_version 'adamant'
game 'gta5'