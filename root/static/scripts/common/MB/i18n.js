// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Released under the GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.txt

(function (i18n) {

    // From https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
    var regExpChars = /([.*+?^=!:${}()|\[\]\/\\])/g;

    function escapeRegExp(string) { return string.replace(regExpChars, "\\$1") }


    // Adapted from `sub _expand` in lib/MusicBrainz/Server/Translation.pm
    i18n.expand = function (string, args) {
        var re = _.chain(args).keys().map(escapeRegExp).value().join("|");

        var links = new RegExp("\\{(" + re + ")\\|(.*?)\\}", "g");
        var names = new RegExp("\\{(" + re + ")\\}", "g");

        string = string.replace(links, function (match, p1, p2) {
            var v1 = args[p1];
            var v2 = args[p2];

            if (v1 === undefined) return match;

            return "<a href=\"" + _.escapeHTML(v1) + "\">" +
                _.escapeHTML(v2 === undefined ? p2 : v2) + "<\/a>";
        });

        string = string.replace(names, function (match, p1) {
            var v1 = args[p1];

            return v1 === undefined ? p1 : v1;
        });

        return string;
    };

}(MB.i18n = {}));
