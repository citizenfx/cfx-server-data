-- local resource init stuff (similar to client resource_init)
RegisterInitHandler(function(initScript, isPreParse)
	local env = {
        _VERSION     = _VERSION,
        assert       = assert,
        error        = error,
        getmetatable = getmetatable,
        ipairs       = ipairs,
        next         = next,
        pairs        = pairs,
        pcall        = pcall,
        print        = print,
        rawequal     = rawequal,
        rawget       = rawget,
        rawlen       = rawlen,
        rawset       = rawset,
        select       = select,
        setmetatable = setmetatable,
        tonumber     = tonumber,
        tostring     = tostring,
        type         = type,
        xpcall       = xpcall,
        bit32 = {
            arshift = bit32.arshift,
            band    = bit32.band,
            bnot    = bit32.bnot,
            bor     = bit32.bor,
            btest   = bit32.btest,
            bxor    = bit32.bxor,
            extract = bit32.extract,
            lrotate = bit32.lrotate,
            lshift  = bit32.lshift,
            replace = bit32.replace,
            rrotate = bit32.rrotate,
            rshift  = bit32.rshift
        },
        coroutine = {
            create  = coroutine.create,
            resume  = coroutine.resume,
            running = coroutine.running,
            status  = coroutine.status,
            wrap    = coroutine.wrap,
            yield   = coroutine.yield
        },
        math = {
            abs        = math.abs,
            acos       = math.acos,
            asin       = math.asin,
            atan       = math.atan,
            atan2      = math.atan2,
            ceil       = math.ceil,
            cos        = math.cos,
            cosh       = math.cosh,
            deg        = math.deg,
            exp        = math.exp,
            floor      = math.floor,
            fmod       = math.fmod,
            frexp      = math.frexp,
            huge       = math.huge,
            ldexp      = math.ldexp,
            log        = math.log,
            max        = math.max,
            min        = math.min,
            modf       = math.modf,
            pi         = math.pi,
            pow        = math.pow,
            rad        = math.rad,
            random     = math.random,
            randomseed = math.randomseed,
            sin        = math.sin,
            sinh       = math.sinh,
            sqrt       = math.sqrt,
            tan        = math.tan,
            tanh       = math.tanh
        },
        string = {
            byte    = string.byte,
            char    = string.char,
            dump    = string.dump,
            find    = string.find,
            format  = string.format,
            gmatch  = string.gmatch,
            gsub    = string.gsub,
            len     = string.len,
            lower   = string.lower,
            match   = string.match,
            rep     = string.rep,
            reverse = string.reverse,
            sub     = string.sub,
            upper   = string.upper
        },
        table = {
            concat = table.concat,
            insert = table.insert,
            pack   = table.pack,
            remove = table.remove,
            sort   = table.sort,
            unpack = table.unpack
        }
	}

    TriggerEvent('getResourceInitFuncs', isPreParse, function(key, cb)
        env[key] = cb
    end)

    local pr = print

	if not isPreParse then
		env.server_scripts = function(n)
            if type(n) == 'string' then
                n = { n }
            end

            for _, d in ipairs(n) do
                AddServerScript(d)
            end
        end

        env.server_script = env.server_scripts
	else
		-- and add our native items
		env.solution = function(n)
			SetResourceInfo('clr_solution', n)
		end

		env.description = function(n)
			SetResourceInfo('description', n)
		end

		env.version = function(n)
			SetResourceInfo('version', n)
		end

        env.client_scripts = function(n)
            if type(n) == 'string' then
                n = { n }
            end

            for _, d in ipairs(n) do
                AddClientScript(d)
            end
        end

        env.client_script = env.client_scripts

        env.files = function(n)
            if type(n) == 'string' then
                n = { n }
            end

            for _, d in ipairs(n) do
                AddAuxFile(d)
            end
        end

        env.file = env.files

		env.dependencies = function(n)
			if type(n) == 'string' then
				n = { n }
			end

			for _, d in ipairs(n) do
				AddResourceDependency(d)
			end
		end

		env.dependency = env.dependencies
	end

    local rawget_ = rawget
    local print_ = print

	local mt = {
		__index = function(t, k) : object
            if env[k] ~= nil then
                return env[k]
            end

			if rawget_(t, k) ~= nil then
                return rawget_(t, k)
            end

			-- as we're not going to return nothing here (to allow unknown directives to be ignored)
			local f = function()
                return f
            end

            return function() return f end
		end
	}

    for k, v in pairs(env) do
        if type(v) == 'function' then
            env[k] = function(...)
                _G.__metatable = nil

                local rv = v(...)

                _G.__metatable = mt

                return rv
            end
        end
    end

    _G.__metatable = mt
	--setmetatable(env, mt)
	--setfenv(initScript, env)

	initScript()

    --env = nil

    --setfenv(initScript, _G)

    _G.__metatable = nil

--    print('rc', findallpaths(rt))
end)

-- nothing, yet

-- TODO: cleanup RPC environment stuff on coroutine end/error
local function RunRPCFunction(f, env)
    local co = coroutine.create(f)
    env.__co = client

    local success, err = coroutine.resume(co)

    if success then
        env.SendEvents()
    else
        print(err)
    end
end

local rpcIdx = 1
local rpcEnvironments = {}

function CreateRPCContext(cl, f)
    local idx = rpcIdx
    rpcIdx = rpcIdx + 1

    local key = cl .. '_' .. idx

    local env = {
        getIdx = function()
            return idx
        end,
        getSource = function()
            return cl
        end
    }

    local lastEnv = _ENV

    setmetatable(env, {__index = _G})

    local _ENV = env
    rpcEnvironments[key] = env

    setfenv(f, env)

    local fRun = f()

    local virtenv_init = loadfile('system/virtenv_init.lua', 't', env)
    virtenv_init()

    _ENV = lastEnv

    RunRPCFunction(fRun, env)
end

RegisterServerEvent('svRpc:results')

AddEventHandler('svRpc:results', function(results)
    if not results.idx then
        return
    end

    local key = source .. '_' .. results.idx

    if not rpcEnvironments[key] then
        return
    end

    rpcEnvironments[key].HandleResults(results)
end)
