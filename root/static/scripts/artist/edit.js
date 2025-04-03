/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import './components/ArtistCreditRenamer.js';
import '../edit/components/FormRowTextListSimple.js';
import '../relationship-editor/components/RelationshipEditorWrapper.js';

import initializeDuplicateChecker from '../edit/check-duplicates.js';
import {installFormUnloadWarning} from '../edit/components/forms.js';
import {initializeTooShortYearChecks} from '../edit/forms.js';
import ArtistEdit from '../edit/MB/Control/ArtistEdit.js';
import initializeBubble from '../edit/MB/Control/Bubble.js';
import typeBubble from '../edit/typeBubble.js';
import initializeToggleEnded from '../edit/utility/toggleEnded.js';
import initializeValidation from '../edit/validation.js';

$(function () {
  const typeIdField = 'select[name=edit-artist\\.type_id]';
  typeBubble(typeIdField);

  ArtistEdit();

  initializeDuplicateChecker('artist');

  initializeToggleEnded('id-edit-artist');
  initializeTooShortYearChecks('artist');

  initializeBubble('#sort-name-bubble', 'input[name=edit-artist\\.sort_name');
  initializeBubble('#ipi-bubble', 'input[name=edit-artist\\.ipi_codes\\.0]');
  initializeBubble(
    '#isni-bubble',
    'input[name=edit-artist\\.isni_codes\\.0]',
  );

  installFormUnloadWarning();

  initializeValidation();
});
