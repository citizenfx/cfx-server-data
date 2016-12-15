local eventBuffer = {}

AddUIHandler('getNew', function(data, cb)
    local localBuf = eventBuffer
    eventBuffer = {}

    cb(localBuf)
end)

function printTo(channel, data)
    table.insert(eventBuffer, {
        meta = 'print',
        channel = channel,
        data = data
    })

    PollUI()
end

function addChannel(id, options)
    if not options.template then
        return
    end

    options.id = id

    table.insert(eventBuffer, {
        meta = 'addChannel',
        data = options
    })

    PollUI()
end

function removeChannel(id)
    table.insert(eventBuffer, {
        meta = 'removeChannel',
        data = id
    })
end
