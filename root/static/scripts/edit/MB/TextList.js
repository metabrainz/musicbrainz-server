/*
 * Copyright (C) 2012 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import MB from '../../common/MB.js';

MB.Form = (MB.Form) ? MB.Form : {};

MB.Form.TextList = function (input) {
  var template = input + '-template';
  var self = {};
  var $template = $('.' + template.replace(/\./g, '\\.'));
  var counter = 0;

  self.removeEvent = function () {
    $(this).closest('div.text-list-row').remove();
  };

  self.init = function (maxIndex) {
    counter = maxIndex;
    $template
      .parent()
      .find('div.text-list-row input.value')
      .siblings('button.remove-item')
      .bind('click.mb', self.removeEvent);

    return self;
  };

  self.add = function (initValue) {
    $template.clone()
      .removeClass(template)
      .insertAfter($template
        .parent()
        .find('div.text-list-row')
        .last())
      .show()
      .find('input.value')
      .attr('name', input + '.' + counter)
      .val(initValue)
      .end()
      .find('button.remove-item')
      .bind('click.mb', self.removeEvent);

    counter++;

    return self;
  };

  $template.parent().find('button.add-item').bind('click.mb', function () {
    self.add('');
  });

  return self;
};
