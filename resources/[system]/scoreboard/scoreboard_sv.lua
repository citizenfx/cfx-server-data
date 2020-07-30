local Players = {}

RegisterNetEvent("Scoreboard:ClientInitialized")
AddEventHandler("Scoreboard:ClientInitialized", function()
  Players[source] = GetPlayerName(source)
  TriggerClientEvent("Scoreboard:GetPlayerList", -1, Players)
end)

AddEventHandler("playerDropped", function (reason)
  Players[source] = false
  TriggerClientEvent("Scoreboard:GetPlayerList", -1, Players)
end)
