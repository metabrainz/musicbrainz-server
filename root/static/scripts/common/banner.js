// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var $ = require('jquery');
var setCookie = require('./utility/setCookie');

$(function () {
    $('.dismiss-alert').on('click', function () {
        setCookie('alert_dismissed_mtime', Math.ceil(Date.now() / 1000));
        $(this).parent().remove();
    });
});
