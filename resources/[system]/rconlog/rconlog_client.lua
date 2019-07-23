RegisterNetEvent('rlUpdateNames')

AddEventHandler('rlUpdateNames', function()
	local names = {}

	for _, i in pairs(GetActivePlayers()) do
		names[GetPlayerServerId(i)] = { id = i, name = GetPlayerName(i) }
	end

	TriggerServerEvent('rlUpdateNamesResult', names)
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent('rlPlayerActivated')

			return
		end
	end
end)
