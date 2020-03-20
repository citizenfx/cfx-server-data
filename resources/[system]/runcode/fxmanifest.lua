fx_version 'bodacious'
games { 'rdr3', 'gta5' }

client_script 'runcode_cl.lua'
server_script 'runcode_sv.lua'
server_script 'runcode_web.lua'

shared_script 'runcode_shared.lua'

shared_script 'runcode.js'

client_script 'runcode_ui.lua'

ui_page 'web/nui.html'

files {
    'web/nui.html'
}