AddEventHandler('onClientMapStart', function()
	Citizen.Trace("ocms fivem\n")

    exports.spawnmanager:setAutoSpawn(true)
    exports.spawnmanager:forceRespawn()
    Citizen.Trace("ocms fivem end\n")
end)
