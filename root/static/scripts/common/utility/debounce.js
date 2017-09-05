// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const ko = require('knockout');

function debounce(value, delay) {
    if (!ko.isObservable(value)) {
        value = ko.computed(value);
    }
    return value.extend({
        rateLimit: { method: "notifyWhenChangesStop", timeout: delay || 500 }
    });
}

module.exports = debounce;
