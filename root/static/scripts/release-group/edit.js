/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import {
  initializeArtistCredit,
  installFormUnloadWarning,
} from '../edit/components/forms.js';
import initializeBubble, {
  initializeExternalLinksBubble,
} from '../edit/MB/Control/Bubble.js';
import {initGuessFeatButton} from '../edit/utility/guessFeat.js';
import initializeValidation from '../edit/validation.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

$(function () {
  initGuessFeatButton('edit-release-group');
  initializeArtistCredit('edit-release-group');
  initializeGuessCase('release_group', 'id-edit-release-group');

  initializeBubble('#name-bubble', 'input[name=edit-release-group\\.name]');
  initializeBubble('#artist-bubble', '#ac-source-single-artist');
  initializeBubble(
    '#comment-bubble',
    'input[name=edit-release-group\\.comment]',
  );
  initializeBubble(
    '#primary-type-bubble',
    'select[name=edit-release-group\\.primary_type_id]',
  );
  initializeBubble(
    '#secondary-types-bubble',
    'select[name=edit-release-group\\.secondary_type_ids]',
  );
  initializeExternalLinksBubble('#external-link-bubble');

  installFormUnloadWarning();
  initializeValidation();
});
