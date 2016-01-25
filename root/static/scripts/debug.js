// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2011 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');
const _ = require('lodash');

const getBooleanCookie = require('./common/utility/getBooleanCookie');
const setCookie = require('./common/utility/setCookie');

if (getBooleanCookie('catalyst-stats-open')) {
    $('#catalyst-stats').show();
}

$('#catalyst-stats-summary').on('click', function () {
    $('#catalyst-stats').toggle();

    setCookie('catalyst-stats-open', $('#catalyst-stats').is(':visible') ? '1' : '0');
});

$('#catalyst-stats table td.duration').each(function (idx, cell) {
    var parts = $(cell).text().split('.');

    if (parts.length === 2) {
        $(cell).html(_.escape(parts[0]) + '.<span class="fractional">' + _.escape(parts[1]) + '</span>');
    }
});
