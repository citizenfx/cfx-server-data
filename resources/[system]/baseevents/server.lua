RegisterNetEvent('baseevents:onPlayerDied')
RegisterNetEvent('baseevents:onPlayerKilled')
RegisterNetEvent('baseevents:onPlayerWasted')
RegisterNetEvent('baseevents:enteringVehicle')
RegisterNetEvent('baseevents:enteringAborted')
RegisterNetEvent('baseevents:enteredVehicle')
RegisterNetEvent('baseevents:leftVehicle')

AddEventHandler('baseevents:onPlayerKilled', function(killedBy, data)
	local victim = source

	RconLog({msgType = 'playerKilled', victim = victim, attacker = killedBy, data = data})
end)

AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)
	local victim = source

	RconLog({msgType = 'playerDied', victim = victim, attackerType = killedBy, pos = pos})
end)
