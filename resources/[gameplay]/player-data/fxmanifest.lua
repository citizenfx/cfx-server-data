-- This resource is part of the default FiveM/RedM resource pack (aka cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
description 'A basic resource for storing player identifiers.'
author 'The CitizenFX Collective'
repository 'https://github.com/citizenfx/cfx-server-data'

fx_version 'bodacious'
game 'common'

server_script 'server.lua'

provides {
    'cfx.re/playerData.v1alpha1'
}