/*
 * @flow strict-local
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import typeBubble from '../edit/typeBubble.js';

const typeIdField = 'select[name=edit-label\\.type_id]';
typeBubble(typeIdField);
