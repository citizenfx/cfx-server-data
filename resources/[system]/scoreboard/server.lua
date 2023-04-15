local players = {}

GlobalState.columns = {
  {
    identifier = "ID",
    friendlyName = "Player ID",
    defaultValue = 0,
    position = 0
  },
  {
    identifier = "Name",
    friendlyName = "Player Name",
    defaultValue = "***Invalid***",
    position = 1
  }
}

RegisterNetEvent("scoreboard:getPlayers")
AddEventHandler("scoreboard:getPlayers", function()
  TriggerLatentClientEvent("scoreboard:receivePlayers", source, 50000, players)
end)

RegisterNetEvent("scoreboard:initialize")
AddEventHandler("scoreboard:initialize", function()
  players[source] = {}
  for id, columnData in pairs(GlobalState.columns) do
    players[source][columnData.identifier] = columnData.defaultValue
  end
  players[source]["ID"] = source
  players[source]["Name"] = GetPlayerName(source)
end)

--[[
Event name: scoreboard:addColumn
Description: Adds a column to the scoreboard in the specified position with a default value.
Parameters:
_identifier: Unique identifier for the column.
_friendlyName: Name of the column you want to add (shows on scoreboard).
_defaultValue: Default value of the column.
_position: The position of the column.
]]
AddEventHandler("scoreboard:addColumn", function(_identifier, _friendlyName, _defaultValue, _position)
  local tempColumns = GlobalState.columns
  tempColumns[#tempColumns+1] = {
    identifier = _identifier,
    friendlyName = _friendlyName,
    defaultValue = _defaultValue or 0,
    position = _position
  }
  GlobalState.columns = tempColumns
  for _, playerId in pairs(GetPlayers()) do
    if players[tonumber(playerId)] ~= nil then
      players[tonumber(playerId)][_identifier] = _defaultValue
    end
  end
end)

--[[
Event name: scoreboard:removeColumn
Description: Removes the specified column.
Parameters:
columnIdentifier: Identifier of the column you want to remove.
]]
AddEventHandler("scoreboard:removeColumn", function(columnIdentifier)
  local columnId = getColumnFromIdentifier(columnIdentifier)
  if columnId then
    for _, playerId in pairs(GetPlayers()) do
      if players[tonumber(playerId)] ~= nil then
        players[tonumber(playerId)][columnIdentifier] = nil
      end
    end
    local tempColumns = GlobalState.columns
    tempColumns[columnId] = nil
    GlobalState.columns = tempColumns
  end
end)

--[[
Event name: scoreboard:updateColumnValue
Description: Updates the specified column value for the specified player.
Parameters:
src: The source of the player you want to change.
columnIdentifier: Identifier of the column you want to change.
value: The value of the column you want to set for that player.
]]
AddEventHandler("scoreboard:updateColumnValue", function(src, columnIdentifier, value)
  local columnId = getColumnFromIdentifier(columnIdentifier)
  if columnId then
    players[src][columnIdentifier] = value
  end
end)

AddEventHandler("playerDropped", function(reason)
  players[source] = nil
end)

function getColumnFromIdentifier(name)
  for id, data in pairs(GlobalState.columns) do
    if data.identifier == name then
      return id
    end
  end
  return false
end
