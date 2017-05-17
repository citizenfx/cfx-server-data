local chatInputActive = false
local chatInputActivating = false

RegisterNetEvent('suggestionAdd')
RegisterNetEvent('chatMessage')
RegisterNetEvent('chatMessageEx')

AddEventHandler('chatMessage', function(author, color, text)
  if author == "" then
    author = false
  end
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = {
      color = color,
      multiline = true,
      args = { author, text }
    }
  })
end)

AddEventHandler('chatMessageEx', function(message)
  SendNUIMessage({
    type = 'ON_MESSAGE',
    message = message
  })
end)

AddEventHandler('suggestionAdd', function(name, help, params)
  Citizen.Trace(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    suggestion = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end)

RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)

  if not data.canceled then
    local id = PlayerId()

    TriggerServerEvent('chatMessageEntered', GetPlayerName(id), data.message)
  end

  cb('ok')
end)

RegisterNUICallback('loaded', function(data, cb)
  TriggerServerEvent('chatInit');

  cb('ok')
end)

Citizen.CreateThread(function()
  SetTextChatEnabled(false)

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true

        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0, 245) then
        SetNuiFocus(true)

        chatInputActivating = false
      end
    end
  end
end)
