-- state variable for session host lock
local sessionHostPending = false
local sessionHostResult

AddEventHandler('sessionHostResult', function(result)
    if not sessionHostPending then
        return
    end

    sessionHostResult = result
    sessionHostPending = false
end)

local attempts = 0

-- allow early script to create the player
AddEventHandler('playerInfoCreated', function()
    CreateThread(function()
        -- so that the game won't trigger the citizen disconnect handler
        SafeguardDisconnect(true)

        -- loop for 3 times
        while attempts < 3 do
            -- 'find' games (this will store the host session in memory, or if no host exists, tell us later)
            NetworkFindGame(16, false, 0, 0)

            -- we don't have to wait for the finding to complete; TestSessionFind.cpp in hooks_ny will instantly return
            local gamesFound = NetworkGetNumberOfGames(_r)

            -- if we found at least one game (if the game isn't hooked, this can be any amount; but
            -- we can't trust the implementation in that case anyway)
            local needsToHost = true -- whether we need to host after completing a possible join

            if gamesFound > 0 then
                -- join the game
                NetworkJoinGame(0)

                SetLoadingText('Entering session') -- status text

                -- wait for the join to complete
                while NetworkJoinGamePending() do
                    Wait(0)
                end

                -- if we succeeded, we're now a session member, and will not need to host
                if NetworkJoinGameSucceeded() then
                    needsToHost = false
                    break
                end
            end

            -- if we didn't find any games, or a join timed out, we'll *consider* hosting
            if needsToHost then
                -- make sure we don't have an actual other host waiting for us
                sessionHostPending = true -- to trigger a wait loop below

                TriggerServerEvent('hostingSession')

                SetLoadingText('Initializing session') -- some vague status text

                -- wait for the server to respond to our request
                while sessionHostPending do
                    Wait(0)
                end

                if sessionHostResult == 'wait' then
                    -- TODO: not implemented yet: wait for a message from the server, then attempt finding a game/joining a game again
                    sessionHostPending = true

                    while sessionHostPending do
                        Wait(0)
                    end

                    if sessionHostResult == 'free' then
                        goto endLoop
                    end
                end

                if sessionHostResult == 'conflict' and gamesFound > 0 then
                    -- there's already a host which is working perfectly fine; show a message to the player
                    --error('session creation conflict: could not connect to original host')
                    echo("session creation conflict\n")
                    goto endLoop
                end

                -- we got a green light to host; start hosting
                if not NetworkHostGameE1(16, false, 32, false, 0, 0) then
                    echo("session creation failure from NetworkHostGameE1\n")
                    error('failed to initialize session')
                end

                -- wait for internal processing to complete
                while NetworkHostGamePending() do
                    Wait(0)
                end

                -- another failure check
                if not NetworkHostGameSucceeded() then
                    echo("session creation failure from NetworkHostGameSucceeded\n")
                    error('failed to initialize session')
                end

                TriggerServerEvent('hostedSession')

                break
            end

            ::endLoop::
            attempts = attempts + 1
        end

        SafeguardDisconnect(false)

        if attempts >= 3 then
            error("Could not connect to session provider.")
        end

        SetLoadingText('Look at that!')

        -- signal local game-specific resources to start
        TriggerEvent('sessionInitialized')
        TriggerServerEvent('sessionInitialized')
    end)
end)
