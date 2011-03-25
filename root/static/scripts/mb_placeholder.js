/*
 * jQuery Placeholder Plugin.
 * http://github.com/mudge/jquery_placeholder
 *
 * A plugin to make HTML5's placeholder attribute work in non-HTML5-supporting
 * browsers.
 *
 * Copyright (c) Paul Mucur (http://mucur.name), 2010.
 * Licensed under the MIT licence (see LICENSE.txt).
 */

/*
   Adapted for MusicBrainz, January 2011, Kuno Woudt <kuno@frob.nl>.
   Copyright 2011 MetaBrainz Foundation

   Usage:

   This plugin no longer provides placeholder functionality automatically for
   all elements.  You may wish to call the following on document ready:

       $("[placeholder]").mb_placeholder (); 

   Furthermore, a feature has been added.  When the 'submit_placeholder_if_empty'
   is set the placeholder will be submitted as the value of the input when the
   form is submitted and the value hasn't otherwise been set.  This means that
   even on browsers which natively support placeholders this plugin will bind a
   submit handler.

   You can set the option like this:

       var options = { 'submit_placeholder_if_empty': true };
       $('input').mb_placeholder (options);

 */

(function($) {

    $.fn.mb_placeholder = function (options) {

        var placeholderNative = function ($elem) {
            $elem.parents('form:first').bind ('submit.mb_placeholder', function() {
                var options = $elem.data ('mb_placeholder');
                if (!options.submit_placeholder_if_empty)
                    return;

                if ($elem.val () === '')
                {
                    $elem.val ($elem.attr ('placeholder'));
                }
            })
        };

        var placeholderNonNative = function ($elem, options) {

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
                    $elem.addClass (classname).val ($elem.attr ('placeholder'));
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

            $elem.parents('form:first').bind ('submit.mb_placeholder', function() {
                var options = $elem.data ('mb_placeholder');
                if (options && options.submit_placeholder_if_empty)
                    return;

                $elem.triggerHandler('focus');
            });

            $elem.triggerHandler('blur');
        };

        var placeholder = function (elem) {

            var $elem = $(elem);
            var elemdata = $elem.data ('mb_placeholder');

            /* overwrite existing values (if any) with newly supplied options. */
            elemdata = elemdata ? elemdata : {};
            $.extend (elemdata, options);

            if (elemdata && elemdata.bound)
            {
                /* already bound to this element.  So only update the
                   options, the caller may simply want to change those. */
                $elem.data ('mb_placeholder', elemdata);
                $elem.triggerHandler('focus');
                $elem.triggerHandler('blur');
                return;
            }

            elemdata.bound = true;
            $elem.data ('mb_placeholder', elemdata);

            if ('placeholder' in elem)
            {
                return placeholderNative ($elem);
            }
            else
            {
                return placeholderNonNative ($elem);
            }

        };

        return this.each (function (idx, elem) {
            placeholder (elem);
        });
    };

}) (jQuery);

