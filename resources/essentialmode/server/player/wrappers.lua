--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

local user = {}

function user.setModel(model)
	if type(model) == "string" then model = GetHashKey(model) end

	if IsModelValid(model) then
		SetPlayerModel(PlayerPedId(), model)
		return true
	else
		return false
	end
end

function user.getRGBColour()
	local _, r, g, b = GetPlayerRgbColour(PlayerId())
	return {r = r, g = g, b = b}
end

function user.getTeam()
	return GetPlayerTeam(PlayerId())
end

function user.setTeam(team)
	SetPlayerTeam(PlayerId(), team)
end

function user.getName()
	return GetPlayerName(PlayerId())
end

function user.setWantedLevel(level)
	SetPlayerWantedLevel(PlayerId(), level, false)
	SetPlayerWantedLevelNow(PlayerId(), true)
end

function user.isDead()
	return IsPlayerDead(PlayerId())
end

function user.isPressingHorn()
	return IsPlayerPressingHorn(PlayerId())
end

function user.setControl(toggle, flags)
	SetPlayerControl(PlayerId(), toggle, flags)
end

function user.getWantedLevel()
	return GetPlayerWantedLevel(PlayerId())
end

function user.setMaxWantedLevel(maxWantedLevel)
	SetMaxWantedLevel(maxWantedLevel)
end

function user.ignorePolice(toggle)
	SetPoliceIgnorePlayer(PlayerId(), toggle)
end

function user.isPlaying()
	return IsPlayerPlaying(PlayerId())
end

function user.setWantedLevelMultiplier(multiplier)
	SetWantedLevelMultiplier(multiplier)
end

function user.setWantedLevelDifficulty(difficulty)
	SetWantedLevelDifficulty(PlayerId(), difficulty)
end

function user.resetWantedLevelDifficulty()
	ResetWantedLevelDifficulty(PlayerId())
end

function user.reportCrime(crimeType, wantedLvlThresh)
	return ReportCrime(PlayerId(), crimeType, wantedLvlThresh)
end

function user.canStartMission()
	return CanPlayerStartMission(PlayerId())
end

function user.isTargettingEntity(entity)
	return IsPlayerTargettingEntity(PlayerId(), entity)
end

function user.getTargetEntity()
	local _, entity = GetPlayerTargetEntity(PlayerId())
	return entity
end

function user.isFreeAiming()
	return IsPlayerFreeAiming(PlayerId())
end

function user.isFreeAimingAtEntity(entity)
	return IsPlayerFreeAimingAtEntity(PlayerId(), entity)
end

function user.getFreeAimingEntity()
	local _, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
	return entity
end

function user.setLockonRangeOverride(range)
	SetPlayerLockonRangeOverride(PlayerId(), range)
end

function user.setCanDoDriveBy(toggle)
	SetPlayerCanDoDriveBy(PlayerId(), toggle)
end

function user.setCanUseCover(toggle)
	SetPlayerCanUseCover(PlayerId(), toggle)
end

function user.isTargettingAnything()
	return IsPlayerTargettingAnything(PlayerId())
end

function user.setSprinting(toggle)
	return SetPlayerSprint(PlayerId(), toggle)
end

function user.resetStamina()
	ResetPlayerStamina(PlayerId())
end

function user.restoreStamina(p1)
	RestorePlayerStamina(PlayerId(), p1)
end

function user.getGroup()
	return GetPlayerGroup(PlayerId())
end

function user.getMaxArmour()
	return GetPlayerMaxArmour(PlayerId())
end

function user.isInControl()
	return IsPlayerControlOn(PlayerId())
end

function user.isClimbing()
	return IsPlayerClimbing(PlayerId())
end

function user.isBeingArrested(atArresting)
	return IsPlayerBeingArrested(PlayerId(), atArresting)
end

function user.getLastVehicle()
	return GetPlayersLastVehicle()
end

function user.getPed()
	return PlayerPedId()
end

function user.setInvincible(toggle)
	SetPlayerInvincible(PlayerId(), toggle)
end

function user.isInVehicle(vehicle, atGetIn)
	return IsPedInVehicle(PlayerPedId(), vehicle, atGetIn)
end

