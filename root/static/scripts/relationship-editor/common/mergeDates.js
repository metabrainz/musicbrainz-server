// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

function mergeDates(a, b) {
    var ay = a.year(), am = a.month(), ad = a.day();
    var by = b.year(), bm = b.month(), bd = b.day();

    var yConflict = ay && by && ay !== by;
    var mConflict = am && bm && am !== bm;
    var dConflict = ad && bd && ad !== bd;

    if (yConflict || mConflict || dConflict) {
        return null;
    }

    return { year: ay || by, month: am || bm, day: ad || bd };
}

module.exports = mergeDates;
