function colorize(string)
{
    var newString = '';
    var inSpan = false;

    for (i = 0; i < string.length; i++)
    {
        if (string[i] == '^')
        {
            if (string[i + 1] == '7' || string[i + 1] == '0')
            {
                if (inSpan)
                {
                    newString += '</span>';

                    inSpan = false;
                }

                i += 2;
            }
            else if (string[i + 1] >= '0' && string[i + 1] <= '9')
            {
                if (inSpan)
                {
                    newString += '</span>';
                }

                i += 2;
                newString += '<span class="color-' + string[i - 1] + '">';

                inSpan = true;
            }
        }

        newString += string[i];
    }

    if (inSpan)
    {
        newString += '</span>';
    }

    return newString;
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

    $(document).keypress(function(e)
    {
        if (e.keyCode == 9)
        {
            e.preventDefault();
            return false;
        }
    });

    window.addEventListener('message', function(event)
    {
        var item = event.data;

        if (item.meta && item.meta == 'openChatBox')
        {
            inputShown = true;

            $('#chat').css('opacity', '1');

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

        message = colorize(message);

        var buf = $('#chatBuffer');

        var nameStr = '';

        if (name != '')
        {
            nameStr = '<strong style="color: rgb(' + colorR + ', ' + colorG + ', ' + colorB + ')">' + name + ': </strong>';
        }

        buf.find('ul').append('<li>' + nameStr + message + '</li>');
        buf.scrollTop(buf[0].scrollHeight - buf.height());

        $('#chat').css('opacity', '1');

        startHideChat();
    }, false);
});
