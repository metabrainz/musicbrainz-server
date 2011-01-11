/*
 * jQuery Placeholder Plugin.
 * http://github.com/mudge/jquery_placeholder
 *
 * A plugin to make HTML5's placeholder attribute work in non-HTML5-supporting
 * browsers.
 *
 * Copyright (c) Paul Mucur (http://mucur.name), 2010.
 * Licensed under the MIT licence (see LICENSE.txt).
 *
 * Slightly adapted for MusicBrainz, January 2011, Kuno Woudt <kuno@frob.nl>.
 * Copyright 2011 MetaBrainz Foundation
 */

(function($) {

    $.fn.mb_placeholder = function () {

        var placeholder = function (elem) {

            if ('placeholder' in elem)
            {
                return; // natively supported.
            }

            var $elem = $(elem);
            var placeholder_value = $elem.attr ('placeholder');
            var classname = 'mb_placeholder';

            /* A fix for Internet Explorer caching placeholder form values even
             * when they are cleared on wndow unload.
             */
            if (!$elem.attr ('defaultValue') && $elem.val () == placeholder_value) {
                $elem.val ('');
            }

            $elem.bind ('blur.mb_placeholder', function () {

                /* As this handler is called on document ready make sure
                 * that the currently active element isn't populated with
                 * a placeholder.
                 */
                if (this != document.activeElement && $elem.val () == '') {
                    $elem.addClass (classname).val (placeholder_value);
                }
            });

            $elem.bind ('focus.mb_placeholder', function() {
                if ($elem.hasClass (classname)) {
                    $elem.val ('').removeClass (classname);
                }
            });

            $elem.bind ('change.mb_placeholder', function() {
                $elem.removeClass(classname);
            });

            $elem.parents('form:first').submit(function() {
                $elem.triggerHandler('focus');
            }).end().triggerHandler('blur');

        };

        return this.each (function (idx, elem) {
            placeholder (elem);
        });
    };

}) (jQuery);

