// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import test from 'tape';

import commaList from '../common/i18n/commaList';
import commaOnlyList from '../common/i18n/commaOnlyList';

test('commaList', function (t) {
    t.plan(5);

    t.equal(commaList([]), '', 'empty list');
    t.equal(commaList(['a']), 'a', 'list with one item');
    t.equal(commaList(['a', 'b']), 'a and b', 'list with two items');
    t.equal(commaList(['a', 'b', 'c']), 'a, b and c', 'list with three items');
    t.equal(commaList(['a', 'b', 'c', 'd']), 'a, b, c and d', 'list with four items');
});

test('commaOnlyList', function (t) {
    t.plan(5);

    t.equal(commaOnlyList([]), '', 'empty list');
    t.equal(commaOnlyList(['a']), 'a', 'list with one item');
    t.equal(commaOnlyList(['a', 'b']), 'a, b', 'list with two items');
    t.equal(commaOnlyList(['a', 'b', 'c']), 'a, b, c', 'list with three items');
    t.equal(commaOnlyList(['a', 'b', 'c', 'd']), 'a, b, c, d', 'list with four items');
});
