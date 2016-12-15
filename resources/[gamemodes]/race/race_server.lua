local checkpoints = {}
local raceId = 0

RegisterServerEvent('race:updateCheckpoints')

AddEventHandler('race:updateCheckpoints', function(cps)
    if #checkpoints > 0 then
        return
    end

    checkpoints = cps

    TriggerClientEvent('race:weGotPorn', -1)
end)

local playerData = {}

local function ensurePlayerData(id)
    if playerData[id] then
        return
    end

    playerData[id] = {
        curCheckpoint = 0
    }
end

local raceStarted = false
local playerCount = 0

local function startRace()
    raceStarted = true

    print("really starting race")

    local function raceCountdown(num)
        local time = (4000 - (num * 1000))

        print("setting countdown for " .. tostring(time))

        SetTimeout(time, function()
            print("trig'd countdown for " .. tostring(time))

            if num == 0 then
                TriggerClientEvent('race:itsGoTime', -1, 0)
                TriggerClientEvent('race:showGoMessage', -1, 'GO')
            else
                TriggerClientEvent('race:showGoMessage', -1, tostring(num))
            end
        end)
    end

    raceCountdown(3) -- 3...
    raceCountdown(2) -- 2...
    raceCountdown(1) -- 1...
    raceCountdown(0) -- GOGOGO
end

local function incrementPlayerCount()
    playerCount = playerCount + 1

    if playerCount > 4 then
        startRace()
    end

    if playerCount == 1 then
        SetTimeout(3000, function()
            if raceStarted then
                return
            end

            print("starting race")

            startRace()
        end)
    end
end

local playersFinished
local raceEnded

AddEventHandler('onMapStart', function()
    playerCount = 0
    playersFinished = 0
    raceId = raceId + 1
    raceStarted = false
    raceEnded = false

    playerData = {}
    checkpoints = {}

    print("mmmmmm race")
end)

local function endRace()
    raceEnded = true

    TriggerClientEvent('race:results', -1, '1234')

    SetTimeout(7500, function()
        TriggerEvent('mapmanager:roundEnded')
    end)
end

AddEventHandler('race:onPlayerFinished', function(player)
    print(GetPlayerName(player) .. ' finished')

    local data = playerData[player]
    local finishSeconds = os.clock() - data.startTime

    local position = playersFinished + 1
    data.position = position
    playersFinished = position

    TriggerClientEvent('race:onPlayerFinished', -1, player, {
        finishSeconds = finishSeconds,
        position = position
    })

    if playersFinished == playerCount then
        endRace()
    elseif playersFinished == 1 then
        local thisRaceId = raceId

        TriggerClientEvent('race:hurryUp', -1, 30000)

        SetTimeout(30000, function()
            if raceId ~= thisRaceId or raceEnded then
                return
            end

            endRace()
        end)
    end
end)

AddEventHandler('playerActivated', function()
    if #checkpoints > 0 then
        TriggerClientEvent('race:weGotPorn', source)
    end
end)

RegisterServerEvent('race:requestGo')

AddEventHandler('race:requestGo', function()
    if #checkpoints > 0 then
        TriggerClientEvent('race:weGotPorn', source)
    end
end)

AddEventHandler('playerDropped', function(player)
    if playerData[player] and playerData[player].curCheckpoint > 0 then
        TriggerClientEvent('race:updateStatus', -1, player, -1)

        playerCount = playerCount - 1
    end
end)

RegisterServerEvent('race:gotCP')

AddEventHandler('race:gotCP', function()
    ensurePlayerData(source)

    local data = playerData[source]

    local next = data.curCheckpoint + 1

    if next > #checkpoints then
        print("omg finished")

        TriggerEvent('race:onPlayerFinished', source)

        return
    end

    data.curCheckpoint = next

    TriggerClientEvent('race:confirmCP', source) -- for sound effects
    TriggerClientEvent('race:setCheckpoint', source, checkpoints[next], checkpoints[next + 1], checkpoints[next + 2])
    TriggerClientEvent('race:updateStatus', -1, source, next - 1)
end)

RegisterServerEvent('race:requestCheckpoint')

AddEventHandler('race:requestCheckpoint', function()
    print('is it even in here')

    ensurePlayerData(source)

    print(source, 'requesting cp')

    if playerData[source].curCheckpoint == 0 then
        incrementPlayerCount()

        print(source, 'requesting cp 0')

        local curCP = 1
        playerData[source].curCheckpoint = curCP
        playerData[source].startTime = os.clock()

        TriggerClientEvent('race:setCheckpoint', source, checkpoints[curCP], checkpoints[curCP + 1], checkpoints[curCP + 2])
        TriggerClientEvent('race:updateStatus', -1, source, 0)

        -- should have raceReallyStarted since 4-second countdown
        if raceStarted then
            TriggerClientEvent('race:itsGoTime', -1, 0)
        end
    end
end)
