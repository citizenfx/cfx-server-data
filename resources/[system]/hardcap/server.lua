local players = GetNumPlayerIndices()

AddEventHandler('playerDropped', function(reason)
  print(GetPlayerName(source) .. '^7 left: ' .. reason)
  players = players - 1
end)

AddEventHandler('playerConnecting', function(name, setReason)  
  local maxPlayers = GetConvarInt('sv_maxClients', 32)

  if players >= maxPlayers then
    print(name .. '^7 tried to join but the server is full.')

    setReason('The server is full (past ' .. maxPlayers .. ' players).')
    CancelEvent()
  end

  print(name .. '^7 connected.')
  players = players + 1
end)
