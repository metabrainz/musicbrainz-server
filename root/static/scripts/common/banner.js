// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const $ = require('jquery');

const setCookie = require('./utility/setCookie');

$(function () {
    $('.dismiss-banner').on('click', function () {
        var bannerName = $(this).parent().remove().end().data('banner-name');

        setCookie(bannerName + '_dismissed_mtime', Math.ceil(Date.now() / 1000));
    });
});
