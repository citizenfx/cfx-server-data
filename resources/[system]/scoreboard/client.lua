RegisterKeyMapping("+scoreboard", "Open the scoreboard.", "keyboard", "z")

RegisterCommand("+scoreboard", function(source, args, rawcommand)
  if not isShowing then
    TriggerServerEvent("scoreboard:getPlayers")
    SendNUIMessage({
      app = 'CfxScoreboard',
      method = 'setVisibility',
      data = true
    })
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
    SetCursorLocation(0.5, 0.5)
    isShowing = true
    Citizen.CreateThread(function()
      while isShowing do
        Citizen.Wait(0)
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 16, true)
        DisableControlAction(0, 17, true)
      end
    end)
  end
end, false)

RegisterCommand("-scoreboard", function(source, args, rawcommand)
  SendNUIMessage({
    app = 'CfxScoreboard',
    method = 'setVisibility',
    data = false
  })
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(false)
  isShowing = false
end, false)

players = {}

RegisterNetEvent("scoreboard:receivePlayers")
AddEventHandler("scoreboard:receivePlayers", function(_players)
  players = _players
  local nuiData = {}
  for playerId, playerData in pairs(players) do
    local nextId = #nuiData+1
    nuiData[nextId] = {}
    for id, columnData in pairs(columns) do
      nuiData[nextId][id] = playerData[columnData.friendlyName]
    end
  end
  -- send to NUI to populate players
  SendNUIMessage({
      app = 'CfxScoreboard',
      method = 'setPlayers',
      data = nuiData
    })
end)

TriggerServerEvent("scoreboard:requestColumns")

RegisterNetEvent("scoreboard:receiveColumns")
AddEventHandler("scoreboard:receiveColumns", function(_columns)
  table.sort(_columns, function(a, b)
    if not a or not b then return end
    return a["position"] < b["position"]
  end)
  columns = _columns
  -- Send to NUI to populate columns
  SendNUIMessage({
    app = 'CfxScoreboard',
    method = 'setColumns',
    data = columns
  })
end)

--[[
The following is stolen from the chat resource to allow for themes.
All credit for this goes to moscovium for writing the theme logic (03362d2).
]]
local function refreshThemes()
  local themes = {}

  for resIdx = 0, GetNumResources() - 1 do
    local resource = GetResourceByFindIndex(resIdx)

    if GetResourceState(resource) == 'started' then
      local numThemes = GetNumResourceMetadata(resource, 'scoreboard_theme')

      if numThemes > 0 then
        local themeName = GetResourceMetadata(resource, 'scoreboard_theme')
        local themeData = json.decode(GetResourceMetadata(resource, 'scoreboard_theme_extra') or 'null')

        if themeName and themeData then
          themeData.baseUrl = 'nui://' .. resource .. '/'
          themes[themeName] = themeData
        end
      end
    end
  end

  SendNUIMessage({
    app = 'CfxScoreboard',
    method = 'updateThemes',
    data = themes
  })
end

AddEventHandler('onClientResourceStart', function(resName)
  Wait(500)

  refreshThemes()
end)

AddEventHandler('onClientResourceStop', function(resName)
  Wait(500)

  refreshThemes()
end)
