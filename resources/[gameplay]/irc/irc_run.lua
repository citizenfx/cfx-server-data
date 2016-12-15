local chatSharp = clr.ChatSharp

local client = chatSharp.IrcClient('irc.rizon.net', chatSharp.IrcUser('citimate', 'mateyate'), false)

-- temporary workaround for connections that never triggered playerActivated but triggered playerDropped
local activatedPlayers = {}

client.ConnectionComplete:add(function(s : object, e : System.EventArgs) : void
	client:JoinChannel('#meow')
end)

-- why is 'received' even misspelled here?
client.ChannelMessageRecieved:add(function(s : object, e : ChatSharp.Events.PrivateMessageEventArgs) : void
	local msg = e.PrivateMessage

	TriggerClientEvent('chatMessage', -1, msg.User.Nick, { 0, 0x99, 255 }, msg.Message)
end)

AddEventHandler('playerActivated', function()
	client:SendMessage('* ' .. GetPlayerName(source) .. '(' .. GetPlayerGuid(source) .. '@' .. GetPlayerEP(source) .. ') joined the server', '#fourdeltaone')
	table.insert(activatedPlayers, GetPlayerGuid(source))
end)

AddEventHandler('playerDropped', function()
	-- find out if this connection ever triggered playerActivated
	for index,guid in pairs(activatedPlayers) do
		if guid == playerGuid then
			-- show player dropping connection in chat
			client:SendMessage('* ' .. GetPlayerName(source) .. '(' .. GetPlayerGuid(source) .. '@' .. GetPlayerEP(source) .. ') left the server', '#fourdeltaone')
			table.remove(activatedPlayers, index)
			return
		end
	end
end)

AddEventHandler('chatMessage', function(source, name, message)
	print('hey there ' .. name)

	local displayMessage = gsub(message, '^%d', '')

	-- ignore zero-length messages
	if string.len(displayMessage) == 0 then
		return
	end

	-- ignore chat messages that are actually commands
	if string.sub(displayMessage, 1, 1) == "/" then
		return
	end

	client:SendMessage('[' .. tostring(GetPlayerName(source)) .. ']: ' .. displayMessage, '#fourdeltaone')
end)

AddEventHandler('onPlayerKilled', function(playerId, attackerId, reason, position)
    local player = GetPlayerByServerId(playerId)
    local attacker = GetPlayerByServerId(attackerId)

    local reasonString = 'killed'

    if reason == 0 or reason == 56 or reason == 1 or reason == 2 then
        reasonString = 'meleed'
    elseif reason == 3 then
        reasonString = 'knifed'
    elseif reason == 4 or reason == 6 or reason == 18 or reason == 51 then
        reasonString = 'bombed'
    elseif reason == 5 or reason == 19 then
        reasonString = 'burned'
    elseif reason == 7 or reason == 9 then
        reasonString = 'pistoled'
    elseif reason == 10 or reason == 11 then
        reasonString = 'shotgunned'
    elseif reason == 12 or reason == 13 or reason == 52 then
        reasonString = 'SMGd'
    elseif reason == 14 or reason == 15 or reason == 20 then
        reasonString = 'assaulted'
    elseif reason == 16 or reason == 17 then
        reasonString = 'sniped'
    elseif reason == 49 or reason == 50 then
        reasonString = 'ran over'
    end

	client:SendMessage('* ' .. attacker.name .. ' ' .. reasonString .. ' ' .. player.name, '#fourdeltaone')
end)

client:ConnectAsync()

AddEventHandler('onResourceStop', function(name)
	if name == GetInvokingResource() then
		client:Quit('Resource stopping.')
	end
end)