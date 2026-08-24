RegisterNetEvent('baseevents:onPlayerWasted')
RegisterNetEvent('baseevents:enteringVehicle')
RegisterNetEvent('baseevents:enteringAborted')
RegisterNetEvent('baseevents:enteredVehicle')
RegisterNetEvent('baseevents:leftVehicle')

RegisterNetEvent('baseevents:onPlayerKilled', function(killedBy, data)
	local victim = source

	RconLog({msgType = 'playerKilled', victim = victim, attacker = killedBy, data = data})
end)

RegisterNetEvent('baseevents:onPlayerDied', function(killedBy, pos)
	local victim = source
	RconLog({msgType = 'playerDied', victim = victim, attackerType = killedBy, pos = pos})
end)