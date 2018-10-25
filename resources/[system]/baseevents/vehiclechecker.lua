local isInVehicle = false
local isEnteringVehicle = false
local currentVehicle = 0
local currentSeat = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local ped = PlayerPedId()

		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				isEnteringVehicle = true
				TriggerServerEvent('baseevents:enteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
				TriggerServerEvent('baseevents:enteringAborted')
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(currentVehicle, ped)
				local model = GetEntityModel(currentVehicle)
				TriggerServerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
			end
		elseif isInVehicle then
			local isDead = IsPlayerDead(PlayerId())
			if not IsPedInAnyVehicle(ped, false) or isDead then
				-- bye, vehicle
				local model = GetEntityModel(currentVehicle)
				TriggerServerEvent('baseevents:leftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)))
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			elseif GetPedInVehicleSeat(currentVehicle, currentSeat) ~= ped and not isDead then
				-- Ped has Seat Swap or has been teleported to another seat
				currentSeat = GetPedVehicleSeat(currentVehicle, ped)
				TriggerServerEvent('baseevents:vehicleSeatChanged', currentVehicle, currentSeat)
			end
		end
		Citizen.Wait(50)
	end
end)

function GetPedVehicleSeat(currentVehicle, ped)
    for i=-1,GetVehicleMaxNumberOfPassengers(currentVehicle) do
        if(GetPedInVehicleSeat(currentVehicle, i) == ped) then return i end
    end
    return -2
end