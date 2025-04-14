/*
 * @flow
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import '../edit/components/FormRowTextListSimple.js';

import initializeDuplicateChecker from '../edit/check-duplicates.js';
import {installFormUnloadWarning} from '../edit/components/forms.js';
import initializeArea from '../edit/MB/Control/Area.js';
import initializeBubble from '../edit/MB/Control/Bubble.js';
import typeBubble from '../edit/typeBubble.js';
import initializeValidation from '../edit/validation.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

$(function () {
  const typeIdField = 'select[name=edit-label\\.type_id]';
  typeBubble(typeIdField);

  initializeGuessCase('label', 'id-edit-label');

  initializeArea('span.area.autocomplete');

  initializeDuplicateChecker('label');

  initializeBubble('#ipi-bubble', 'input[name=edit-label\\.ipi_codes\\.0]');
  initializeBubble('#isni-bubble', 'input[name=edit-label\\.isni_codes\\.0]');

  installFormUnloadWarning();

  initializeValidation();
});
