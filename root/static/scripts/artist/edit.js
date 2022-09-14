/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import './components/ArtistCreditRenamer.js';
import '../relationship-editor/components/RelationshipEditorWrapper.js';

import typeBubble from '../edit/typeBubble.js';

const typeIdField = 'select[name=edit-artist\\.type_id]';
typeBubble(typeIdField);
