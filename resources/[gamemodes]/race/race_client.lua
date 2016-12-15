local curCheckpoint, nextCheckpoint
local goGoGo

local playerCar
local weFinished
local resultsShown

local checkpoints = {}
local playerScores = {}

local function initializeMap()
    echo("[RACE] initializeMap\n")

    TriggerServerEvent('race:updateCheckpoints', checkpoints)
end

local function resetGameMode()
    curCheckpoint = nil
    nextCheckpoint = nil

    SetMultiplayerHudTime('')

    checkpointCount = 0
    playerScores = {}

    if IsThisMachineTheServer() then
        -- load the initial map
        initializeMap()
    end

    goGoGo = false
    weFinished = false
    resultsShown = false
end

local function updatePositions()
    local players = {}

    for id, data in pairs(playerScores) do
        data.playerId = id

        table.insert(players, data)
    end

    table.sort(players, function(a, b)
        if a.finishPosition or b.finishPosition then
            if not b.finishPosition then
                return true
            end

            if not a.finishPosition then
                return false
            end

            return a.finishPosition < b.finishPosition
        end

        if a.cp == b.cp then
            local aPed = a.ped
            local bPed = b.ped

            local aPos
            local bPos

            if not DoesCharExist(aPed) or not DoesCharExist(bPed) then
                aPos = { 0, 0 }
                bPos = { 0, 0 }
            else
                aPos = a.ped.position
                bPos = b.ped.position
            end

            local nextCp = checkpoints[a.cp + 1]

            if not nextCp then
                return a.cp > b.cp
            end

            local aDist = GetDistanceBetweenCoords2d(aPos[1], aPos[2], nextCp.pos[1], nextCp.pos[2])
            local bDist = GetDistanceBetweenCoords2d(bPos[1], bPos[2], nextCp.pos[1], nextCp.pos[2])

            return aDist < bDist
        end

        return a.cp > b.cp
    end)

    if not playerScores[GetPlayerId().serverId] then
        return
    end

    local lastPosition = selfLastPosition

    local i = 1

    for _, v in ipairs(players) do
        playerScores[v.playerId].position = i

        i = i + 1
    end

    local selfPosition = playerScores[GetPlayerId().serverId].position
    selfLastPosition = selfPosition

    if selfPosition ~= lastPosition then
        TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'position changed to ' .. tostring(selfPosition) .. ' from ' .. tostring(lastPosition))
    end


    -- positions updated, we hope
end

AddEventHandler('race:onPlayerFinished', function(player, data)
    local selfId = GetPlayerId().serverId

    if not playerScores[player] then
        local ped = sPlayer.ped

        playerScores[player] = {
            cp = #checkpoints,
            ped = ped,
            vehicle = ped.vehicle
        }
    end

    playerScores[player].finishPosition = data.position

    if selfId == player then
        exports.obituary:printObituary('New world record!')

        TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'you finished!')

        weFinished = true

        tearDownCheckpoint(curCheckpoint)
        tearDownCheckpoint(nextCheckpoint)

        -- todo: spectate?

        CreateThread(function()
            Wait(500)

            if playerCar then
                FreezeCarPosition(playerCar, true)
            end
        end)
    end

    local sPlayer = GetPlayerByServerId(player)

    if sPlayer then
        exports.obituary:printObituary('<b>%s</b> finished in %s seconds', sPlayer.name, tostring(data.finishSeconds))
    end
end)

AddEventHandler('onClientGameTypeStart', function()
    CreateThread(function()
        --[[while true do
            Wait(500)

            local player = GetPlayerId()

            TriggerServerEvent('race:updatePos', player.ped.position)
        end]]
    end)

    CreateThread(function()
        while true do
            Wait(250)

            updatePositions()
        end
    end)
end)

function GetPlayerInteger(i)
    local serverId = i.serverId
    local players = GetPlayers()

    for k, v in ipairs(players) do
        if v.serverId == serverId then
            return k
        end
    end

    return 1
end

local function spawnVehicle(spawnPoint)
    local carModel

    if not spawnPoint.carModel then
        carModel = 'admiral'
    else
        carModel = spawnPoint.carModel
    end

    if not tonumber(carModel) then
        carModel = GetHashKey(carModel, _r)
    end

    -- is the model actually a model?
    if not IsModelInCdimage(carModel) then
        error("invalid spawn model")
    end

    -- is is even a vehicle?
    if not IsThisModelAVehicle(carModel) then
        error("this model ain't a vehicle!")
    end

    -- spawn a vehicle for our lovely player
    RequestModel(carModel)
    LoadAllObjectsNow()

    playerCar = CreateCar(carModel, spawnPoint.x, spawnPoint.y, spawnPoint.z, 0, 1)
    SetCarHeading(playerCar, spawnPoint.heading)
    SetCarOnGroundProperly(playerCar)

    WarpCharIntoCar(GetPlayerId().ped, playerCar)

    if not goGoGo then
        FreezeCarPosition(playerCar, true)
    end

    LockCarDoors(playerCar, 4)

    -- and done, hopefully.
end

AddEventHandler('race:itsGoTime', function()
    if playerCar then
        -- let go of the brakes
        FreezeCarPosition(playerCar, false)
    end

    -- gogogo
    goGoGo = true
end)

