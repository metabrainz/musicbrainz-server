/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import typeof {ERROR_TARGETS} from '../edit/URLCleanup.js';

export type CreditableEntityOptionsT =
  | 'entity0_credit'
  | 'entity1_credit'
  | null;

export type ErrorT = {
  blockMerge?: boolean,
  message: React.Node,
  target: ErrorTargetT,
};

type ErrorTargetT = $Values<ERROR_TARGETS>;

export type HighlightT =
  | 'rel-add'
  | 'rel-edit'
  | ''
  | 'rel-remove';

export type LinksEditorPropsT = {
  +errorObservable?: (boolean) => void,
  +isNewEntity: boolean,
  +sourceData:
    | RelatableEntityT
    | {
        +entityType: RelatableEntityTypeT,
        +id?: void,
        +isNewEntity?: true,
        +name?: string,
        +orderingTypeID?: number,
        +relationships?: void,
      },
};

export type LinksEditorStateT = {
  +links: $ReadOnlyArray<LinkStateT>,
};

export type LinkMapT = Map<string, LinkStateT>;

export type LinkRelationshipT = $ReadOnly<{
  ...LinkStateT,
  +error: ErrorT | null,
  +index: number,
  +urlIndex: number,
}>;

export type LinkStateT = $ReadOnly<{
  ...DatePeriodRoleT,
  +deleted: boolean,
  +editsPending: boolean,
  +entity0:
    | RelatableEntityT
    | {
        +entityType: RelatableEntityTypeT,
        +id?: void,
        +isNewEntity?: true,
        +name?: string,
        +orderingTypeID?: number,
        +relationships?: void,
      }
    | null,
  +entity0_credit: string,
  +entity1: RelatableEntityT | null,
  +entity1_credit: string,
  +pendingTypes: $ReadOnlyArray<number> | null,
  +rawUrl: string,
  // New relationships will use a unique string ID like "new-1".
  +relationship: StrOrNum | null,
  +submitted: boolean,
  +type: number | null,
  +url: string,
  +video: boolean,
}>;

export type LinkTypeOptionT = {
  data: LinkTypeT,
  disabled?: boolean,
  text: string,
  value: number,
};

export type SeededUrlShapeT = {
  link_type_id?: string,
  text?: string,
};
