local ListOn = false

Citizen.CreateThread(function()
    ListOn = false
    while true do
        Wait(0)

        if IsControlPressed(0, 27)--[[ INPUT_PHONE ]] then
            if not ListOn then
                local Players = {}
                local PlayerTable = GetPlayers()
                ListOn = true

                for _, i in ipairs(PlayerTable) do
                    local r, g, b = GetPlayerRgbColour(i)
                    table.insert(Players, '<tr style=\"color: rgb(' .. r .. ', ' .. g .. ', ' .. b .. ')\"><td>' .. GetPlayerServerId(i) .. '</td><td>' .. sanitize(GetPlayerName(i)) .. '</td></tr>')
                end

                SendNUIMessage({ text = table.concat(Players) })

                while ListOn do
                    Wait(0)

                    if not IsControlPressed(0, 27) then
                        ListOn = false

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

function GetPlayers()
    local Players = {}
    local Count = NetworkGetNumConnectedPlayers()

    for i = 0, Count do
        if NetworkIsPlayerActive(i) then
            table.insert(Players, i)
        end
    end

    return Players
end

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
