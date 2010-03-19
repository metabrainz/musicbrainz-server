/*
 *       DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                 Version 2, December 2004
 *
 * Copyright (C) 2004 Sam Hocevar
 * 14 rue de Plaisance, 75014 Paris, France
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *
 *          DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 * TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *
 * 0. You just DO WHAT THE FUCK YOU WANT TO.
 */

(function($) {
    var n = 0, cache = {}, tag_char = '%';

    var lambda = function(tag) {
        var regexp = new RegExp('<'+tag+'([^\\x1a]*)\\+\\x1a', 'g'),
            str = $.trim(this.innerHTML)
                .replace(/\s*<!\[CDATA\[|\]\]>\s*/g, '')
                .replace(/[\r\n\t]/g, '')
                .split(tag+'>').join("+\x1a")
                .split('<'+tag+'=').join('\x1a+')
                .replace(regexp, "\x1a;$1t+=\x1a")
                .split("'").join("\\'")
                .split("\x1a").join("'");

        return new Function('i,j',
            "var t='" + str + "'; return t;"
        );
    };

    $.fn.jqote = function(data, tag) {
        var dom = [];

        if ( !$.isArray(data) ) data = [data];

        $(this).each(function(i) {
            var f = ( fn = cache[$.data(this, 'jqote')] ) ?
                fn : cache[$.data(this, 'jqote', n++)] = lambda.call(this, tag || tag_char);

            for ( j=0; j < data.length; j++ )
                dom.push(f.call(data[j], i, j));
        });

        return $(dom.join(''));
    };

    $.jqote_tag = function(c) {        
        tag_chr = c;
    };
})(jQuery);
