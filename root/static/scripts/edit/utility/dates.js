/*
 * Copyright (C) 2012-2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import getDaysInMonth from '../../../../utility/getDaysInMonth';
import nonEmpty from '../../common/utility/nonEmpty';
import parseInteger from '../../common/utility/parseInteger';

export const isDateValid = function (y, m, d) {
    y = nonEmpty(y) ? parseInteger(y) : null;
    m = nonEmpty(m) ? parseInteger(m) : null;
    d = nonEmpty(d) ? parseInteger(d) : null;

    // We couldn't parse one of the fields as a number.
    if (isNaN(y) || isNaN(m) || isNaN(d)) {
        return false;
    }

    // The year is a number less than 1.
    if (y !== null && y < 1) {
        return false;
    }

    // The month is a number less than 1 or greater than 12.
    if (m !== null && (m < 1 || m > 12)) {
        return false;
    }

    // The day is empty. There's no further validation we can do.
    if (d === null) {
        return true;
    }

    // Invalid number of days based on the year.
    if (d < 1 || d > 31 || d > getDaysInMonth(y, m)) {
        return false;
    }

    // The date is assumed to be valid.
    return true;
};

export const isYearFourDigits = function (y) {
    return (y === null || y === '' || y.length === 4);
};

export const isDatePeriodValid = function (a, b) {
    var y1 = a.year, m1 = a.month, d1 = a.day;
    var y2 = b.year, m2 = b.month, d2 = b.day;

    if (!isDateValid(y1, m1, d1) || !isDateValid(y2, m2, d2)) {
        return false;
    }

    if (!y1 || !y2 || +y1 < +y2) {
        return true;
    } else if (+y2 < +y1) {
        return false;
    }
    if (!m1 || !m2 || +m1 < +m2) {
        return true;
    } else if (+m2 < +m1) {
        return false;
    }
    if (!d1 || !d2 || +d1 < +d2) {
        return true;
    } else if (+d2 < +d1) {
        return false;
    }

    return true;
};
