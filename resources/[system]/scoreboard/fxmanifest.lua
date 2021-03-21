-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'The scoreboard resource.'
repository 'https://github.com/citizenfx/cfx-server-data'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/*.js',
  'html/*.css',
  'assets/*.png',
  'assets/*.ttf'
}

client_script 'client.lua'

server_script 'server.lua'

dependencies {
  'yarn',
  'webpack'
}

webpack_config 'webpack.config.js'