string.lpad = function(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

AddEventHandler('race:results', function(time)
    if playerCar then
        FreezeCarPosition(playerCar, true)
    end

    tearDownCheckpoint(curCheckpoint)
    tearDownCheckpoint(nextCheckpoint)

    SetMultiplayerHudTime('')

    updatePositions()

    local players = {}

    for id, data in pairs(playerScores) do
        table.insert(players, data)
    end

    table.sort(players, function(a, b) return a.position < b.position end)

    TriggerEvent('chatMessage', '', { 0, 0, 0 }, 'RESULTS')

    for i, p in ipairs(players) do
        local name = '**INVALID**'
        local sp = GetPlayerByServerId(p.playerId)

        if sp then
            name = sp.name
        end

        TriggerEvent('chatMessage', '', { 0, 0, 0 }, tostring(i) .. '. ' .. name)
    end
end)

AddEventHandler('race:hurryUp', function(time)
    CreateThread(function()
        echo("resultsShown: " .. tostring(resultsShown) .. " , weF: " .. tostring(weFinished) .. "\n")

        while not resultsShown and not weFinished do
            Wait(1000)

            time = time - 1000

            SetMultiplayerHudTime('00:' .. tostring(math.floor(time / 1000)):lpad(2, '0'))
            echo(tostring(math.floor(time / 1000)):lpad(2, '0') .. ':' .. tostring(math.floor((time % 1000) / 100)):lpad(2, '0') .. "\n")
        end
    end)
end)

AddEventHandler('race:showGoMessage', function(message)
    TriggerEvent('chatMessage', '', { 0, 0, 0 }, message)
end)

AddEventHandler('onClientMapStart', function(res)
    resetGameMode()

    requestedGo = true

    TriggerServerEvent('race:requestGo')
end)

AddEventHandler('onClientMapStop', function(res)
    DoScreenFadeOut(50)
end)

AddEventHandler('race:weGotPorn', function()
    echo("[RACE] race:weGotPorn\n")

    if not requestedGo then
        return
    end

    requestedGo = false

    exports.spawnmanager:setAutoSpawn(false)

    exports.spawnmanager:spawnPlayer(GetPlayerInteger(GetPlayerId()), function(spawnPoint)
        spawnVehicle(spawnPoint)
    end)

    TriggerServerEvent('race:requestCheckpoint', '1234')
end)

local function setUpCheckpoint(cp, next)
    local nextPos, typeNum

    if next then
        nextPos = next.pos
        typeNum = 2
    else
        nextPos = { 0.0, 0.0, 0.0 }
        typeNum = 3
    end

    -- 2 = regular 'ground', 3 = finish 'ground', others are different 3dmarker types
    cp.handle = CreateCheckpoint(typeNum, cp.pos[1], cp.pos[2], cp.pos[3] + 2.5, nextPos[1], nextPos[2], nextPos[3], 1.0001, _r)
    cp.blip = AddBlipForCoord(cp.pos[1], cp.pos[2], cp.pos[3], _i)

    if cp == nextCheckpoint then
        ChangeBlipScale(cp.blip, 0.8)
    end

    ChangeBlipSprite(cp.blip, 3)
end

function tearDownCheckpoint(cp)
    if not cp then
        return
    end

    if cp.blip then
        RemoveBlip(cp.blip)
        cp.blip = nil
    end

    if cp.handle then
        DeleteCheckpoint(cp.handle)
        cp.handle = nil
    end
end

AddEventHandler('race:setCheckpoint', function(cur, next, later)
    if curCheckpoint then
        tearDownCheckpoint(curCheckpoint)
    end

    if nextCheckpoint then
        tearDownCheckpoint(nextCheckpoint)
    end

    curCheckpoint = cur
    nextCheckpoint = next

    if cur then
        setUpCheckpoint(curCheckpoint, nextCheckpoint)

        -- make a background thread waiting for the checkpoint to be reached
        CreateThread(function()
            local localCur = curCheckpoint

            -- so we exit if the checkpoint target is changed
            while curCheckpoint == localCur do
                Wait(25)

                if playerCar then
                    local px, py, pz = GetCarCoordinates(playerCar)
                    local distance = GetDistanceBetweenCoords2d(px, py, localCur.pos[1], localCur.pos[2])

                    if distance < 10 then
                        -- pass the fact we reached the checkpoint to the server
                        TriggerServerEvent('race:gotCP', '1234')

                        break
                    end
                end
            end
        end)
    end

    if next then
        setUpCheckpoint(nextCheckpoint, later)
    end
end)

AddEventHandler('race:confirmCP', function()
    PlayAudioEvent('FRONTEND_GAME_PICKUP_CHECKPOINT')
end)

AddEventHandler('race:updateStatus', function(player, curCP)
    if curCP == -1 then
        playerScores[player] = nil
    end

    local sPlayer = GetPlayerByServerId(player)

    if not sPlayer then
        return
    end

    local ped = sPlayer.ped

    playerScores[player] = {
        cp = curCP,
        ped = ped,
        vehicle = ped.vehicle
    }

    TriggerEvent('chatMessage', '', { 0, 0, 0 }, sPlayer.name .. ' now has cp ' .. curCP)

    updatePositions()
end)

AddEventHandler('onClientMapStop', function()
    if playerCar then
        MarkCarAsNoLongerNeeded(playerCar)
        playerCar = nil
    end

    if curCheckpoint and curCheckpoint.handle then
        DeleteCheckpoint(curCheckpoint.handle)
    end

    if nextCheckpoint and nextCheckpoint.handle then
        DeleteCheckpoint(nextCheckpoint.handle)
    end
end)

AddEventHandler('getMapDirectives', function(add)
    -- call the remote callback
    add('checkpoint', function(state, data)
        table.insert(checkpoints, data)

        state.add('pos', data.pos)

        -- delete callback follows on the next line
    end, function(state, arg)
        for i, sp in ipairs(checkpoints) do
            if sp.pos[1] == state.pos[1] and sp.pos[2] == state.pos[2] and sp.pos[3] == state.pos[3] then
                table.remove(checkpoints, i)
                return
            end
        end
    end)
end)
