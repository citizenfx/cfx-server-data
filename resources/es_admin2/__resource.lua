resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Admin tool for ES'

client_script 'client.lua'
server_script 'server.lua'

ui_page 'ui/index.html'

files {
	'ui/index.html',
	'ui/style.css'
}

dependency 'essentialmode'