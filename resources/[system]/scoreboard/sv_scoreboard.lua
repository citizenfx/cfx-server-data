-- prevent the possibility of someone spamming this event to try and net lag the server.
local joinedTbl = {}
RegisterNetEvent('playerJoined', function()
	local name = GetPlayerName(source)
	if not joinedTbl[source] then
		joinedTbl[source] = name
		TriggerClientEvent('fivem:playerJoined', -1, source, name)
		TriggerClientEvent('fivem:syncPlayerData', source, joinedTbl)
	else
		print(('%s [%s] tried sending the \'playerJoined\' net event, but they\'ve already joined!'):format(name, source))
	end
end)

AddEventHandler('playerDropped', function()
	joinedTbl[source] = nil
	TriggerClientEvent('fivem:playerLeft', -1, source)
end)