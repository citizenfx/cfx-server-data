-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.
fx_version 'cerulean'
games { 'rdr3', 'gta5' }
repository 'https://github.com/citizenfx/cfx-server-data'

author 'Cfx.re <root@cfx.re>'
description 'Handles the "host lock" for non-OneSync servers. Do not disable.'
version '1.0.0'

client_script 'client/empty.lua'
server_script 'server/host_lock.lua'
