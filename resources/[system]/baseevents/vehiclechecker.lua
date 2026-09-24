
local isEnteringVehicle, isInVehicle, currentVehicle, currentSeat, ped

Citizen.CreateThread(function()
	while true do

		ped = PlayerPedId()

		if not isInVehicle then
			local vehicleIsTryingToEnter = GetVehiclePedIsTryingToEnter(ped) or 0

			if DoesEntityExist(vehicleIsTryingToEnter) and not isEnteringVehicle then
				-- Entering Vehicle
				isEnteringVehicle = true

				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local model = GetEntityModel(vehicleIsTryingToEnter)
				local vehicleName = GetDisplayNameFromVehicleModel(model)
				local netId = VehToNet(vehicle)
				local seat = GetSeatPedIsTryingToEnter(ped)

				TriggerEvent('baseevents:enteringVehicle', vehicle, seat, model, vehicleName)
				TriggerServerEvent('baseevents:enteringVehicle', vehicle, seat, model, vehicleName, netId)
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- Vehicle Entering Aborted
				isEnteringVehicle = false

				TriggerEvent('baseevents:enteringAborted')
				TriggerServerEvent('baseevents:enteringAborted')
			elseif IsPedInAnyVehicle(ped, false) then
				-- Entered Vehicle
				isEnteringVehicle = false
				isInVehicle = true

				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(ped)
				
				local model = GetEntityModel(currentVehicle)
				local vehicleName = GetDisplayNameFromVehicleModel(model)
				local netId = VehToNet(currentVehicle)

				TriggerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, model, vehicleName)
				TriggerServerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, model, vehicleName, netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) then
				-- Exiting Vehicle
				local model = GetEntityModel(currentVehicle)
				local vehicleName = GetDisplayNameFromVehicleModel(model)
				local netId = VehToNet(currentVehicle)
				
				TriggerEvent('baseevents:leftVehicle', currentVehicle, currentSeat, model, vehicleName)
				TriggerServerEvent('baseevents:leftVehicle', currentVehicle, currentSeat, model, vehicleName, netId)

				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end

		Citizen.Wait(100)
	end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end
