// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import Jed from 'jed';
import jedData from 'jed-data';

var jedInstance = new Jed(jedData);
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

        var string = jedInstance[method].apply(jedInstance, args);
        return expandArgs ? exports.expand(string, expandArgs) : string;
    };
}

var l = wrapGettext("gettext");
var ln = wrapGettext("ngettext");

var __pgettext = wrapGettext("pgettext");
function lp() {
    // Swap order of context, msgid.
    return __pgettext.call(null, arguments[1], arguments[0], arguments[2]);
}

exports.l = l;
exports.ln = ln;
exports.lp = lp;

// From https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
var regExpChars = /([.*+?^=!:${}()|\[\]\/\\])/g;

function escapeRegExp(string) {
    return string.replace(regExpChars, "\\$1");
}

// Adapted from `sub _expand` in lib/MusicBrainz/Server/Translation.pm
exports.expand = function (string, args) {
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

exports.commaList = function (items) {
    var count = items.length;

    if (count <= 1) {
        return items[0] || "";
    }

    var output = l("{almost_last_list_item} and {last_list_item}", {
        last_list_item: items[count - 1],
        almost_last_list_item: items[count - 2]
    });

    items = items.slice(0, -2).reverse();
    count -= 2;

    for (var i = 0; i < count; i++) {
        output = l("{list_item}, {rest}", { list_item: items[i], rest: output });
    }

    return output;
};

exports.commaOnlyList = function (items) {
    var output = '';

    if (!items.length) {
        return output;
    }

    output = l('{last_list_item}', {last_list_item: items.pop()});
    items.reverse();

    _.each(items.reverse(), function (item) {
        output = l('{commas_only_list_item}, {rest}', {commas_only_list_item: item, rest: output});
    });

    return output;
};

var lang = document.documentElement.lang || "en";
var collatorOptions = { numeric: true };
var collator;

if (typeof Intl === "undefined") {
    exports.compare = function (a, b) {
        return a.localeCompare(b, lang, collatorOptions);
    };
} else {
    collator = new Intl.Collator(lang, collatorOptions);
    exports.compare = function (a, b) {
        return collator.compare(a, b);
    };
}

exports.addColon = function (variable) {
    return exports.l("{variable}:", { variable: variable });
};

exports.strings = {};

exports.strings.entityName = {
    area:           l("Area"),
    artist:         l("Artist"),
    event:          l("Event"),
    instrument:     l("Instrument"),
    label:          l("Label"),
    place:          l("Place"),
    recording:      l("Recording"),
    release:        l("Release"),
    release_group:  l("Release group"),
    series:         lp("Series", "singular"),
    url:            l("URL"),
    work:           l("Work")
};

exports.strings.addANewEntity = {
    artist:         l("Add a new artist"),
    event:          l("Add a new event"),
    label:          l("Add a new label"),
    place:          l("Add a new place"),
    recording:      l("Add a new recording"),
    release_group:  l("Add a new release group"),
    series:         l("Add a new series"),
    work:           l("Add a new work")
};

exports.strings.addAnotherEntity = {
    area:           l("Add another area"),
    artist:         l("Add another artist"),
    event:          l("Add another event"),
    instrument:     l("Add another instrument"),
    label:          l("Add another label"),
    place:          l("Add another place"),
    recording:      l("Add another recording"),
    release:        l("Add another release"),
    release_group:  l("Add another release group"),
    series:         l("Add another series"),
    work:           l("Add another work")
};
