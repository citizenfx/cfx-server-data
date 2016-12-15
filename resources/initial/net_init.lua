local function launchGame()
	-- TODO: replace with the actual game mode the joined session is running
	--StartResource('citizen')
	TriggerEvent('gameModeStarted')

	--StopResource('initial')
end

local function showError(err)
	ForceLoadingScreen(0)
	SetMsgForLoadingScreen(err)

	echo(err .. "\n")

	return "exit"
end

CreateThread(function()
	Wait(50)

	AllowThisScriptToBePaused(false)
	SetNoResprays(false)
	ThisScriptIsSafeForNetworkGame()

	if IsPlayerPlaying(GetPlayerIndex()) then
		SetPlayerControl(GetPlayerIndex(), false)
	end

	-- setup default callbacks
	exports.session:reset()

	AddEventHandler('sessionStateChanged', function(state)
		if state == 'find' then
			SetLoadingText('Finding games...')
		elseif state == 'host' then
			SetLoadingText('Creating game...')
		end
	end)

	AddEventHandler('sessionJoining', function(cur, max, hostName)
		SetLoadingText('Joining game ' .. cur .. ' of ' .. max .. '... (' .. hostName .. ')')
	end)

	AddEventHandler('sessionJoined', launchGame)
	AddEventHandler('sessionHosted', launchGame)

	AddEventHandler('sessionHostFailed', function(err)
		echo("hosting game failed: " .. err .. "\n")
		showError("NICON_MT")

		ShutdownAndLaunchSinglePlayerGame()
	end)

	local sessionList
	local curJoinSession = 0

	local joinFailed = function()
		exports.session:hostSession(16, 32)
	end

	AddEventHandler('sessionJoinFailed', function()
		curJoinSession = curJoinSession + 1

		if curJoinSession > #sessionList then
			joinFailed()
			return
		end

		exports.session:joinSession(sessionList[curJoinSession])
	end)

	AddEventHandler('sessionsFound', function(sessions)
		if #sessions == 0 then
			joinFailed()
			return
		end

		sessionList = sessions

		curJoinSession = 1
		exports.session:joinSession(sessionList[curJoinSession])
	end)

	exports.session:findSessions(16)
end)
