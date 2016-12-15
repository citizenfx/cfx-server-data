CreateThread(function()
	local bit = function()
		return math.random()
	end

	local function freezePlayer(id, freeze)
		local player = ConvertIntToPlayerindex(id)
		SetPlayerControlForNetwork(player, not freeze, false)

		local ped = GetPlayerChar(player, _i)

		if not freeze then
			if not IsCharVisible(ped) then
				SetCharVisible(ped, true)
			end

			if not IsCharInAnyCar(ped) then
				SetCharCollision(ped, true)
			end

			FreezeCharPosition(ped, false)
			SetCharNeverTargetted(ped, false)
			SetPlayerInvincible(player, false)
		else
			FreezeCharPosition(ped, true)
			SetCharNeverTargetted(ped, true)
			SetPlayerInvincible(player, true)

			if not IsCharFatallyInjured(ped) then
				--ClearCharTasksImmediately(ped)
			end
		end
	end

	local player = CreatePlayer(0, -2000.5 + bit(), -2000.5 + bit(), 240.5 + bit(), _i)

	freezePlayer(GetPlayerId(), true)

	SetLoadingText("this is too lovely")

	TriggerEvent('playerInfoCreated')
end)
