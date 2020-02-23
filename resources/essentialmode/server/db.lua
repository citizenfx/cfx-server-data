--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

local bs = { [0] =
	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/',
}

local function base64(s)
	local byte, rep = string.byte, string.rep
	local pad = 2 - ((#s-1) % 3)
	s = (s..rep('\0', pad)):gsub("...", function(cs)
		local a, b, c = byte(cs, 1, 3)
		return bs[a>>2] .. bs[(a&3)<<4|b>>4] .. bs[(b&15)<<2|c>>6] .. bs[c&63]
	end)

	return s:sub(1, #s-pad) .. rep('=', pad)
end

auth = base64(auth)

db = {}
exposedDB = {}

function db.firstRunCheck()
	if settings.defaultSettings.enableCustomData ~= '1' and settings.defaultSettings.defaultDatabase ~= '1' then
		PerformHttpRequest("http://" .. ip .. ":" .. port .. "/essentialmode/_compact", function(err, rText, headers)
		end, "POST", "", {["Content-Type"] = "application/json", Authorization = "Basic " .. auth})

		PerformHttpRequest("http://" .. ip .. ":" .. port .. "/essentialmode", function(err, rText, headers)
			if err == 0 then
				print(_Prefix .. "-------------------------------------------------------------")
				print(_Prefix .. "--- No errors detected, essentialmode is setup properly. ---")
				print(_Prefix .. "-------------------------------------------------------------")
			elseif err == 412 then
				print(_Prefix .. "-------------------------------------------------------------")
				print(_Prefix .. "--- No errors detected, essentialmode is setup properly. ---")
				print(_Prefix .. "-------------------------------------------------------------")
			elseif err == 401 then
				print(_PrefixError .. "------------------------------------------------------------------------------------------------")
				print(_PrefixError .. "--- Error detected in authentication, please take a look at your convars for essentialmode. ---")
				print(_PrefixError .. "------------------------------------------------------------------------------------------------")
				log('== Authentication error with CouchDB ==')
			elseif err == 201 then
				print(_Prefix .. "-------------------------------------------------------------")
				print(_Prefix .. "--- No errors detected, essentialmode is setup properly. ---")
				print(_Prefix .. "-------------------------------------------------------------")
				log('== DB Created ==')			
			else
				print(_PrefixError .. "------------------------------------------------------------------------------------------------")
				print(_PrefixError .. "--- Unknown error detected ( " .. err .. " ): " .. rText)
				print(_PrefixError .. "------------------------------------------------------------------------------------------------")
				log('== Unknown error, (' .. err .. '): ' .. rText .. ' ==')
			end
		end, "PUT", "", {Authorization = "Basic " .. auth})
	elseif settings.defaultSettings.defaultDatabase == '1' and settings.defaultSettings.enableCustomData ~= '1' then
		TriggerEvent("es_sqlite:initialize")
	else
		TriggerEvent('es_db:firstRunCheck', ip, port)
	end
end

local url = "http://" .. ip .. ":" .. port .. "/"

local function requestDB(request, location, data, headers, callback)
	if request == nil or type(request) ~= "string" then request = "GET" end
	if headers == nil or type(headers) ~= "table" then headers = {} end
	if data == nil or type(data) ~= "table" then data = "" end
	if location == nil or type(location) ~= "string" then location = "" end

	-- So I don't have to repeat this every single request
	if auth then
		headers.Authorization = 'Basic ' .. auth
	end

	if type(data) == "table" then
		data = json.encode(data)
	end

	PerformHttpRequest(url .. location, function(err, rText, headers)
		if callback then
			callback(err, rText, headers)
		end
	end, request, data, headers)
end

local function getUUID(amount, cb)
	if amount == nil or amount <= 0 then amount = 1 end

	requestDB('GET', '_uuids?count=' .. amount, nil, nil, function(err, rText, headers)
		if err ~= 200 then
			log('== Could not retrieve UUID from CouchDB, error('.. err .. '): '.. rText .. ' ==')
			print(_PrefixError .. ' Error occurred while performing database request: could not retrieve UUID, error code: ' .. err .. ", server returned: " .. rText)
		else
			if cb then
				if amount > 1 then
					cb(json.decode(rText).uuids)
				else
					cb(json.decode(rText).uuids[1])
				end
			end
		end
	end)
end

local function getDocument(uuid, callback)
	requestDB('GET', 'essentialmode/' .. uuid, nil, nil, function(err, rText, headers)
		local doc =  json.decode(rText)

		if err ~= 200 then
			log('== Could not retrieve document from CouchDB, error('.. err .. '): '.. rText .. ' ==')
			print(_PrefixError .. 'Error occurred while performing database request: could not retrieve document, error code: ' .. err .. ", server returned: " .. rText)
		else
			if callback then
				if doc then callback(doc) else callback(false) end
			end
		end
	end)	
end

local function createDocument(doc, cb)
	if doc == nil or type(doc) ~= "table" then doc = {} end

	getUUID(1, function(uuid)
		requestDB('PUT', 'essentialmode/' .. uuid, doc, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
			if err ~= 201 then
				print(_PrefixError .. 'Error occurred while performing database request: could not create document, error code: ' .. err .. ", server returned: " .. rText)
			else
				if cb then
					cb(rText, doc)
				end
			end
		end)
	end)
end

local function updateDocument(docID, updates, callback)
	if docID == nil then docID = "" end
	if updates == nil or type(updates) ~= "table" then updates = {} end

	getDocument(docID, function(doc)
		if doc then
			for i in pairs(updates)do
				if updates[i] then
					doc[i] = updates[i]
				end
			end

			if updates.license then
				doc.license = updates.license
			end

			requestDB('PUT', 'essentialmode/' .. docID, doc, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
				if not json.decode(rText).ok then
					if err ~= 409 then
						print(_PrefixError .. 'Error occurred while performing database request: could not update document error ' .. err .. ", returned: " .. rText)
					end
				else
					if callback then
						callback(rText)
					end
				end
			end)
		else
			print(_PrefixError .. "Error occurred while performing database request: could not find document (" .. docID .. ")")
		end
	end)
end

function db.updateUser(identifier, new, callback)
	if settings.defaultSettings.enableCustomData ~= '1' and settings.defaultSettings.defaultDatabase ~= '1' then
		db.retrieveUser(identifier, function(user)
			updateDocument(user._id, new, function(returned)
				if callback then callback(returned) end
			end)
		end)
	elseif settings.defaultSettings.defaultDatabase == '1' and settings.defaultSettings.enableCustomData ~= '1' then
		TriggerEvent('es_sqlite:updateUser', identifier, new, callback)
	else
		TriggerEvent('es_db:updateUser', identifier, new, callback)
	end
end

db.requestDB = requestDB

function db.createUser(identifier, license, callback)
	if settings.defaultSettings.enableCustomData ~= '1' and settings.defaultSettings.defaultDatabase ~= '1' then
		if type(identifier) == "string" and identifier ~= nil then
			createDocument({ identifier = identifier, license = license, money = tonumber(settings.defaultSettings.startingCash) or 0, bank = tonumber(settings.defaultSettings.startingBank) or 0, group = "user", permission_level = 0 }, function(returned, document)
				if callback then
					callback(returned, document)
				end
			end)
		else
			print(_PrefixError .. "Error occurred while creating user, missing parameter or incorrect parameter: identifier")
		end
	elseif settings.defaultSettings.defaultDatabase == '1' and settings.defaultSettings.enableCustomData ~= '1' then
		TriggerEvent("es_sqlite:createUser", identifier, license, tonumber(settings.defaultSettings.startingCash), tonumber(settings.defaultSettings.startingBank), "user", 0, "", callback)
	else
		TriggerEvent('es_db:createUser', identifier, license, tonumber(settings.defaultSettings.startingCash), tonumber(settings.defaultSettings.startingBank), callback)
	end
end

function db.doesUserExist(identifier, callback)
	if settings.defaultSettings.enableCustomData ~= '1' and settings.defaultSettings.defaultDatabase ~= '1' then
		if identifier ~= nil and type(identifier) == "string" then
			requestDB('POST', 'essentialmode/_find', {selector = {["identifier"] = identifier}}, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
				if rText then
					if callback then
						if json.decode(rText).docs[1] then callback(true) else callback(false) end
					end
				else
					print(_PrefixError .. 'Error occurred while attempting to find user in CouchDB.')
				end
			end)
		else
			print(_PrefixError .. "Error occurred while checking existance user, missing parameter or incorrect parameter: identifier")
		end
	elseif settings.defaultSettings.defaultDatabase == '1' and settings.defaultSettings.enableCustomData ~= '1' then
		TriggerEvent("es_sqlite:doesUserExist", identifier, callback)
	else
		TriggerEvent('es_db:doesUserExist', identifier, callback)
	end
end

function db.retrieveUser(identifier, callback)
	if settings.defaultSettings.enableCustomData ~= '1' and settings.defaultSettings.defaultDatabase ~= '1' then
		if identifier ~= nil and type(identifier) == "string" then
			requestDB('POST', 'essentialmode/_find', {selector = {["identifier"] = identifier}}, {["Content-Type"] = 'application/json'}, function(err, rText, headers)
				local doc =  json.decode(rText).docs[1]
				if callback then
					if doc then callback(doc) else callback(false) end
				end
			end)
		else
			print(_PrefixError .. "Error occurred while retrieving user, missing parameter or incorrect parameter: identifier")
		end
	elseif settings.defaultSettings.defaultDatabase == '1' and settings.defaultSettings.enableCustomData ~= '1' then
		TriggerEvent("es_sqlite:retrieveUser", identifier, callback)
	else
		TriggerEvent('es_db:retrieveUser', identifier, callback)
	end
end

function db.performCheckRunning()
	requestDB('GET', nil, nil, nil, function(err, rText, header)
		print(rText)
	end)
end

db.firstRunCheck()

function exposedDB.createDatabase(db, cb)
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db, function(err, rText, headers)
		if err == 0 then
			cb(true, 0)
		else
			cb(false, rText)
		end
	end, "PUT", "", {Authorization = "Basic " .. auth})
end

function exposedDB.createDocument(db, rows, cb)
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/_uuids", function(err, rText, headers)
		PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/" .. json.decode(rText).uuids[1], function(err, rText, headers)
			if err == 0 then
				cb(true, 0)
			else
				cb(false, rText)
			end
		end, "PUT", json.encode(rows), {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})
	end, "GET", "", {Authorization = "Basic " .. auth})
end

function exposedDB.getDocumentByRow(db, row, value, callback)
	local qu = {selector = {[row] = value}}
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/_find", function(err, rText, headers)
		local t = json.decode(rText)

		if(t)then
			if t.docs then
				if(t.docs[1])then
					callback(t.docs[1])
				else
					callback(false)
				end
			else
				callback(false)
			end
		else
			callback(false, rText)
		end
	end, "POST", json.encode(qu), {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})		
end

function exposedDB.updateDocument(db, documentID, updates, callback)
	PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/" .. documentID, function(err, rText, headers)
		local doc = json.decode(rText)

		if(doc)then
			for i in pairs(updates)do
				doc[i] = updates[i]
			end

			PerformHttpRequest("http://" .. ip .. ":" .. port .. "/" .. db .. "/" .. doc._id, function(err, rText, headers)
				callback((err or true))
			end, "PUT", json.encode(doc), {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})
		end
	end, "GET", "", {["Content-Type"] = 'application/json', Authorization = "Basic " .. auth})	
end

AddEventHandler('es:exposeDBFunctions', function(cb)
	cb(exposedDB)
end)

-- Why the fuck is this required?
local theTestObject, jsonPos, jsonErr = json.decode('{"test":"tested"}')