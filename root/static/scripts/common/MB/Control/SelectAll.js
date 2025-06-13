/*
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

export function initializeRangeSelect(selector, parent) {
  let lastChecked = null;
  $(parent || 'body').on(
    'click',
    selector,
    function (event) {
      const thisChecked = event.currentTarget;
      const $checkboxes = $(selector);

      if (event.shiftKey && lastChecked && lastChecked !== thisChecked) {
        const lastIndex = $checkboxes.index(lastChecked);
        const thisIndex = $checkboxes.index(thisChecked);
        const thisIsChecked = $(thisChecked).is(':checked');

        if (lastIndex > thisIndex) {
          $checkboxes.slice(thisIndex, lastIndex + 1)
            .filter(thisIsChecked ? ':not(:checked)' : ':checked')
            .trigger('click');
        } else if (thisIndex > lastIndex) {
          $checkboxes.slice(lastIndex, thisIndex + 1)
            .filter(thisIsChecked ? ':not(:checked)' : ':checked')
            .trigger('click');
        }
      }
      lastChecked = thisChecked;
    },
  );
}

export function initializeSelectAll(table) {
  const $table = $(table);
  const $checkboxes = $table.find('td input[type="checkbox"]');

  const $selector = $table.find('th input[type="checkbox"]');

  $selector.toggle($checkboxes.length > 0);

  $selector.change(function () {
    const $input = $(this);
    $checkboxes.prop('checked', $input.prop('checked'));
  });

  initializeRangeSelect('td input[type="checkbox"]', $table);
}

$(function () {
  $('table.tbl').each(function () {
    initializeSelectAll(this);
  });
});
