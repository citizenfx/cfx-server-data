RegisterCommand('run', function(source, args, rawCommand)
	local res, err = RunCode('return ' .. rawCommand:sub(4))
end, true)

RegisterCommand('crun', function(source, args, rawCommand)
	TriggerClientEvent('runcode:gotSnippet', source, -1, 'return ' .. rawCommand:sub(5))
end, true)