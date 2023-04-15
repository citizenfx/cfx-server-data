local isShowing = false
local players = {}
local lastUpdate = 0

RegisterKeyMapping("+scoreboard", "Open the scoreboard.", "keyboard", "z")
RegisterCommand("+scoreboard", function(source, args, rawcommand)
  if not isShowing then
    if GetGameTimer() >= lastUpdate + 3000 then
      lastUpdate = GetGameTimer()
      TriggerServerEvent("scoreboard:getPlayers")
    end
    sortedColumns = sortColumns(GlobalState.columns)
    SendNUIMessage({
      app = 'CfxScoreboard',
      method = 'setColumns',
      data = sortedColumns
    })
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
        DisableControlAction(0, 1, true) -- INPUT_LOOK_LR - Prevent moving camera when moving mouse.
        DisableControlAction(0, 2, true) -- INPUT_LOOK_UD - Prevent moving camera when moving mouse.
        DisableControlAction(0, 16, true) -- INPUT_SELECT_NEXT_WEAPON - Prevent switching weapon when scrolling through list.
        DisableControlAction(0, 17, true) -- INPUT_SELECT_PREV_WEAPON	 - Prevent switching weapon when scrolling through list.
        DisableControlAction(0, 255, true) -- INPUT_MP_TEXT_CHAT_ALL - Prevent chat from opening.
        DisableControlAction(0, 99, true) -- INPUT_VEH_SELECT_NEXT_WEAPON - Prevent switching weapon when scrolling through list in a vehicle.
        DisableControlAction(0, 115, true) -- INPUT_VEH_FLY_SELECT_NEXT_WEAPON - Prevent switching weapon when scrolling through list in a vehicle.
        if GetGameTimer() >= lastUpdate + 3000 then
          TriggerServerEvent("scoreboard:getPlayers")
          lastUpdate = GetGameTimer()
        end
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

RegisterNetEvent("scoreboard:receivePlayers")
AddEventHandler("scoreboard:receivePlayers", function(_players)
  players = _players
  local nuiData = {}
  local sortedColumns = sortColumns(GlobalState.columns)
  SendNUIMessage({
    app = 'CfxScoreboard',
    method = 'setColumns',
    data = sortedColumns
  })
  for playerId, playerData in pairs(players) do
    local nextId = #nuiData+1
    nuiData[nextId] = {}
    for id, columnData in pairs(sortedColumns) do
      nuiData[nextId][id] = playerData[columnData.identifier]
    end
  end
  -- send to NUI to populate players
  SendNUIMessage({
    app = 'CfxScoreboard',
    method = 'setPlayers',
    data = nuiData
  })
end)

TriggerServerEvent("scoreboard:initialize")

function sortColumns(unsortedTable)
  table.sort(unsortedTable, function(a, b)
    if not a or not b then return end
    return a["position"] < b["position"]
  end)
  return unsortedTable
end

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
