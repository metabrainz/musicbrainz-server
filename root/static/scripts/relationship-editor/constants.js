/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {createContext} from 'react';
import * as tree from 'weight-balanced-tree';

import type {
  RelationshipSourceGroupsContextT,
} from './types.js';

type REL_STATUS_NOOP_T = 0;
export const REL_STATUS_NOOP: REL_STATUS_NOOP_T = 0;

type REL_STATUS_ADD_T = 1;
export const REL_STATUS_ADD: REL_STATUS_ADD_T = 1;

type REL_STATUS_EDIT_T = 2;
export const REL_STATUS_EDIT: REL_STATUS_EDIT_T = 2;

type REL_STATUS_REMOVE_T = 3;
export const REL_STATUS_REMOVE: REL_STATUS_REMOVE_T = 3;

export type RelationshipEditStatusT =
  | REL_STATUS_NOOP_T
  | REL_STATUS_ADD_T
  | REL_STATUS_EDIT_T
  | REL_STATUS_REMOVE_T;

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
  React.Context<RelationshipSourceGroupsContextT> =
  createContext({
    existing: tree.empty,
    pending: tree.empty,
  });
