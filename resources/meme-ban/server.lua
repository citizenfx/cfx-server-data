function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

RegisterCommand("meme", function(source, args, raw)
	if (isAdmin(source)) then
		if (tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil) then
			TriggerClientEvent("SendAlert", -1, "e", "e")
			Citizen.CreateThread(function()
				Citizen.Wait(1000 * tonumber(args[2]))
				TriggerEvent("EasyAdmin:banPlayer", tonumber(args[1]), Config.meme.message, false, GetPlayerName(args[1]))
				DropPlayer(tonumber(args[1]), Config.meme.message .. " (KICKED)")
			end)
		end
	else
		TriggerClientEvent('chatMessage', source, "meme", {255, 255, 255}, "Uou")
	end
end, false)

function isAdmin(source)
    local allowed = false
    for i,id in ipairs(Config.meme.admins) do
        for x,pid in ipairs(GetPlayerIdentifiers(source)) do
            if string.lower(pid) == string.lower(id) then
                allowed = true
            end
        end
	end
	if IsPlayerAceAllowed(source, "lance.meme") then
		allowed = true
	end
    return allowed
end

-- This work is by lance good and the cia