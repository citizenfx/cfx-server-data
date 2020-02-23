--       Licensed under: AGPLv3        --
--  GNU AFFERO GENERAL PUBLIC LICENSE  --
--     Version 3, 19 November 2007     --

-- Metric API
local MetricsAPIRequest = "https://api.kanersps.pw/em/metrics?uuid=" .. _UUID

function postMetrics()
	PerformHttpRequest(MetricsAPIRequest, function(err, rText, headers) end, "POST", "", {
		startingCash = settings.defaultSettings['startingCash'],
		startingBank = settings.defaultSettings['startingBank'],
		enableRankDecorators = settings.defaultSettings['enableRankDecorators'],
		nativeMoneySystem = settings.defaultSettings['nativeMoneySystem'],
		commandDelimeter = settings.defaultSettings['commandDelimeter'],
		enableLogging = settings.defaultSettings['enableLogging'],
		enableCustomData = settings.defaultSettings['enableCustomData'],
		defaultDatabase = settings.defaultSettings['defaultDatabase']
	})
end

-- Post metrics periodically while server is running.
Citizen.CreateThread(function()
	while true do
		postMetrics()
		Citizen.Wait(3600000)
	end
end)