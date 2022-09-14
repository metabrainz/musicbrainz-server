/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {createContext} from 'react';

import type {
  RelationshipSourceGroupsContextT,
} from './types.js';

export opaque type RelationshipEditStatusT = number;

export const REL_STATUS_NOOP: RelationshipEditStatusT = 0;
export const REL_STATUS_ADD: RelationshipEditStatusT = 1;
export const REL_STATUS_EDIT: RelationshipEditStatusT = 2;
export const REL_STATUS_REMOVE: RelationshipEditStatusT = 3;

export const EMPTY_DIALOG_PARTIAL_DATE = Object.freeze({
  day: '',
  error: '',
  month: '',
  pendingError: '',
  year: '',
});

export const EMPTY_DIALOG_DATE_PERIOD = Object.freeze({
  beginDate: EMPTY_DIALOG_PARTIAL_DATE,
  endDate: EMPTY_DIALOG_PARTIAL_DATE,
  ended: false,
  error: '',
  pendingError: '',
});

export const RelationshipSourceGroupsContext:
  React$Context<RelationshipSourceGroupsContextT> =
  createContext({
    existing: null,
    pending: null,
  });
