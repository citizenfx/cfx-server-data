-- Player Died event.
RegisterServerEvent("baseevents:onPlayerDied")
AddEventHandler('baseevents:onPlayerDied', function(killer, killerT)	
	TriggerClientEvent("playerDied", source)
end)

-- Player killed event.
RegisterServerEvent("baseevents:onPlayerKilled")
AddEventHandler('baseevents:onPlayerKilled', function(killer, killerT)	
	TriggerClientEvent("playerKilled", source, killer, killerT)
end)

RegisterServerEvent("kills:_notification")
AddEventHandler("kills:_notification", function(text, duration)
	TriggerClientEvent("kills:notification", -1, text, duration)
end)