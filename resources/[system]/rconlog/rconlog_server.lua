RconLog({ msgType = 'serverStart', hostname = 'lovely', maxplayers = 32 })

RegisterServerEvent('rlPlayerActivated')

local names = {}

AddEventHandler('rlPlayerActivated', function()
    RconLog({ msgType = 'playerActivated', netID = source, name = GetPlayerName(source), guid = GetPlayerIdentifiers(source)[1], ip = GetPlayerEP(source) })

    names[source] = { name = GetPlayerName(source), id = source }

	if GetHostId() then
		TriggerClientEvent('rlUpdateNames', GetHostId())
	end
end)

RegisterServerEvent('rlUpdateNamesResult')

AddEventHandler('rlUpdateNamesResult', function(res)
    if source ~= tonumber(GetHostId()) then
        print('bad guy')
        return
    end

    for id, data in pairs(res) do
        if data then
            if data.name then
                if not names[id] then
                    names[id] = data
                end

                if names[id].name ~= data.name or names[id].id ~= data.id then
                    names[id] = data

                    RconLog({ msgType = 'playerRenamed', netID = id, name = data.name })
                end
            end
        else
            names[id] = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    RconLog({ msgType = 'playerDropped', netID = source, name = GetPlayerName(source) })

    names[source] = nil
end)

AddEventHandler('chatMessage', function(netID, name, message)
    RconLog({ msgType = 'chatMessage', netID = netID, name = name, message = message, guid = GetPlayerIdentifiers(netID)[1] })
end)

RegisterCommand('status', function(source, args, rawCommand)
    for netId, data in pairs(names) do
        local guid = GetPlayerIdentifiers(netId)

        if guid and guid[1] and data then
            local ping = GetPlayerPing(netId)

            print(netId .. ' ' .. guid[1] .. ' ' .. data.name .. ' ' .. GetPlayerEP(netId) .. ' ' .. ping .. '\n')
        end
    end
end, true)

RegisterCommand('clientkick', function(source, args, rawCommand)
    local playerId = tonumber(args[1])
    local msg = #args >= 2 and table.concat(args, ' ', 2) or 'No reason provided.'
    if not playerId or not GetPlayerName(playerId) then return end

    DropPlayer(playerId, msg)
end, true)

RegisterCommand('tempbanclient', function(source, args, rawCommand)
    local playerId = tonumber(args[1])
    local msg = #args >= 2 and table.concat(args, ' ', 2) or 'No reason provided.'
    if not playerId or not GetPlayerName(playerId) then return end

    TempBanClient(playerId, msg)
end, true)
