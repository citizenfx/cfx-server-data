-- This resource is part of the default FiveM/RedM resource pack (cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
author 'The CitizenFX Collective <pr@fivem.net>'
description 'Limits the number of players to the one set in sv_maxclients in the server.cfg.'
repository 'https://github.com/citizenfx/cfx-server-data'

client_script 'client.lua'
server_script 'server.lua'

fx_version 'adamant'
games { 'gta5', 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
