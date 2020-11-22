-- This resource is part of the default FiveM/RedM resource pack (cfx-server-data)
-- Modifying or rewriting this resource for local use only is strongly discouraged.

version '1.0.0'
author 'The CitizenFX Collective <pr@fivem.net>'
description 'Provides custom chat functionality for FiveM using a NUI-based interface.'
repository 'https://github.com/citizenfx/cfx-server-data'

ui_page 'dist/ui.html'

client_script 'cl_chat.lua'
server_script 'sv_chat.lua'

files {
  'dist/ui.html',
  'dist/index.css',
  'html/vendor/*.css',
  'html/vendor/fonts/*.woff2',
}

fx_version 'adamant'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
  'yarn',
  'webpack'
}

webpack_config 'webpack.config.js'