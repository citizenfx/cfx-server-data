RegisterServerEvent('chatCommandEntered')
RegisterServerEvent('chatMessageEntered')
RegisterServerEvent('initialSuggestions')


AddEventHandler('chatMessageEntered', function(author, message)
    if not message or not author then
        return
    end

    TriggerEvent('chatMessage', source, author, message)

    if not WasEventCanceled() then
        print("No cancel")
        TriggerClientEvent('chatMessage', -1, author,  { 0, 0, 0 }, message)
    end

    print(author .. ': ' .. message)
end)

-- player join messages
AddEventHandler('playerActivated', function()
    TriggerClientEvent('chatMessage', -1, '', { 0, 0, 0 }, '^2* ' .. GetPlayerName(source) .. ' joined.')
end)

AddEventHandler('playerDropped', function(reason)
    TriggerClientEvent('chatMessage', -1, '', { 0, 0, 0 }, '^2* ' .. GetPlayerName(source) ..' left (' .. reason .. ')')
end)
