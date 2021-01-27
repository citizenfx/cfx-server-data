RegisterCommand('help',function()
    TriggerEvent('chat:addMessage', {
        color = {255,0,0},
        multiline = true,
        args = {'SERVER','Join the Discord server for help'}

    })
end)

RegisterCommand('car', function(source, args)
    -- TODO: make a vehicle! fun!
    TriggerEvent('chat:addMessage', {
        args = { 'I wish I could spawn this ' .. (args[1] or 'adder') .. ' but my owner was too lazy. :(' }
    })
end, false)