/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

/*
 * Make sure click events within the dialog don't bubble and cause
 * side-effects.
 */

$(function () {
  $('body').on('click', '.ui-dialog', function (event) {
    event.stopPropagation();
  });
});
