// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import leven from 'leven';

var punctuation = /[!"#$%&'()*+,\-.>\/:;<=>?¿@[\\\]^_`{|}~⁓〜\u2000-\u206F\s]/g;

function stripSpacesAndPunctuation(str) {
    return (str || '').replace(punctuation, '').toLowerCase();
}

// Compares two names, considers them equivalent if there are only case
// changes, changes in punctuation and/or changes in whitespace between
// the two strings.

export default function similarity(a, b) {
    // If a track title is all punctuation, we'll end up with an empty
    // string, so just fall back to the original for comparison.
    a = stripSpacesAndPunctuation(a) || a || '';
    b = stripSpacesAndPunctuation(b) || b || '';

    return 1 - (leven(a, b) / (a.length + b.length));
}
