RegisterNetEvent("baseevents:onPlayerKilled")
AddEventHandler("baseevents:onPlayerKilled", function(killedBy, data)
  if source == killedBy then DropPlayer(source, "Nice try.") return end
  local localPly = Player(source)
  localPly.state.deaths = localPly.state.deaths + 1
  updateScoreboard(source)
  local killerPly = Player(killedBy)
  killerPly.state.kills = killerPly.state.kills + 1
  updateScoreboard(killedBy)
  TriggerClientEvent("ffa:onPlayerKilled", killedBy)
  if killerPly.state.kills == GetConvarInt("ffa_kill_threshold", 25) then
    TriggerClientEvent("ffa:roundEnd", -1)
    Citizen.Wait(5500)
    for _, playerId in pairs(GetPlayers()) do
      local ply = Player(playerId)
      ply.state.kills = 0
      ply.state.deaths = 0
      updateScoreboard(tonumber(playerId))
    end
    exports["mapmanager"]:roundEnded()
  end
end)

RegisterNetEvent("baseevents:onPlayerDied")
AddEventHandler('baseevents:onPlayerDied', function(killerType, pos)
  local localPly = Player(source)
  localPly.state.deaths = localPly.state.deaths + 1
  updateScoreboard(source)
end)

RegisterNetEvent("baseevents:onPlayerWasted")
AddEventHandler('baseevents:onPlayerWasted', function(killerType, pos)
  local localPly = Player(source)
  localPly.state.deaths = localPly.state.deaths + 1
  updateScoreboard(source)
end)

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  TriggerEvent("scoreboard:addColumn", "Kills", "Kills", 0, 2)
  TriggerEvent("scoreboard:addColumn", "Deaths", "Deaths", 0, 3)
  TriggerEvent("scoreboard:addColumn", "KD", "K/D", 0, 4)
  TriggerEvent("scoreboard:addColumn", "Points", "Points", 0, 5)
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  TriggerEvent("scoreboard:removeColumn", "Kills")
  TriggerEvent("scoreboard:removeColumn", "Deaths")
  TriggerEvent("scoreboard:removeColumn", "KD")
  TriggerEvent("scoreboard:removeColumn", "Points")
end)

RegisterNetEvent("ffa:init")
AddEventHandler("ffa:init", function()
  local localPly = Player(source)
  localPly.state.kills = 0
  localPly.state.deaths = 0
end)

--http://lua-users.org/wiki/SimpleRound
local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function updateScoreboard(src)
  local localPly = Player(src)
  TriggerEvent("scoreboard:updateColumnValue", src, "Kills", localPly.state.kills)
  TriggerEvent("scoreboard:updateColumnValue", src, "Deaths", localPly.state.deaths)
  local kd = round(localPly.state.kills/localPly.state.deaths, 2)
  if tostring(kd) == "inf" then kd = 0.0 end
  TriggerEvent("scoreboard:updateColumnValue", src, "KD", kd)
  TriggerEvent("scoreboard:updateColumnValue", src, "Points", 0)
end
