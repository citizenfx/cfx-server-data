version '1.0.0'
description 'An example money system client containing a money fountain.'
author 'Cfx.re <pr@fivem.net>'

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