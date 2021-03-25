local ffaMap
local firstSpawn = true

AddEventHandler('getMapDirectives', function(add)
  add('ffa_map', function(state, mapName)
    return function(opts)
      ffaMap = {
        coords = vec3(opts.x, opts.y, opts.z),
        radius = opts.radius
      }
      state.add('map', mapName)
      print(mapName .. " has been started.")
    end
  end, function(state, arg)
    print(state.map .. " has been stopped.")
  end)
end)

Citizen.CreateThread(function()
  while ffaMap == nil or firstSpawn do
    Citizen.Wait(100)
  end
  while true do
    Citizen.Wait(100)
    local distFromMap = #(ffaMap.coords - GetEntityCoords(PlayerPedId()))
    if distFromMap >= ffaMap.radius then
      local timer = 5
      while distFromMap >= ffaMap.radius do
        Citizen.Wait(1000)
        distFromMap = #(ffaMap.coords - GetEntityCoords(PlayerPedId()))
        countdown(timer, "Turn back!")
        if timer == 0 and distFromMap >= ffaMap.radius then
          SetEntityHealth(PlayerPedId(), 0)
        end
        timer = timer - 1
      end
      countdown(0)
    end
  end
end)

AddEventHandler("playerSpawned", function()
  firstSpawn = false
  GiveWeaponToPed(PlayerPedId(), `WEAPON_CARBINERIFLE`, 1000, false, true)
end)

NetworkSetFriendlyFireOption(true)
SetCanAttackFriendly(PlayerPedId(), true, true)
TriggerServerEvent("ffa:init")

AddEventHandler('onClientMapStart', function()
  exports.spawnmanager:setAutoSpawn(true)
  exports.spawnmanager:forceRespawn()
end)

RegisterNetEvent("ffa:onPlayerKilled")
AddEventHandler("ffa:onPlayerKilled", function()
  SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent("ffa:roundEnd")
AddEventHandler("ffa:roundEnd", function()
  for i = 5, 0, -1 do
    countdown(i, "Next round starts in:")
    Citizen.Wait(1000)
  end
end)
