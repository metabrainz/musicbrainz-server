// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import NopArgs from './i18n/NopArgs';
import wrapGettext from './i18n/wrapGettext';

export const l = wrapGettext('dgettext', 'mb_server');
export const ln = wrapGettext('dngettext', 'mb_server');
export const lp = wrapGettext('dpgettext', 'mb_server');

function noop(func) {
    return (...args) => new NopArgs(func, args);
}

export const N_l = noop(l);
export const N_ln = noop(ln);
export const N_lp = noop(lp);

let documentLang = 'en';
if (typeof document !== 'undefined') {
    documentLang = document.documentElement.lang || documentLang;
}

const collatorOptions = { numeric: true };

export let compare;

if (typeof Intl === "undefined") {
    compare = function (a, b) {
        return a.localeCompare(b, documentLang, collatorOptions);
    };
} else {
    const collator = new Intl.Collator(documentLang, collatorOptions);
    compare = function (a, b) {
        return collator.compare(a, b);
    };
}

export function addColon(variable) {
    return l("{variable}:", { variable: variable });
};

export function hyphenateTitle(title, subtitle) {
    return l("{title} - {subtitle}", { title: title, subtitle: subtitle });
};

export const strings = {};

strings.entityName = {
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

strings.addANewEntity = {
    artist:         l("Add a new artist"),
    event:          l("Add a new event"),
    label:          l("Add a new label"),
    place:          l("Add a new place"),
    recording:      l("Add a new recording"),
    release_group:  l("Add a new release group"),
    series:         l("Add a new series"),
    work:           l("Add a new work")
};

strings.addAnotherEntity = {
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
