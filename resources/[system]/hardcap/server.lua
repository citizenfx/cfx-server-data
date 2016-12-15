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

AddEventHandler('playerConnecting', function(name, setReason)
  print('Connecting: ' .. name)

  if playerCount >= 24 then
    print('Full. :(')

    setReason('This server is full (past 24 players).')
    CancelEvent()
  end
end)
