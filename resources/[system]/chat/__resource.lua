description 'chat management stuff'

ui_page 'html/chat.html'

client_script 'chat_client.lua'
server_script 'chat_server.lua'

export 'printChatLine'

files {
    'html/chat.html',
    'html/chat.css',
    'html/chat.js',
    'html/jquery.faketextbox.js'
}
