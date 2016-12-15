AddEventHandler('onClientResourceStart', function(name)
    if name == GetCurrentResource() then
        local x, y = GetHudPosition('HUD_RADAR')
        local w, h = GetHudSize('HUD_RADAR')

        x = x - 0.01
        w = w + 0.02

        if GetIsWidescreen() then
            x = x / 1.333
            w = w / 1.333
        end

        exports.channelfeed:addChannel('obituary', {
            method = 'append',
            styleUrl = 'nui://obituary/obituary.css',
            styles = { -- temporary
                left = tostring(x * 100) .. '%',
                bottom = 'calc(' .. tostring((1 - y) * 100) .. '% + 10px)',
                width = tostring(w * 100) .. '%'
            },
            template = '<div class="item">{{{text}}}</div>'
        })
    end
end)

function printObituary(format, ...)
    local args = table.pack(...)

    for i = 1, args.n do
        if type(args[i]) == 'string' then
            args[i] = args[i]:gsub('<', '&lt;')
        end
    end

    echo("obituary: printObituary\n")

    exports.channelfeed:printTo('obituary', {
        text = string.format(format, table.unpack(args))
    })
end

--[[AddEventHandler('chatMessage', function(name, color, message)
    exports.channelfeed:printTo('obituary', {
        text = message:gsub('<', '&lt;')
    })
end)]]

AddEventHandler('onClientResourceStop', function()
    -- todo: remove channel
end)
