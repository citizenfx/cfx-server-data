fx_version 'cerulean'
games { 'rdr3', 'gta5' }
repository 'https://github.com/citizenfx/cfx-server-data'

author 'Cfx.re <root@cfx.re>'
description 'Handles the "host lock" for non-OneSync servers. Do not disable.'
version '1.0.0'

client_script 'client/empty.lua'
server_script 'server/host_lock.lua'
