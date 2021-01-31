-- prevent the possibility of someone spamming this event to try and net lag the server.
local joined = {}
RegisterNetEvent('playerJoined', function()
	if not joined[source] then
		joined[source] = true
		TriggerClientEvent('fivem:playerJoined', -1, source, GetPlayerName(source))
	end
end)

AddEventHandler('playerDropped', function()
	joined[source] = nil
	TriggerClientEvent('fivem:playerLeft', -1, source)
end)