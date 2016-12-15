(function() {
    var getLock = 0;

    var channels = {};

    var zoomLevel = '100%';

    $(function()
    {
        zoomLevel = Math.round(($(window).height() / 720) * 100) + '%'; // yay dynamic typing
    });

    function refetchData()
    {
        getLock = 0;

        $.get('http://channelfeed/getNew', function(data)
        {
            if (getLock > 1)
            {
                setTimeout(refetchData, 50);

                return;
            }

            getLock++;

            data.forEach(function(item)
            {
                switch (item.meta)
                {
                    case 'print':
                        var channel = item.channel;

                        if (!(channel in channels))
                        {
                            return;
                        }

                        channel = channels[channel];

                        var elem = $($.Mustache.render(item.channel, item.data, { method: channel.method })).appendTo(channel.$elem);

                        setTimeout(function()
                        {
                            elem.fadeOut(400, function()
                            {
                                elem.remove();
                            });
                        }, 7500);

                        break;

                    case 'addChannel':
                        var channel = item.data;

                        if (channel.id in channels)
                        {
                            return;
                        }

                        channel.$elem = $('<div></div>').attr('id', 'channel-' + channel.id).appendTo('#channels');

                        if (channel.styles !== undefined)
                        {
                            channel.$elem.css(channel.styles);
                        }

                        channel.$elem = $('<div></div>').css('zoom', zoomLevel).appendTo(channel.$elem);

                        if (channel.styleUrl !== undefined)
                        {
                            $('<link>').appendTo('head').attr({ type: 'text/css', rel: 'stylesheet' }).attr('href', channel.styleUrl);
                        }

                        $.Mustache.add(channel.id, channel.template);

                        channels[channel.id] = channel;

                        break;
                    case 'removeChannel':
                        var channelId = item.data;

                        if (channelId in channels)
                        {
                            channel.$elem.parent().remove();

                            delete channels[channelId];
                        }

                        break;
                    case 'clear':
                        var channel = item.channel;

                        if (!(channel in channels))
                        {
                            return;
                        }

                        channel = channels[channel];

                        channel.$elem.html();
                        break;
                }
            });
        });
    }

    window.addEventListener('message', function(event)
    {
        if (event.data.type != 'poll')
        {
            return;
        }

        refetchData();
    });
})();
