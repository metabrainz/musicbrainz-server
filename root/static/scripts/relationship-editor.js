/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import './relationship-editor/components/RelationshipEditorWrapper.js';

import {
  getCatalystContext,
  getSourceEntityData,
} from './common/utility/catalyst.js';
import {
  createExternalLinksEditorForHtmlForm,
} from './external-links-editor/components/ExternalLinksEditor.js';

$(function () {
  const source = getSourceEntityData(getCatalystContext());
  const entityType = source.entityType;
  const reactEditors = ['event', 'genre'];

  if (
    /*
     * Exclude React edit pages which use the <ExternalLinksEditor />
     * component directly.
     */
    !reactEditors.includes(entityType)
  ) {
    createExternalLinksEditorForHtmlForm(
      'edit-' + entityType.replace('_', '-'),
    );
  }
});
