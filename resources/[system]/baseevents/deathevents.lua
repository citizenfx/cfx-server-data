CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(0) end
    while not DoesEntityExist(PlayerPedId()) do Wait(0) end

    local isDead = false
    local hasBeenDead = false
    local diedAt

    while true do
        local sleep = 500
        local player = PlayerId()

        local ped = PlayerPedId()
        local fatallyInjured = IsPedFatallyInjured(ped)

        if fatallyInjured and not isDead then
            isDead = true
            sleep = 0
            if not diedAt then
                diedAt = GetGameTimer()
            end

            local killer, killerweapon = NetworkGetEntityKillerOfPlayer(player)
            local killerentitytype = GetEntityType(killer)
            local killertype = -1
            local killerinvehicle = false
            local killervehiclename = ''
            local killervehicleseat = 0

            if killerentitytype == 1 then
                killertype = GetPedType(killer)
                if IsPedInAnyVehicle(killer, false) then
                    local killerVehicle = GetVehiclePedIsUsing(killer)
                    killerinvehicle = true
                    killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(killerVehicle))
                    killervehicleseat = GetPedVehicleSeat(killer, killerVehicle)
                end
            end

            local killerid = NetworkGetPlayerIndexFromPed(killer)
            if killer ~= ped and killerid ~= -1 and NetworkIsPlayerActive(killerid) then
                killerid = GetPlayerServerId(killerid)
            else
                killerid = -1
            end

            local coords = { table.unpack(GetEntityCoords(ped)) }

            if killer == ped or killer == -1 then
                TriggerEvent('baseevents:onPlayerDied', killertype, coords)
                TriggerServerEvent('baseevents:onPlayerDied', killertype, coords)
            else
                local killerData = {
                    killertype = killertype,
                    weaponhash = killerweapon,
                    killerinveh = killerinvehicle,
                    killervehseat = killervehicleseat,
                    killervehname = killervehiclename,
                    killerpos = coords
                }
                TriggerEvent('baseevents:onPlayerKilled', killerid, killerData)
                TriggerServerEvent('baseevents:onPlayerKilled', killerid, killerData)
            end
            hasBeenDead = true

        elseif not fatallyInjured and isDead then
            isDead = false
            diedAt = nil
            sleep = 0
        end

        if not hasBeenDead and diedAt ~= nil then
            local coords = { table.unpack(GetEntityCoords(ped)) }
            TriggerEvent('baseevents:onPlayerWasted', coords)
            TriggerServerEvent('baseevents:onPlayerWasted', coords)
            hasBeenDead = true
            sleep = 0
        elseif hasBeenDead and diedAt == nil then
            hasBeenDead = false
        end

        Wait(sleep)
    end
end)
