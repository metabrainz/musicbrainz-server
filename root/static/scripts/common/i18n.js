// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const isNodeJS = require('detect-node');
const Jed = require('jed');
const _ = require('lodash');
const React = require('react');
const sliced = require('sliced');

let gettext;
if (isNodeJS) {
    // Avoid bundling this module in the browser by using a dynamic require().
    let nodeGettext = '../../../server/gettext';
    gettext = require(nodeGettext).getHandle('en')
} else {
    gettext = new Jed(require('jed-data'));
}

exports.setGettextHandle = function (handle) {
    gettext = handle;
};

function wrapGettext(method) {
    return function () {
        var args = sliced(arguments);
        var expandArgs = args[args.length - 1];

        if (expandArgs && typeof expandArgs === "object") {
            args.pop();
        } else {
            expandArgs = null;
        }

        // FIXME support domains other than mb_server
        args.unshift('mb_server');
        var string = gettext[method].apply(gettext, args);

        if (expandArgs) {
            let react = expandArgs.__react;
            if (react) {
                let parts = expandToArray(string, expandArgs);
                if (react === 'frag') {
                    return <frag>{parts}</frag>;
                }
                return parts;
            }
            return exports.expand(string, expandArgs);
        }

        return string;
    };
}

var l = wrapGettext("dgettext");
var ln = wrapGettext("dngettext");

var __dpgettext = wrapGettext("dpgettext");
function lp() {
    // Swap order of context, msgid.
    return __dpgettext.call(null, arguments[1], arguments[0], arguments[2]);
}

exports.l = l;
exports.ln = ln;
exports.lp = lp;

// From https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
var regExpChars = /([.*+?^=!:${}()|\[\]\/\\])/g;

function escapeRegExp(string) {
    return string.replace(regExpChars, "\\$1");
}

function getExpandRegExps(args) {
    var re = _(args).keys().map(escapeRegExp).join('|');

    return {
        links: new RegExp(`\\{(${re})\\|(.*?)\\}`, 'g'),
        names: new RegExp(`\\{(${re})\\}`, 'g')
    };
}

function varReplacement(args, key) {
    return _.get(args, key, `{${key}}`);
}

function anchor(args, hrefProp, textProp, callback) {
    let href = args[hrefProp];

    if (href === undefined) {
        return `{${hrefProp}|${textProp}}`;
    }

    return callback(_.isObject(href) ? href : {href: href}, _.get(args, textProp, textProp));
}

function textAnchor(props, text) {
    let attributes = _(props).keys().sort().map(k => `${k}="${_.escape(props[k])}"`).join(' ');

    return `<a ${attributes}>${_.escape(text)}</a>`;
}

function reactAnchor(props, text) {
    return <a key={props.href} {...props}>{text}</a>;
}

// Adapted from `sub _expand` in lib/MusicBrainz/Server/Translation.pm
exports.expand = function (string, args) {
    let {links, names} = getExpandRegExps(args);

    return (string || '')
        .replace(links, (match, p1, p2) => anchor(args, p1, p2, textAnchor))
        .replace(names, (match, p1) => varReplacement(args, p1));
};

function expandToArray(string, args) {
    if (!string) {
        return [];
    }

    let {links, names} = getExpandRegExps(args);
    let parts = string.split(links);

    return parts.reduce(function (accum, part, index) {
        if (index % 3 === 0) {
            let nameParts = part.split(names).reduce(function (accum2, part2, index2) {
                if (index2 % 2 === 0) {
                    return part2 ? accum2.concat(part2) : accum2;
                }

                return accum2.concat(varReplacement(args, part2));
            }, []);

            return accum.concat(nameParts);
        }

        if ((index - 1) % 3 === 0) {
            return accum.concat(anchor(args, part, parts[index + 1], reactAnchor));
        }

        return accum;
    }, []);
}

var documentLang = 'en';
if (typeof document !== 'undefined') {
    documentLang = document.documentElement.lang || documentLang;
}

var collatorOptions = { numeric: true };
var collator;

if (typeof Intl === "undefined") {
    exports.compare = function (a, b) {
        return a.localeCompare(b, documentLang, collatorOptions);
    };
} else {
    collator = new Intl.Collator(documentLang, collatorOptions);
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
