local execQueue = {}
local execQueueArgNum = 1
local execResults = {}
local curRoutine

_i = { _a = '_i' }
_f = { _a = '_f' }

function GetResult(argNum)
    if not execResults[argNum] then
        if #execQueue > 0 then
            execQueue.idx = getIdx()

            curRoutine = coroutine.running()
            coroutine.yield()

            execQueue = {}
        end
    end

    local r = execResults[argNum]
    execResults[argNum] = nil

    return r
end

function HandleResults(results)
    for k, v in pairs(results) do
        execResults[k] = v
    end

    if coroutine.status(curRoutine) == 'dead' then
        return
    end

    local success, err = coroutine.resume(curRoutine)

    if success then
        SendEvents({ getSource = getSource })
    else
        print(err)
    end
end

function SendEvents(env)
    TriggerClientEvent('svRpc:run', getSource(), 10, execQueue)
end

function CallNative(hash, ...)
    local arguments = {}
    local returns = {}

    local arg = {...}

    for i, v in ipairs(arg) do
        local a = v

        if type(v) == 'table' then
            if v._a then
                if v._a == '_i' or v._a == '_f' then
                    a._i = execQueueArgNum
                    execQueueArgNum = execQueueArgNum + 1

                    local fakeRetVal = {
                        _a = '_z',
                        _i = a._i
                    }

                    -- this will only work in Lua 5.2+; as metamethod yielding got added there
                    setmetatable(fakeRetVal, {
                        __call = function()
                            if not fakeRetVal._value then
                                fakeRetVal._value = GetResult(fakeRetVal._i)
                            end

                            return fakeRetVal._value
                        end
                    })

                    table.insert(returns, fakeRetVal)
                end
            end
        end

        table.insert(arguments, a)
    end

    table.insert(execQueue, {
        h = hash,
        a = arguments
    })

    return table.unpack(returns)
end

function PrintStringWithLiteralString(...) return CallNative(0x3F89280B, ...) end
function PrintStringWithLiteralStringNow(...) return CallNative(0xCA539D6, ...) end
function GetCharCoordinates(...) return CallNative(0x2B5C06E6, ...) end
function GetPlayerChar(...) return CallNative(0x511454A9, ...) end
