local plyTable = {}

RegisterNetEvent('fivem:playerJoined', function(source, name)
	plyTable[source] = name
end)

RegisterNetEvent('fivem:syncPlayerData', function(scoreTbl)
	plyTable = scoreTbl
end)

RegisterNetEvent('fivem:playerLeft', function(source)
	plyTable[source] = nil
end)

RegisterCommand('+scoreboard', function()
	local localPly = PlayerPedId()
	local players = {}
	for serverId, name in pairs(plyTable) do
		local ply = GetPlayerFromServerId(serverId)
		local wantedLevel
		local r, g, b = 255, 255, 255
		-- if the player exists and isnt themselves.
		if ply ~= localPly then
			wantedLevel = GetPlayerWantedLevel(ply)
			r, g, b = GetPlayerRgbColour(ply)
		end
		players[#players + 1] = '<tr style=\"color: rgb(' .. r .. ', ' .. g .. ', ' .. b .. ')\"><td>' .. serverId .. '</td><td>' .. sanitize(name) .. '</td><td>' .. (wantedLevel and wantedLevel or tostring(0)) .. '</td></tr>'
	end
	SendNUIMessage({ text = table.concat(players) })
end)
RegisterCommand('-scoreboard', function()
	SendNUIMessage({
		meta = 'close'
	})
end)
RegisterKeyMapping('+scoreboard', 'Opens Scoreboard', 'keyboard', GetConvar('scoreboard_toggleScoreboard', 'UP'))

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
