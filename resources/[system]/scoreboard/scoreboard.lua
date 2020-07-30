local listOn = false
local PlayerList = {}

Citizen.CreateThread(function()
    listOn = false
    while true do
        Wait(0)

        if IsControlPressed(0, 27)--[[ INPUT_PHONE ]] then
            if not listOn then
                local players = {}
                for id, name in ipairs(PlayerList) do
                  if name then
                    local playerid = GetPlayerFromServerId(id)
                    local wantedLevel = GetPlayerWantedLevel(playerid)
                    r, g, b = GetPlayerRgbColour(playerid)
                    table.insert(players,
                    '<tr style=\"color: rgb(' .. r .. ', ' .. g .. ', ' .. b .. ')\"><td>' .. id .. '</td><td>' .. sanitize(name) .. '</td><td>' .. (wantedLevel and wantedLevel or tostring(0)) .. '</td></tr>'
                    )
                  end
                end

                SendNUIMessage({ text = table.concat(players) })

                listOn = true
                while listOn do
                    Wait(0)
                    if(IsControlPressed(0, 27) == false) then
                        listOn = false
                        SendNUIMessage({
                            meta = 'close'
                        })
                        break
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("Scoreboard:GetPlayerList")
AddEventHandler("Scoreboard:GetPlayerList", function(list)
  PlayerList = list
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerServerEvent('Scoreboard:ClientInitialized')
			return
		end
	end
end)

function sanitize(txt)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }
    return txt
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s) return ' '..('&nbsp;'):rep(#s-1) end)
end
