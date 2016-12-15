(function ($) {
    $.fn.fakeTextbox = function () {

        return this.each(function () {

            var $me = $(this),
                cursorTimer,
                $tb = $('<input type="text" class="fake" />');

            if ($me.data('ftbftw')) {
                console.log('already initialized');
                return;
            }

            $me.data('ftbftw', 1);

            $tb.insertAfter($me);

            function appendCaret(toHere, position, selStart, selEnd) {
                if (position === selStart) {
                    toHere += "</div><div class='caret'>";
                }
                if (position === selEnd) {
                    toHere += "</div><div>";
                }
                return toHere;
            }

            function syncTextbox() {
                var tbVal = $tb.val().replace('<', '&lt;');
                var tbLen = tbVal.length;
                var selStart = $tb.get(0).selectionStart;
                var selEnd = $tb.get(0).selectionEnd;
                var newOut = '<div>';

                for (var i = 0; i < tbLen; i++) {
                    newOut = appendCaret(newOut, i, selStart, selEnd);
                    newOut += tbVal[i];
                }

                $me.html(colorize(appendCaret(newOut, i, selStart, selEnd) + '</div>'));
                if (selStart != selEnd) {
                    $('.caret', $me).addClass('selection');
                }
            }

            $me.click(function () {
                $tb.focus();
            });

            $tb.bind("change keypress keyup", function()
            {
                setTimeout(syncTextbox, 1); //
            })
                .blur(function () {
                clearInterval(cursorTimer);
                cursorTimer = null;
                var $cursor = $('.caret', $me);
                $cursor.css({
                    visibility: 'visible'
                });
                $me.removeClass('focused');
            }).focus(function () {
                if (!cursorTimer) {
                    $me.addClass('focused');
                    cursorTimer = window.setInterval(function () {
                        var $cursor = $('.caret', $me);
                        if ($cursor.hasClass('selection') || $cursor.css('visibility') === 'hidden') {
                            $cursor.css({
                                visibility: 'visible'
                            });
                        } else {
                            $cursor.css({
                                visibility: 'hidden'
                            });
                        }
                    }, 500);
                }
            });

            this.doFocus = function()
            {
                $tb.focus();
            };

            this.onPress = function(f)
            {
                $tb.bind('keypress', f);
            };

            this.getTextBox = function()
            {
                return $tb;
            };

            syncTextbox();

            if ($me.hasClass('initFocus')) {
                $tb.focus();
            }
        });
    };
}(jQuery));
