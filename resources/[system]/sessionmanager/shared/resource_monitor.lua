-- resources
local resources = {}

-- Get all resources first
Citizen.CreateThread(function()
	local numResources = GetNumResources()
	for index = 0, numResources - 1 do
		local resourceName = GetResourceByFindIndex(index)
		if resources[resourceName] == nil then
			resources[resourceName] = false
		end
	end
end)

-- If a resource starts or stops, add it to resources with true
AddEventHandler('onResourceStart', function(resourceName) 
	resources[resourceName] = true
end)

AddEventHandler('onResourceStop', function(resourceName) 
	resources[resourceName] = false
end)

-- Export end users can use
function isResourceRunning(resourceName)
	if resources[resourceName] == nil then
		return
	end
	return resources[resourceName]
end