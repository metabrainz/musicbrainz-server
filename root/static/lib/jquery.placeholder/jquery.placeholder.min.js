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
(function(a){a.placeholder={className:"jquery_placeholder",supportedNatively:function(c){var b=document.createElement(c);return"placeholder" in b},backwardsCompatibility:function(){if(!a.placeholder.supportedNatively("input")&&!a.placeholder.supportedNatively("textarea")){var b=":input"}else{if(!a.placeholder.supportedNatively("textarea")){var b="textarea"}else{var b=null}}if(b){a(window).unload(function(){a(b+"."+a.placeholder.className).val("")});a(b+"[placeholder]").each(function(){var c=a(this);var d=c.attr("placeholder");if(!c.attr("defaultValue")&&c.val()==d){c.val("")}c.blur(function(){if(this!=document.activeElement&&c.val()==""){c.addClass(a.placeholder.className).val(d)}}).focus(function(){if(c.hasClass(a.placeholder.className)){c.val("").removeClass(a.placeholder.className)}}).change(function(){if(c.hasClass(a.placeholder.className)){c.removeClass(a.placeholder.className)}}).parents("form:first").submit(function(){c.triggerHandler("focus")}).end().triggerHandler("blur")})}}};a(a.placeholder.backwardsCompatibility)})(jQuery);
