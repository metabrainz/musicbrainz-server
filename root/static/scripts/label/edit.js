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

import typeBubble from '../edit/typeBubble.js';
import initializeValidation from '../edit/validation.js';

$(function () {
  const typeIdField = 'select[name=edit-label\\.type_id]';
  typeBubble(typeIdField);

  initializeValidation();
});
