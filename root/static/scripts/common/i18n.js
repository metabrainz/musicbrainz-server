// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const NopArgs = require('./i18n/NopArgs');
const wrapGettext = require('./i18n/wrapGettext');

const l = wrapGettext('dgettext', 'mb_server');
const ln = wrapGettext('dngettext', 'mb_server');
const lp = wrapGettext('dpgettext', 'mb_server');

function noop(func) {
    return (...args) => new NopArgs(func, args);
}

exports.l = l;
exports.ln = ln;
exports.lp = lp;
exports.N_l = noop(l);
exports.N_ln = noop(ln);
exports.N_lp = noop(lp);

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

exports.hyphenateTitle = function (title, subtitle) {
    return exports.l("{title} - {subtitle}", { title: title, subtitle: subtitle });
};
