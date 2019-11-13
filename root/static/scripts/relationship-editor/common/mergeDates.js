// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import nonEmpty from '../../common/utility/nonEmpty';
import parseIntegerOrNull from '../../common/utility/parseIntegerOrNull';

function conflict(a, b, prop) {
    return nonEmpty(a[prop]) && nonEmpty(b[prop]) && a[prop] !== b[prop];
}

var unwrapInteger = _.flow(ko.unwrap, parseIntegerOrNull);

function mergeDates(a, b) {
    a = _.mapValues(a, unwrapInteger);
    b = _.mapValues(b, unwrapInteger);

    if (conflict(a, b, 'year') || conflict(a, b, 'month') || conflict(a, b, 'day')) {
        return null;
    }

    /* eslint-disable no-multi-spaces */
    return {
        year:  nonEmpty(a.year)  ? a.year  : b.year,
        month: nonEmpty(a.month) ? a.month : b.month,
        day:   nonEmpty(a.day)   ? a.day   : b.day,
    };
    /* eslint-enable no-multi-spaces */
}

export default mergeDates;
