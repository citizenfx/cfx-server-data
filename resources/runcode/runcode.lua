RegisterCommand('runcode', function(source, args, rawCommand)
	RunCode('return ' .. rawCommand:sub(8))
end, true)