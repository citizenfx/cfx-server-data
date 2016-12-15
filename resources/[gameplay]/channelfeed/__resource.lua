description 'output lists for game content'

SetResourceInfo('uiPage', 'client/html/index.html')

client_script 'client/channelfeed.lua'

export 'printTo'
export 'addChannel'
export 'removeChannel'

files
{
    'client/html/index.html',
    'client/html/feed.js',
    'client/html/feed.css',
    'client/fonts/roboto-regular.ttf',
    'client/fonts/roboto-condensed.ttf',
}
