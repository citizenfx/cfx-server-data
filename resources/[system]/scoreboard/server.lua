RegisterNetEvent("scoreboard:getPlayers")
AddEventHandler("scoreboard:getPlayers", function()
  TriggerClientEvent("scoreboard:receivePlayers", source, players)
end)

columns = {
  {
    friendlyName = "Player ID",
    defaultValue = 0,
    position = 0
  },
  {
    friendlyName = "Name",
    defaultValue = "***Invalid***",
    position = 1
  }
}

players = {}

RegisterNetEvent("scoreboard:requestColumns")
AddEventHandler("scoreboard:requestColumns", function()
  players[source] = {}
  for id, columnData in pairs(columns) do
    players[source][columnData.friendlyName] = columnData.defaultValue
  end
  players[source]["Player ID"] = source
  players[source]["Name"] = GetPlayerName(source)
  TriggerClientEvent("scoreboard:receiveColumns", source, columns)
end)

--[[
Event name: scoreboard:addColumn
Description: Adds a column to the scoreboard in the specified position with a default value.
Parameters:
_friendlyName: Name of the column you want to add (shows on scoreboard).
_defaultValue: Default value of the column.
_position: The position of the column.
]]
AddEventHandler("scoreboard:addColumn", function(_friendlyName, _defaultValue, _position)
  columns[#columns+1] = {
    friendlyName = _friendlyName,
    defaultValue = _defaultValue or 0,
    position = _position
  }
  for _, playerId in pairs(GetPlayers()) do
    if players[tonumber(playerId)] ~= nil then
      players[tonumber(playerId)][_friendlyName] = _defaultValue
    end
  end
  TriggerClientEvent("scoreboard:receiveColumns", -1, columns)
end)

--[[
Event name: scoreboard:removeColumn
Description: Removes the specified column.
Parameters:
columnName: Name of the column you want to remove (needs to be the same as the column name on the scoreboard).
]]
AddEventHandler("scoreboard:removeColumn", function(columnName)
  local columnId = getColumnFromName(columnName)
  if columnId then
    for _, playerId in pairs(GetPlayers()) do
      if players[tonumber(playerId)] ~= nil then
        players[tonumber(playerId)][columnName] = nil
      end
    end
    columns[columnId] = nil
    TriggerClientEvent("scoreboard:receiveColumns", -1, columns)
    TriggerClientEvent("scoreboard:receivePlayers", -1, players)
  end
end)

--[[
Event name: scoreboard:updateColumnValue
Description: Updates the specified column value for the specified player.
Parameters:
src: The source of the player you want to change.
columnName: Name of the column you want to change (needs to be the same as the column name on the scoreboard).
value: The value of the column you want to set for that player.
]]
AddEventHandler("scoreboard:updateColumnValue", function(src, columnName, value)
  local columnId = getColumnFromName(columnName)
  if columnId then
    players[src][columnName] = value
  end
end)


AddEventHandler("playerDropped", function(reason)
  players[source] = nil
end)

function getColumnFromName(name)
  for id, data in pairs(columns) do
    if data.friendlyName == name then
      return id
    end
  end
  return false
end
