--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

-- Global variables
Users = {}
commands = {}
settings = {}
settings.defaultSettings = {
	['permissionDenied'] = GetConvar('es_permissionDenied', 'false'),
	['startingCash'] = GetConvar('es_startingCash', '0'),
	['startingBank'] = GetConvar('es_startingBank', '0'),
	['enableRankDecorators'] = GetConvar('es_enableRankDecorators', 'false'),
	['moneyIcon'] = GetConvar('es_moneyIcon', '$'),
	['nativeMoneySystem'] = GetConvar('es_nativeMoneySystem', '0'),
	['commandDelimeter'] = GetConvar('es_commandDelimeter', '/'),
	['enableLogging'] = GetConvar('es_enableLogging', 'false'),
	['enableCustomData'] = GetConvar('es_enableCustomData', 'false'),
	['defaultDatabase'] = GetConvar('es_defaultDatabase', '1'),
	['disableCommandHandler'] = GetConvar('es_disableCommandHandler', 'false'),
	['identifierUsed'] = GetConvar('es_identifierUsed', 'steam')
}
settings.sessionSettings = {}
commandSuggestions = {}

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

function startswith(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

function returnIndexesInTable(t)
	local i = 0;
	for _,v in pairs(t)do
		i = i + 1
	end
	return i;
end

function debugMsg(msg)
	if(settings.defaultSettings.debugInformation and msg)then
		print("ES_DEBUG: " .. msg)
	end
end

function logExists(date, cb)
	Citizen.CreateThread(function()
		local log = LoadResourceFile(GetCurrentResourceName(), "logs/" .. date .. ".txt")
		if log then cb(true) else cb(false) end
		return
	end)
end

function doesLogExist(cb)
	logExists(string.gsub(os.date('%x'), '(/)', '-'), function(exists)
		Citizen.CreateThread(function()
			if not exists then
				local file = SaveResourceFile(GetCurrentResourceName(), "logs/" .. string.gsub(os.date('%x'), '(/)', '-') .. ".txt", '-- Begin of log for ' .. string.gsub(os.date('%x'), '(/)', '-') .. ' --\n', -1)
			end
			cb(exists)

			log('== EssentialMode started, version ' .. _VERSION .. ' ==')

			return
		end)
	end)
end

Citizen.CreateThread(function()
	if settings.defaultSettings.enableLogging ~= "false" then doesLogExist(function()end) end
	return
end)


function log(log)
	if settings.defaultSettings.enableLogging ~= "false" then
		Citizen.CreateThread(function()
			local file = LoadResourceFile(GetCurrentResourceName(), "logs/" .. string.gsub(os.date('%x'), '(/)', '-') .. ".txt")
			if file then
				SaveResourceFile(GetCurrentResourceName(), "logs/" .. string.gsub(os.date('%x'), '(/)', '-') .. ".txt", file .. log .. "\n", -1)
				return
			end
		end)
	end
end

AddEventHandler("es:debugMsg", debugMsg)
AddEventHandler("es:logMsg", log)