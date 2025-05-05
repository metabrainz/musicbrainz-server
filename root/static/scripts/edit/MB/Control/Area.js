/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import EntityAutocomplete from '../../../common/MB/Control/Autocomplete.js';

import {BubbleDoc} from './Bubble.js';

export default function initializeArea(spanSelector, bubbleSelector) {
  const bubble = new BubbleDoc();
  ko.applyBindingsToNode($(bubbleSelector)[0], {bubble});

  $(spanSelector).each(function () {
    const name = $(this).find('input.name')[0];
    const ac = EntityAutocomplete({inputs: $(this)});
    ko.applyBindingsToNode(
      name, {controlsBubble: bubble}, {area: ac.currentSelection},
    );
  });
}
