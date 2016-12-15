function colorize(str)
{
    const s = "<span>" + (str.replace(/\^([0-9])/g, (str, color) => `</span><span class="color-${color}">`)) + "</span>";
    return s.replace(/<span[^>]*><\/span[^>]*>/g, '');
}

$(function()
{
    var chatHideTimeout;
    var inputShown = false;

    function startHideChat()
    {
        if (chatHideTimeout)
        {
            clearTimeout(chatHideTimeout);
        }

        if (inputShown)
        {
            return;
        }

        chatHideTimeout = setTimeout(function()
        {
            if (inputShown)
            {
                return;
            }

            $('#chat').animate({ opacity: 0 }, 300);
        }, 7000);
    }

    handleResult = function(elem, wasEnter)
    {
        inputShown = false;

        $('#chatInputHas').hide();

        startHideChat();

        var obj = {};

        if (wasEnter)
        {
            obj = { message: $(elem).val() };
        }

        $(elem).val('');

        $.post('http://chat/chatResult', JSON.stringify(obj), function(data)
        {
            console.log(data);
        });
    };

    $('#chatInput').fakeTextbox(); // //

    $('#chatInput')[0].onPress(function(e)
    {
        if (e.which == 13)
        {
            handleResult(this, true);
        }
    });

    $(document).keyup(function(e)
    {
        if (e.keyCode == 27)
        {
            handleResult($('#chatInput')[0].getTextBox(), false);
        }
    });

    $(document).keydown(function(e)
    {
        if (e.keyCode == 9)
        {
            e.preventDefault();
            return false;
        }
        else if (e.keyCode == 33)
        {
            let buf = $('#chatBuffer');
            buf.scrollTop(buf.scrollTop() - 50);
        }
        else if (e.keyCode == 34)
        {
            let buf = $('#chatBuffer');
            buf.scrollTop(buf.scrollTop() + 50);
        }
    });

    window.addEventListener('message', function(event)
    {
        var item = event.data;

        if (item.meta && item.meta == 'openChatBox')
        {
            inputShown = true;

            $('#chat').stop().css('opacity', '1');

            $('#chatInputHas').show();
            $('#chatInput')[0].doFocus();

            return;
        }

        // TODO: use some templating stuff for this
        var colorR = parseInt(item.color[0]);
        var colorG = parseInt(item.color[1]);
        var colorB = parseInt(item.color[2]);

        var name = item.name.replace('<', '&lt;');
        var message = item.message.replace('<', '&lt;');

        name = colorize(name);
        message = colorize(message);

        var buf = $('#chatBuffer');

        var nameStr = '';

        if (name != '')
        {
            nameStr = '<strong style="color: rgb(' + colorR + ', ' + colorG + ', ' + colorB + ')">' + name + ': </strong>';
        }

        buf.find('ul').append('<li>' + nameStr + message + '</li>');
        buf.scrollTop(buf[0].scrollHeight - buf.height());

        $('#chat').stop().css('opacity', '1');

        startHideChat();
    }, false);
});
