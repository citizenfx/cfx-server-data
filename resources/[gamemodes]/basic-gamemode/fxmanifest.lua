-- This resource is part of the default FiveM/RedM resource pack (cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
author 'The CitizenFX Collective <pr@fivem.net>'
description 'Basic freeroam gamemode which signals spawnmanager to autospawn players.'
repository 'https://github.com/citizenfx/cfx-server-data'

resource_type 'gametype' { name = 'Freeroam' }

client_script 'basic_client.lua'

game 'common'
fx_version 'adamant'
