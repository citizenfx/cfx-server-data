-- prevent stopping gameInit on the server
AddEventHandler('onResourceStop', function(name)
    if name == 'gameInit' then CancelEvent() end
end)
