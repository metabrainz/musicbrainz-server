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

  initializeBubble('#name-bubble', 'input[name=edit-artist\\.name]');
  initializeBubble(
    '#sort-name-bubble',
    'input[name=edit-artist\\.sort_name]',
  );
  initializeBubble('#comment-bubble', 'input[name=edit-artist\\.comment]');
  initializeBubble('#gender-bubble', 'select[name=edit-artist\\.gender_id]');
  initializeBubble('#ipi-bubble', 'input[name=edit-artist\\.ipi_codes\\.0]');
  initializeBubble(
    '#isni-bubble',
    'input[name=edit-artist\\.isni_codes\\.0]',
  );
  initializeBubble(
    '#begin-end-date-bubble',
    'input[name^=edit-artist\\.period\\.begin_date\\.], ' +
      'input[name^=edit-artist\\.period\\.end_date\\.]',
  );

  // Update the begin and end documentation bubbles to match the type.
  const updateBeginEndBubbles = () => {
    for (const sel of ['#begin-end-date-bubble', '#begin-end-area-bubble']) {
      $(sel + ' .desc').hide();
      const value = $(typeIdField)[0].value;
      const desc = $(sel + ` .desc-${value}`);
      if (desc.length) {
        desc.show();
      } else {
        $(sel + ' .desc-default').show();
      }
    }
  };
  $(typeIdField).on('change', () => updateBeginEndBubbles());
  updateBeginEndBubbles();

  /*
   * Display documentation bubbles for external components.
   * Area bubbles are initialized in ArtistEdit().
   */
  const externalLinkBubble = initializeBubble('#external-link-bubble');
  $(document).on(
    'focus',
    '#external-links-editor-container .external-link-item input.value',
    (event) => externalLinkBubble.show(event.target),
  );

  installFormUnloadWarning();

  initializeValidation();
});
