-- handles the script end of the flag the 'leave game' option in the pause menu sets
CreateThread(function()
    while true do
        Wait(0)

        -- if the flag is set
        if DoesGameCodeWantToLeaveNetworkSession() then
            -- if we're part of a started session; end it first (FIXME: will this break others when we're host?)
            if NetworkIsSessionStarted() then
                NetworkEndSession()

                -- wait for the session to be ended
                while NetworkEndSessionPending() do
                    Wait(0)
                end
            end

            -- attempt to leave the game
            NetworkLeaveGame()

            -- while we're waiting to leave...
            while NetworkLeaveGamePending() do
                Wait(0)
            end

            -- reinitialize the game as a network game (TODO: call into citigame for UI/NetLibrary leaving)
            --ShutdownAndLaunchNetworkGame(0) -- episode id is arg
            ShutdownNetworkCit('Left');
        end
    end
end)
