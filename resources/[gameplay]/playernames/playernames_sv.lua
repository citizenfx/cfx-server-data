local curTemplate
local curTags = {}

local function detectUpdates()
    SetTimeout(500, detectUpdates)

    local template = GetConvar('playerNames_template', '[{{id}}] {{name}}')
    
    if curTemplate ~= template then
        setNameTemplate(-1, template)

        curTemplate = template
    end

    template = GetConvar('playerNames_svTemplate', '[{{id}}] {{name}}')

    for _, v in ipairs(GetPlayers()) do
        local newTag = formatPlayerNameTag(v, template)

        if newTag ~= curTags[v] then
            setName(v, newTag)

            curTags[v] = newTag
        end
    end
end



RegisterNetEvent('playernames:init')
AddEventHandler('playernames:init', function()
    reconfigure(source)
end)

SetTimeout(500, detectUpdates)
detectUpdates()