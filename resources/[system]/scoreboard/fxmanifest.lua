fx_version 'cerulean'
game 'gta5'

version '1.0.0'
author 'Chip & Neco'
description 'The scoreboard resource.'
repository 'https://github.com/citizenfx/cfx-server-data'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/*.js',
  'html/*.css',
  'assets/*.png'
}

client_script 'client.lua'

server_script 'server.lua'

dependencies {
  'yarn',
  'webpack'
}

webpack_config 'webpack.config.js'
