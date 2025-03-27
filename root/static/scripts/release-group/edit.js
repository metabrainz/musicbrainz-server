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
import {initGuessFeatButton} from '../edit/utility/guessFeat.js';
import initializeValidation from '../edit/validation.js';

$(function () {
  initGuessFeatButton('edit-release-group');
  initializeArtistCredit('edit-release-group');
  installFormUnloadWarning();
  initializeValidation();
});
