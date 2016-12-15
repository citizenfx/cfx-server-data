Citizen.Trace("OMG FINALLY FIVEM SCRIPTING FROM SERVER-SIDE STUFF WOWOWOWOWOW-zers\n")

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = GetPlayerPed(-1)

		if playerPed and playerPed ~= -1 then
			--local pos = GetEntityCoords(playerPed)

			local is, pos = GetPedLastWeaponImpactCoord(playerPed)

			if is then
				SetNotificationTextEntry('STRING')
				AddTextComponentString(tostring(pos))
				DrawNotification(false, false)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50)

		local playerPed = GetPlayerPed(-1)

		if playerPed and playerPed ~= -1 then
			if IsControlPressed(2, 18) then
				SetEntityHeading(playerPed, GetEntityHeading(playerPed) + 15.0)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(250)

		local playerPed = GetPlayerPed(-1)

		if playerPed and playerPed ~= -1 then
			if IsControlPressed(0, 11) then 
				RequestModel(0x2B6DC64A)

				while not HasModelLoaded(0x2B6DC64A) do
					Citizen.Wait(0)
				end

				local playerCoords = GetEntityCoords(playerPed)
				playerCoords = playerCoords + vector3(0, 2, 0)

				local car = CreateVehicle(0x2B6DC64A, playerCoords, 0.0, true, false)

				SetNotificationTextEntry('STRING')
				AddTextComponentString('car: ' .. tostring(car))
				DrawNotification(false, false)

				TriggerEvent('isogram', 'a', function(b)
					Citizen.Trace('in isogram ' .. tostring(b.a) .. "\n")

					return b.a + 2
				end)
			end
		end
	end
end)

AddEventHandler('isogram', function(i, s)
	Citizen.Trace('in isogram_0 ' .. tostring(i) .. "\n")

	Citizen.Trace('out of isogram_0 ' .. tostring(s({ a = 50 })) .. "\n")
end)

AddEventHandler('onPlayerJoining', function(netId, name)
	TriggerServerEvent('yepThatsMe', netId, name, { a = 'b' })
end)