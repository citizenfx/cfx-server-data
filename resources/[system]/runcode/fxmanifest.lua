-- This resource is part of the default Cfx.re asset pack (cfx-server-data)
-- Altering or recreating for local use only is strongly discouraged.
fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Cfx.re <root@cfx.re>'
description 'Allows server owners to execute arbitrary server-side or client-side JavaScript/Lua code. *Consider only using this on development servers.'
version '1.0.0'
repository 'https://github.com/citizenfx/cfx-server-data'

client_scripts {
    'runcode_cl.lua',
    'runcode_ui.lua'
}
server_scripts {
    'runcode_sv.lua',
    'runcode_web.lua'
}

shared_script {
    'runcode.js',
    'runcode_shared.lua'
}

ui_page 'web/nui.html'

file {
    'web/nui.html'
}
