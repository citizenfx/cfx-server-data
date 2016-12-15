-- serving the duties of the office of the host

-- two functions from GTA script; they do 'something lock-ish'
local function acquireHostLock()
    if IsThisMachineTheServer() then
        SetThisMachineRunningServerScript(true)
        return true
    end

    return false
end

local function releaseHostLock()
    SetThisMachineRunningServerScript(false)
end

-- handle msgGetReadyToStartPlaying sending
function serviceHostStuff()
    -- acquire the host lock
    if acquireHostLock() then
        -- check if players want to join
        for i = 0, 31 do
            -- does this index?
            if PlayerWantsToJoinNetworkGame(i) then
                -- well, get ready to start playing!
                TellNetPlayerToStartPlaying(i, 0)

                TriggerServerEvent('playerJoining', i)
            end
        end

        -- release the host lock
        releaseHostLock()
    end
end

-- host service loop
CreateThread(function()
    NetworkSetScriptLobbyState(false)
    SwitchArrowAboveBlippedPickups(true)
    UsePlayerColourInsteadOfTeamColour(true)
    LoadAllPathNodes(true)
    SetSyncWeatherAndGameTime(true)

    while true do
        Wait(0)

        serviceHostStuff()

        -- launch the local player, for the initial host scenario
        if LocalPlayerIsReadyToStartPlaying() then
            LaunchLocalPlayerInNetworkGame()
        end
    end
end)
