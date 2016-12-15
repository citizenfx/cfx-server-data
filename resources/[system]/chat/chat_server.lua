RegisterServerEvent('chatCommandEntered')
RegisterServerEvent('chatMessageEntered')

AddEventHandler('chatMessageEntered', function(name, color, message)
    if not name or not color or not message or #color ~= 3 then
        return
    end

    TriggerEvent('chatMessage', source, name, message)

    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, color, message)
    end

    print(name .. ': ' .. message)
end)

-- player join messages
AddEventHandler('playerActivated', function()
    TriggerClientEvent('chatMessage', -1, '', { 0, 0, 0 }, '^2* ' .. GetPlayerName(source) .. ' joined.')
end)

AddEventHandler('playerDropped', function(reason)
    TriggerClientEvent('chatMessage', -1, '', { 0, 0, 0 }, '^2* ' .. GetPlayerName(source) ..' left (' .. reason .. ')')
end)

-- say command handler
AddEventHandler('rconCommand', function(commandName, args)
    if commandName == "say" then
        local msg = table.concat(args, ' ')

        TriggerClientEvent('chatMessage', -1, 'console', { 0, 0x99, 255 }, msg)
        RconPrint('console: ' .. msg .. "\n")

        CancelEvent()
    end
end)

-- tell command handler
AddEventHandler('rconCommand', function(commandName, args)
    if commandName == "tell" then
        local target = table.remove(args, 1)
        local msg = table.concat(args, ' ')

        TriggerClientEvent('chatMessage', tonumber(target), 'console', { 0, 0x99, 255 }, msg)
        RconPrint('console: ' .. msg .. "\n")

        CancelEvent()
    end
end)
