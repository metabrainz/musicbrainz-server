/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {HighlightT} from './types.js';

/* eslint-disable import/prefer-default-export */

export const HIGHLIGHTS = {
  ADD: 'rel-add' as HighlightT,
  EDIT: 'rel-edit' as HighlightT,
  NONE: '' as HighlightT,
  REMOVE: 'rel-remove' as HighlightT,
} as const;
