/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  HighlightT,
  LinkRelationshipStateT,
} from './types.js';

export const DEFAULT_LINK_RELATIONSHIP: LinkRelationshipStateT = {
  beginDate: null,
  dialogState: null,
  editsPending: false,
  endDate: null,
  ended: false,
  entityCredit: '',
  error: null,
  id: 0,
  linkTypeID: null,
  originalState: null,
  removed: false,
  url: '',
  video: false,
};

export const HIGHLIGHTS = {
  ADD: 'rel-add' as HighlightT,
  EDIT: 'rel-edit' as HighlightT,
  NONE: '' as HighlightT,
  REMOVE: 'rel-remove' as HighlightT,
} as const;
