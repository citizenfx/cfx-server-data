RegisterNetEvent("SendAlert")
AddEventHandler("SendAlert", function()
    SendNUIMessage({
        type    = "alert",
        enable  = true,
        volume  = Config.meme.Volume
    })
end)