-- This resource is part of the default FiveM/RedM resource pack (aka cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
author 'The CitizenFX Collective'
description 'Basic Freeroam gamemode that will signal spawnmanager to autospawn players.'
repository 'https://github.com/citizenfx/cfx-server-data'

resource_type 'gametype' { name = 'Freeroam' }

client_script 'basic_client.lua'

game 'common'
fx_version 'adamant'