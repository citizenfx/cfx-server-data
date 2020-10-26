isDead, playerActive, player, ped = false, false

CreateThread(function()
    while true do
        player = PlayerId()
        ped = PlayerPedId()
        playerActive = NetworkIsPlayerActive(player)
        Wait(1000)
    end
end)

CreateThread(function()
    local hasBeenDead, diedAt = false
    
    while true do Wait(0)
        if playerActive then
            if IsPedFatallyInjured(ped) and not isDead then
                isDead = true
                if not diedAt then diedAt = GetGameTimer() end
                local killer, killerweapon = NetworkGetEntityKillerOfPlayer(player)
                local killerentitytype = GetEntityType(killer)
                local killertype, killerinvehicle, killervehiclename, killervehicleseat = -1, false, '', 0

                if killerentitytype == 1 then
					killertype = GetPedType(killer)
					if IsPedInAnyVehicle(killer, false) == 1 then
						killerinvehicle = true
						killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(killer)))
                        killervehicleseat = GetPedVehicleSeat(killer)
					else killerinvehicle = false
					end
                end
                
                local killerid = GetPlayerByEntityID(killer)
				if killer ~= ped and killerid ~= nil and NetworkIsPlayerActive(killerid) then killerid = GetPlayerServerId(killerid)
				else killerid = -1
                end
                
                if killer == ped or killer == -1 then
                    TriggerEvent('baseevents:onPlayerDied', killertype, { table.unpack(GetEntityCoords(ped)) })
                    TriggerServerEvent('baseevents:onPlayerDied', killertype, { table.unpack(GetEntityCoords(ped)) })
                    hasBeenDead = true
                else
                    TriggerEvent('baseevents:onPlayerKilled', killerid, {killertype=killertype, weaponhash = killerweapon, killerinveh=killerinvehicle, killervehseat=killervehicleseat, killervehname=killervehiclename, killerpos={table.unpack(GetEntityCoords(ped))}})
                    TriggerServerEvent('baseevents:onPlayerKilled', killerid, {killertype=killertype, weaponhash = killerweapon, killerinveh=killerinvehicle, killervehseat=killervehicleseat, killervehname=killervehiclename, killerpos={table.unpack(GetEntityCoords(ped))}})
                    hasBeenDead = true
                end
            elseif not IsPedFatallyInjured(ped) and isDead then
                isDead = false
                diedAt = nil
            end

            -- check if the player has to respawn in order to trigger an event
            if not hasBeenDead and diedAt ~= nil and diedAt > 0 then
                TriggerEvent('baseevents:onPlayerWasted', { table.unpack(GetEntityCoords(ped)) })
                TriggerServerEvent('baseevents:onPlayerWasted', { table.unpack(GetEntityCoords(ped)) })

                hasBeenDead = true
            elseif hasBeenDead and diedAt ~= nil and diedAt <= 0 then
                hasBeenDead = false
            end
        end
    end
end)

function GetPlayerByEntityID(id)
    for _, player in ipairs(GetActivePlayers()) do if NetworkIsPlayerActive(player) and GetPlayerPed(player) == id then return player end end
    return nil
end