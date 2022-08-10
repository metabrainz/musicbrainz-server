/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import {initializeBubble} from '../edit/MB/Control/Bubble.js';

export default function typeBubble(typeIdField: string): void {
  initializeBubble('#type-bubble', typeIdField);
  $(typeIdField).on('change', function (this: HTMLSelectElement) {
    if (this.value.match(/\S/g)) {
      $('#type-bubble-default').hide();
      $('.type-bubble-description').hide();
      $(`#type-bubble-description-${this.value}`).show();
    } else {
      $('.type-bubble-description').hide();
      $('#type-bubble-default').show();
    }
  });
}
