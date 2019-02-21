/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import setCookie from './utility/setCookie';

$(function () {
  $('.dismiss-banner').on('click', function () {
    const bannerName = $(this).parent().remove()
      .end()
      .data('banner-name');

    if (bannerName === 'birthday_message') {
      const oneDayFromNow = new Date(Date.now() + (1000 * 60 * 60 * 24));
      setCookie(
        bannerName + '_dismissed_mtime',
        Math.ceil(Date.now() / 1000),
        oneDayFromNow,
      );
    } else {
      setCookie(
        bannerName + '_dismissed_mtime',
        Math.ceil(Date.now() / 1000),
      );
    }
  });
});
