// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const sliced = require('sliced');

const expand = require('./i18n/expand');
const NopArgs = require('./i18n/NopArgs');
const wrapGettext = require('./i18n/wrapGettext');

const l = wrapGettext('dgettext', 'mb_server');
const ln = wrapGettext('dngettext', 'mb_server');
const lp = wrapGettext('dpgettext', 'mb_server');

function noop() {
    return new NopArgs(sliced(arguments));
}

exports.l = l;
exports.ln = ln;
exports.lp = lp;
exports.N_l = noop;
exports.N_ln = noop;
exports.N_lp = noop;
exports.expand = expand;

let documentLang = 'en';
if (typeof document !== 'undefined') {
    documentLang = document.documentElement.lang || documentLang;
}

const collatorOptions = { numeric: true };

if (typeof Intl === "undefined") {
    exports.compare = function (a, b) {
        return a.localeCompare(b, documentLang, collatorOptions);
    };
} else {
    const collator = new Intl.Collator(documentLang, collatorOptions);
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
