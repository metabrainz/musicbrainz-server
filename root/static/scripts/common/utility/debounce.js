// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';

function debounce(value, delay) {
    if (!ko.isObservable(value)) {
        value = ko.computed(value);
    }
    if (process.env.MUSICBRAINZ_RUNNING_TESTS) {
        return value;
    }
    return value.extend({
        rateLimit: {method: "notifyWhenChangesStop", timeout: delay || 500},
    });
}

export default debounce;