function user.isInAnyVehicle(atGetIn)
	return IsPedInAnyVehicle(PlayerPedId(), atGetIn)
end

function user.isInjured()
	return IsPedInjured(PlayerPedId())
end

function user.isHurt()
	return IsPedHurt(PlayerPedId())
end

function user.isFatallyInjured()
	return IsPedFatallyInjured(PlayerPedId())
end

function user.isDeadOrDying()
	return IsPedDeadOrDying(PlayerPedId(), 1)
end

function user.isAimingFromCover()
	return IsPedAimingFromCover(PlayerPedId())
end

function user.isReloading()
	return IsPedReloading(PlayerPedId())
end

function user.isInMeleeCombat()
	return IsPedInMeleeCombat(PlayerPedId())
end

function user.isStopped()
	return IsPedStopped(PlayerPedId())
end

function user.isShooting()
	return IsPedShooting(PlayerPedId())
end

function user.setAccuracy(accuracy)
	SetPedAccuracy(PlayerPedId(), accuracy)
end

function user.getAccuracy()
	return GetPedAccuracy(PlayerPedId())
end

function user.setArmour(amount)
	SetPedArmour(PlayerPedId(), amount)
end

function user.setPedIntoVehicle(vehicle, seatIndex)
	SetPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
end

function user.isMale()
	return IsPedMale(PlayerPedId())
end

function user.isHuman()
	return IsPedHuman(PlayerPedId())
end

function user.getVehicle(lastVehicle)
	return GetVehiclePedIsIn(ped, lastVehicle or false)
end

function user.isOnVehicle()
	return IsPedOnVehicle(PlayerPedId())
end

function user.isOnFoot()
	return IsPedOnFoot(PlayerPedId())
end

function user.isOnAnyBike()
	return IsPedOnAnyBike(PlayerPedId())
end

function user.isPlantingBomb()
	return IsPedPlantingBomb(PlayerPedId())
end

function user.isInAnyBoat()
	return IsPedInAnyBoat(PlayerPedId())
end

function user.isInAnySub()
	return IsPedInAnySub(PlayerPedId())
end

function user.isInAnyHeli()
	return IsPedInAnyHeli(PlayerPedId())
end

function user.isInAnyPlane()
	return IsPedInAnyPlane(PlayerPedId())
end

function user.isInFlyingVehicle()
	return IsPedInFlyingVehicle(PlayerPedId())
end

function user.setDiesInWater(toggle)
	SetPedDiesInWater(PlayerPedId(), toggle)
end

function user.setDiesInSinkingVehicle(toggle)
	SetPedDiesInSinkingVehicle(PlayerPedId(), toggle)
end

function user.getArmour()
	return GetPedArmour(PlayerPedId())
end

function user.setCanBeShotInVehicle(toggle)
	SetPedCanBeShotInVehicle(PlayerPedId(), toggle)
end

function user.isInPoliceVehicle()
	return IsPedInAnyPoliceVehicle(PlayerPedId())
end

function user.isFalling()
	return IsPedFalling(PlayerPedId())
end

function user.isJumping()
	return IsPedJumping(PlayerPedId())
end

function user.isClimbing()
	return IsPedClimbing(PlayerPedId())
end

function user.isVaulting()
	return IsPedVaulting(PlayerPedId())
end

function user.isDiving()
	return IsPedDiving(PlayerPedId())
end

function user.isJumpingOutOfVehicle()
	return IsPedJumpingOutOfVehicle(PlayerPedId())
end

function user.isDucking()
	return IsPedDucking(PlayerPedId())
end

function user.isInTaxi()
	return IsPedInAnyTaxi(PlayerPedId())
end

function user.setAsGroupLeader(groupId)
	SetPedAsGroupLeader(PlayerPedId(), groupId)
end

function user.setAsGroupMember(groupId)
	SetPedAsGroupMember(PlayerPedId(), groupId)
end

function user.getType()
	return GetPedType(PlayerPedId())
end

function user.setCoords(xPos, yPos, zPos, xAxis, yAxis, zAxis, clearArea)
	SetEntityCoords(PlayerPedId(), xPos, yPos, zPos, xAxis or 0.0, yAxis or 0.0, zAxis or 0.0, clearArea or false)
end

function getUser()
	return user
end