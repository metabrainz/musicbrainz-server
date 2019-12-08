/*
 * Copyright (C) 2010 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import MB from '../../MB';

MB.Control.SelectAll = function (table) {
  const self = {};

  self.$table = $(table);
  self.$checkboxes = self.$table.find('td input[type="checkbox"]');
  self.lastChecked = null;

  self.$selector = self.$table.find('th input[type="checkbox"]');

  self.$selector.toggle(self.$checkboxes.length > 0);

  self.$selector.change(function () {
    const $input = $(this);
    self.$checkboxes.prop('checked', $input.prop('checked'));
  });

  self.$checkboxes.click(function (event) {
    if (event.shiftKey && self.lastChecked && self.lastChecked !== this) {
      const first = self.$checkboxes.index(self.lastChecked);
      const last = self.$checkboxes.index(this);

      if (first > last) {
        self.$checkboxes.slice(last, first + 1)
          .prop('checked', this.checked);
      } else if (last > first) {
        self.$checkboxes.slice(first, last + 1)
          .prop('checked', this.checked);
      }
    }
    self.lastChecked = this;
  });

  return self;
};

$(function () {
  $('table.tbl').each(function () {
    MB.Control.SelectAll(this);
  });
});
