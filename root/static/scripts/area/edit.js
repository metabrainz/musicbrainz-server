/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import '../edit/components/FormRowTextList.js';
import '../edit/validation.js';

import typeBubble from '../edit/typeBubble.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

const typeIdField = 'select[name=edit-area\\.type_id]';
typeBubble(typeIdField);

initializeGuessCase('area', 'id-edit-area');
