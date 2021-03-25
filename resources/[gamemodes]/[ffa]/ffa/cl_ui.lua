local position = {
  "1st",
  "2nd",
  "3rd"
}
local timer = 0
local countdownMessage = ""

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    SetPlayerWantedLevel(PlayerId(), 0, false)
    local killsTab = getKills()
    for i = 1, 3 do
      if killsTab[i] ~= nil then
        drawTxt(0.015, 0.7+(0.02*i), 0, 0.3, string.format("%s: %s (%s kills)", position[i], GetPlayerName(killsTab[i][1]), killsTab[i][2]), 255,255,255,255, true)
      end
    end
    if timer > 0 then
      drawTxt(0.5, 0.4, 7, 0.4, countdownMessage, 255,255,255,255, true, true)
      drawTxt(0.5, 0.42, 7, 0.5, timer, 255,255,255,255, true, true)
    end
  end
end)

function countdown(value, message)
  timer = value
  if message then
    countdownMessage = message
  end
end

function getKills()
  local playerKills = {}
  local i = 1
  for _, playerId in pairs(GetActivePlayers()) do
    playerKills[i] = {playerId, Player(GetPlayerServerId(playerId)).state.kills}
    i = i + 1
  end
  table.sort(playerKills, function(a, b)
    if not a[2] or not b[2] then return end
    return a[2] > b[2]
  end)
  return {playerKills[1], playerKills[2], playerKills[3]}
end
function drawTxt(x,y, font, scale, text, r,g,b,a, outline, centre)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextCentre(centre)
  SetTextDropShadow()
  if(outline)then
    SetTextOutline()
  end
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end
