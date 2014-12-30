// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (i18n) {

    var jed = new (require('jed'))(MB_LANGUAGE === 'en' ? {} : require('jed-' + MB_LANGUAGE));
    var slice = Array.prototype.slice;

    function wrapGettext(method) {
        return function () {
            var args = slice.call(arguments, 0);
            var expandArgs = args[args.length - 1];

            if (expandArgs && typeof expandArgs === "object") {
                args.pop();
            } else {
                expandArgs = null;
            }

            var string = jed[method].apply(jed, args);
            return expandArgs ? i18n.expand(string, expandArgs) : string;
        };
    }

    i18n.l = wrapGettext("gettext");
    i18n.ln = wrapGettext("ngettext");
    var __pgettext = wrapGettext("pgettext");

    i18n.lp = function () {
        // Swap order of context, msgid.
        return __pgettext.call(null, arguments[1], arguments[0], arguments[2]);
    };

    // From https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
    var regExpChars = /([.*+?^=!:${}()|\[\]\/\\])/g;

    function escapeRegExp(string) { return string.replace(regExpChars, "\\$1") }


    // Adapted from `sub _expand` in lib/MusicBrainz/Server/Translation.pm
    i18n.expand = function (string, args) {
        var re = _(args).keys().map(escapeRegExp).join("|");

        var links = new RegExp("\\{(" + re + ")\\|(.*?)\\}", "g");
        var names = new RegExp("\\{(" + re + ")\\}", "g");

        string = (string || "").replace(links, function (match, p1, p2) {
            var v1 = args[p1];
            var v2 = args[p2];

            if (v1 === undefined) return match;

            var text = _.escape(v2 === undefined ? p2 : v2);

            if (_.isObject(v1)) {
                return "<a " + _(v1).keys().sort()
                    .map(function (key) { return key + '="' + _.escape(v1[key]) + '"' })
                    .join(" ") + ">" + text + "<\/a>";
            } else {
                return "<a href=\"" + _.escape(v1) + "\">" + text + "<\/a>";
            }
        });

        string = string.replace(names, function (match, p1) {
            var v1 = args[p1];

            return v1 === undefined ? p1 : v1;
        });

        return string;
    };


    i18n.commaList = function (items) {
        var count = items.length;

        if (count <= 1) {
            return items[0] || "";
        }

        var output = i18n.l("{almost_last_list_item} and {last_list_item}", {
            last_list_item: items[count - 1],
            almost_last_list_item: items[count - 2]
        });

        items = items.slice(0, -2).reverse();
        count -= 2;

        for (var i = 0; i < count; i++) {
            output = i18n.l("{list_item}, {rest}", { list_item: items[i], rest: output });
        }

        return output;
    };


    var lang = document.documentElement.lang || "en",
        collatorOptions = { numeric: true };

    if (typeof Intl === "undefined") {
        i18n.compare = function (a, b) { return a.localeCompare(b, lang, collatorOptions) };
    } else {
        var collator = new Intl.Collator(lang, collatorOptions);
        i18n.compare = function (a, b) { return collator.compare(a, b) };
    }

    i18n.addColon = function (variable) {
        return i18n.l("{variable}:", { variable: variable });
    };

    i18n.strings = {};

    i18n.strings.entityName = {
        area:           i18n.l("Area"),
        artist:         i18n.l("Artist"),
        instrument:     i18n.l("Instrument"),
        label:          i18n.l("Label"),
        place:          i18n.l("Place"),
        recording:      i18n.l("Recording"),
        release:        i18n.l("Release"),
        release_group:  i18n.l("Release group"),
        series:         i18n.lp("Series", "singular"),
        url:            i18n.l("URL"),
        work:           i18n.l("Work")
    };

    i18n.strings.addANewEntity = {
        artist:         i18n.l("Add a new artist"),
        label:          i18n.l("Add a new label"),
        place:          i18n.l("Add a new place"),
        recording:      i18n.l("Add a new recording"),
        release_group:  i18n.l("Add a new release group"),
        series:         i18n.l("Add a new series"),
        work:           i18n.l("Add a new work")
    };

    i18n.strings.addAnotherEntity = {
        area:           i18n.l("Add another area"),
        artist:         i18n.l("Add another artist"),
        instrument:     i18n.l("Add another instrument"),
        label:          i18n.l("Add another label"),
        place:          i18n.l("Add another place"),
        recording:      i18n.l("Add another recording"),
        release:        i18n.l("Add another release"),
        release_group:  i18n.l("Add another release group"),
        series:         i18n.l("Add another series"),
        work:           i18n.l("Add another work")
    };

}(MB.i18n = {}));
