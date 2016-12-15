-- more rline stuff, this does some late-term session management (which I think has some race condition with launching the network player?)
AddEventHandler('sessionInitialized', function()
    if IsThisMachineTheServer() then
        -- unknown stuff, seems needed though
        NetworkChangeExtendedGameConfigCit()

        CreateThread(function()
            Wait(1500)

            if not NetworkIsSessionStarted() then
                NetworkStartSession()

                while NetworkStartSessionPending() do
                    Wait(0)
                end

                if not NetworkStartSessionSucceeded() then
                    ForceLoadingScreen(0)
                    SetMsgForLoadingScreen("MO_SNI")

                    return
                end
            end
        end)
    end
end)
