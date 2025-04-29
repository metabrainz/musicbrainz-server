/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import './RecordingName.js';
import '../edit/components/FormRowTextList.js';

import {
  initializeArtistCredit,
  installFormUnloadWarning,
} from '../edit/components/forms.js';
import initializeBubble, {
  initializeExternalLinksBubble,
} from '../edit/MB/Control/Bubble.js';
import {initGuessFeatButton} from '../edit/utility/guessFeat.js';
import initializeValidation from '../edit/validation.js';

$(function () {
  initGuessFeatButton('edit-recording');
  initializeArtistCredit('edit-recording');

  initializeBubble('#name-bubble', 'input[name=edit-recording\\.name]');
  initializeBubble('#artist-bubble', '#ac-source-single-artist');
  initializeBubble('#comment-bubble', 'input[name=edit-recording\\.comment]');
  initializeBubble('#length-bubble', 'input[name=edit-recording\\.length]');
  initializeBubble('#isrcs-bubble', 'input[name=edit-recording\\.isrcs\\.0]');
  initializeExternalLinksBubble('#external-link-bubble');

  installFormUnloadWarning();
  initializeValidation();
});
