/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import initializeValidation from '../edit/validation.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

$(function () {
  initializeGuessCase('instrument', 'id-edit-instrument');
  initializeValidation();
});
