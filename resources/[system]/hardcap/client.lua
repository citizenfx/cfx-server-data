Citizen.CreateThread(function()
	while true do
		Wait(0)

		-- If the player is connected to the server
		if NetworkIsSessionStarted() then
			TriggerServerEvent('hardcap:playerActivated')

			return
		end
	end
end)