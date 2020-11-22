-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.

version '1.0.0'
author 'Cfx.re <root@cfx.re>'
description 'Basic player scoreboard.'
repository 'https://github.com/citizenfx/cfx-server-data'

-- temporary!
ui_page 'html/scoreboard.html'

client_script 'scoreboard.lua'

files {
    'html/scoreboard.html',
    'html/style.css',
    'html/reset.css',
    'html/listener.js',
    'html/res/futurastd-medium.css',
    'html/res/futurastd-medium.eot',
    'html/res/futurastd-medium.woff',
    'html/res/futurastd-medium.ttf',
    'html/res/futurastd-medium.svg',
}

fx_version 'adamant'
game 'gta5'
