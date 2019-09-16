/*
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import MB from '../../MB';

MB.Control.RangeSelect = function ($checkboxes) {
  let lastChecked = null;
  $checkboxes.click(function (event) {
    const nowChecked = event.currentTarget;

    if (event.shiftKey && lastChecked && lastChecked !== nowChecked) {
      const first = $checkboxes.index(lastChecked);
      const last = $checkboxes.index(nowChecked);

      if (first > last) {
        $checkboxes.slice(last, first + 1)
          .prop('checked', nowChecked.checked);
      } else if (last > first) {
        $checkboxes.slice(first, last + 1)
          .prop('checked', nowChecked.checked);
      }
    }
    lastChecked = nowChecked;
  });
};

MB.Control.SelectAll = function (table) {
  const $table = $(table);
  const $checkboxes = $table.find('td input[type="checkbox"]');

  const $selector = $table.find('th input[type="checkbox"]');

  $selector.toggle($checkboxes.length > 0);

  $selector.change(function () {
    const $input = $(this);
    $checkboxes.prop('checked', $input.prop('checked'));
  });

  MB.Control.RangeSelect($checkboxes);
};

$(function () {
  $('table.tbl').each(function () {
    MB.Control.SelectAll(this);
  });
});
