local isInVehicle = false
local isEnteringVehicle = false
local currentVehicle = 0
local currentSeat = 0

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local playerId = PlayerId()

        if not isInVehicle and not IsPlayerDead(playerId) then
            local vehicleTryingToEnter = GetVehiclePedIsTryingToEnter(ped)
            local tryingToEnter = DoesEntityExist(vehicleTryingToEnter)

            if tryingToEnter and not isEnteringVehicle then
                local seat = GetSeatPedIsTryingToEnter(ped)
                isEnteringVehicle = true
                sleep = 0
                TriggerServerEvent('baseevents:enteringVehicle', vehicleTryingToEnter, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicleTryingToEnter)), VehToNet(vehicleTryingToEnter))
            elseif not tryingToEnter and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
                isEnteringVehicle = false
                sleep = 0
                TriggerServerEvent('baseevents:enteringAborted')
            elseif IsPedInAnyVehicle(ped, false) then
                isEnteringVehicle = false
                isInVehicle = true
                currentVehicle = GetVehiclePedIsUsing(ped)
                currentSeat = GetPedVehicleSeat(ped, currentVehicle)
                sleep = 0
                TriggerServerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), VehToNet(currentVehicle))
            elseif isEnteringVehicle then
                sleep = 0
            end
        elseif isInVehicle then
            if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(playerId) then
                isInVehicle = false
                sleep = 0
                TriggerServerEvent('baseevents:leftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), VehToNet(currentVehicle))
                currentVehicle = 0
                currentSeat = 0
            end
        end

        Wait(sleep)
    end
end)

function GetPedVehicleSeat(ped, vehicle)
    vehicle = vehicle or GetVehiclePedIsIn(ped, false)
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) do
        if GetPedInVehicleSeat(vehicle, i) == ped then return i end
    end
    return -2
end
