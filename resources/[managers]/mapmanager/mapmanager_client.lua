maps = {}
gametypes = {}

AddEventHandler('getResourceInitFuncs', function(isPreParse, add)
    if not isPreParse then
        add('map', function(file)
            addMap(file, GetInvokingResource())
        end)

        add('resource_type', function(type)
            return function(params)
                local resourceName = GetInvokingResource()

                if type == 'map' then
                    maps[resourceName] = params
                elseif type == 'gametype' then
                    gametypes[resourceName] = params
                end
            end
        end)
    end
end)

mapFiles = {}

function addMap(file, owningResource)
    if not mapFiles[owningResource] then
        mapFiles[owningResource] = {}
    end

    table.insert(mapFiles[owningResource], file)
end

AddEventHandler('onClientResourceStart', function(res)
    -- parse metadata for this resource

    -- map files
    local num = GetNumResourceMetadata(res, 'map')

    if num then
        for i = 0, num-1 do
            local file = GetResourceMetadata(res, 'map', i)

            if file then
                addMap(file, res)
            end
        end
    end

    -- resource type data
    local type = GetResourceMetadata(res, 'resource_type', 0)

    if type then
        Citizen.Trace("type " .. res .. " " .. type .. "\n")

        local extraData = GetResourceMetadata(res, 'resource_type_extra', 0)

        if extraData then
            extraData = json.decode(extraData)
        else
            extraData = {}
        end

        if type == 'map' then
            maps[res] = extraData
        elseif type == 'gametype' then
            gametypes[res] = extraData
        end
    end

    -- handle starting
    if mapFiles[res] then
        for _, file in ipairs(mapFiles[res]) do
            parseMap(file, res)
        end
    end

    -- defer this to the next game tick to work around a lack of dependencies
    Citizen.CreateThread(function()
        Citizen.Wait(15)

        if maps[res] then
            TriggerEvent('onClientMapStart', res)
        elseif gametypes[res] then
            TriggerEvent('onClientGameTypeStart', res)
        end
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if maps[res] then
        TriggerEvent('onClientMapStop', res)
    elseif gametypes[res] then
        TriggerEvent('onClientGameTypeStop', res)
    end

    if undoCallbacks[res] then
        for _, cb in ipairs(undoCallbacks[res]) do
            cb()
        end

        undoCallbacks[res] = nil
        mapFiles[res] = nil
    end
end)

undoCallbacks = {}

function parseMap(file, owningResource)
    if not undoCallbacks[owningResource] then
        undoCallbacks[owningResource] = {}
    end

    local env = {
        math = math, pairs = pairs, ipairs = ipairs, next = next, tonumber = tonumber, tostring = tostring,
        type = type, table = table, string = string, _G = env
    }

    TriggerEvent('getMapDirectives', function(key, cb, undocb)
        env[key] = function(...)
            local state = {}

            state.add = function(k, v)
                state[k] = v
            end

            local result = cb(state, ...)
            local args = table.pack(...)

            table.insert(undoCallbacks[owningResource], function()
                undocb(state)
            end)

            return result
        end
    end)

    local mt = {
        __index = function(t, k)
            if rawget(t, k) ~= nil then return rawget(t, k) end

            -- as we're not going to return nothing here (to allow unknown directives to be ignored)
            local f = function()
                return f
            end

            return function() return f end
        end
    }

    setmetatable(env, mt)
    
    local fileData = LoadResourceFile(owningResource, file)
    local mapFunction, err = load(fileData, file, 't', env)

    if not mapFunction then
        Citizen.Trace("Couldn't load map " .. file .. ": " .. err .. " (type of fileData: " .. type(fileData) .. ")\n")
        return
    end

    mapFunction()
end

AddEventHandler('getMapDirectives', function(add)
    add('vehicle_generator', function(state, name)
        return function(opts)
            local x, y, z, heading
            local color1, color2

            if opts.x then
                x = opts.x
                y = opts.y
                z = opts.z
            else
                x = opts[1]
                y = opts[2]
                z = opts[3]
            end

            heading = opts.heading or 1.0
            color1 = opts.color1 or -1
            color2 = opts.color2 or -1

            local hash = GetHashKey(name)
            RequestModel(hash)

            LoadAllObjectsNow()

            local carGen = CreateScriptVehicleGenerator(x, y, z, heading, 5.0, 3.0, hash, color1, color2, -1, -1, true, false, false, true, true, -1)
            SetScriptVehicleGenerator(carGen, true)
            SetAllVehicleGeneratorsActive(true)

            state.add('cargen', carGen)
        end
    end, function(state, arg)
        Citizen.Trace("deleting car gen " .. tostring(state.cargen) .. "\n")

        DeleteScriptVehicleGenerator(state.cargen)
    end)
end)
