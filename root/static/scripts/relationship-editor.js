/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import './relationship-editor/components/RelationshipEditorWrapper.js';

import {
  getSourceEntityDataForRelationshipEditor,
} from './common/utility/catalyst.js';
import {createExternalLinksEditorForHtmlForm} from './edit/externalLinks.js';

const sourceData = getSourceEntityDataForRelationshipEditor();
const entityType = sourceData.entityType;

if (
  /*
   * Exclude React edit pages which use the <ExternalLinksEditor /> component
   * directly.
   */
  entityType !== 'genre'
) {
  createExternalLinksEditorForHtmlForm(
    'edit-' + entityType.replace('_', '-'),
  );
}
