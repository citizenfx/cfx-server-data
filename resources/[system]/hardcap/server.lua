local playerCount = 0
local list = {}

RegisterServerEvent('hardcap:playerActivated')

AddEventHandler('hardcap:playerActivated', function()
  if not list[source] then
    playerCount = playerCount + 1
    list[source] = true
  end
end)

AddEventHandler('playerDropped', function()
  if list[source] then
    playerCount = playerCount - 1
    list[source] = nil
  end
end)

AddEventHandler('playerConnecting', function(Name, KickReason)
  local cv = GetConvarInt('sv_maxclients', 32)

  print("Player attempting to connect: " .. Name .. "^7")

  if playerCount >= cv then
    print("Player kicked: " .. Name .. " kicked due to the server being full.")

    KickReason("Sorry " .. Name .. ", the server is full (" .. tostring(cv) .. "/" .. tostring(cv) .. " players).")
    CancelEvent()
  end
end)
