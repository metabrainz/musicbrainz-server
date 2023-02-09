/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {createCoreEntityObject} from '../../common/entity2.js';
import {uniqueNegativeId} from '../../common/utility/numbers.js';
import RelationshipDialogContent
  from '../components/RelationshipDialogContent.js';
import {REL_STATUS_ADD} from '../constants.js';
import type {
  RelationshipStateT,
  TargetTypeOptionsT,
} from '../types.js';
import type {
  UpdateRelationshipActionT,
} from '../types/actions.js';
import getRelationshipStateId from '../utility/getRelationshipStateId.js';
import getTargetTypeOptions from '../utility/getTargetTypeOptions.js';

import useCatalystUser from './useCatalystUser.js';

const RELATIONSHIP_DEFAULTS = {
  _lineage: [],
  _original: null,
  _status: REL_STATUS_ADD,
  attributes: null,
  begin_date: null,
  editsPending: false,
  end_date: null,
  ended: false,
  entity0_credit: '',
  entity1_credit: '',
  id: null,
  linkOrder: 0,
  linkTypeID: null,
};

type CommonOptionsT = {
  +batchSelectionCount?: number,
  +dispatch: (UpdateRelationshipActionT) => void,
  +releaseHasUnloadedTracks: boolean,
  +source: CoreEntityT,
  +title: string,
};

export default function useRelationshipDialogContent(
  options: $ReadOnly<{
    ...CommonOptionsT,
    +hasPreselectedTargetType: boolean,
    +relationship: RelationshipStateT,
    +targetTypeOptions: TargetTypeOptionsT | null,
    +targetTypeRef: {-current: CoreEntityTypeT} | null,
    +user: ActiveEditorT,
  }>,
): (
  closeAndReturnFocus: () => void,
) => React.MixedElement {
  const {
    batchSelectionCount,
    dispatch,
    hasPreselectedTargetType,
    relationship,
    releaseHasUnloadedTracks,
    source,
    targetTypeOptions,
    targetTypeRef,
    title,
    user,
  } = options;

  return React.useCallback((closeAndReturnFocus) => {
    if (targetTypeOptions != null && !targetTypeOptions.length) {
      /*
       * This string should not be seen by users outside of development
       * servers.
       */
      return (
        <p>
          {
            'No relationship types are available for ' +
            JSON.stringify(source.entityType) +
            ' entities.'
          }
        </p>
      );
    }
    return (
      <RelationshipDialogContent
        batchSelectionCount={batchSelectionCount}
        closeDialog={closeAndReturnFocus}
        hasPreselectedTargetType={hasPreselectedTargetType}
        initialRelationship={relationship}
        releaseHasUnloadedTracks={releaseHasUnloadedTracks}
        source={source}
        sourceDispatch={dispatch}
        targetTypeOptions={targetTypeOptions}
        targetTypeRef={targetTypeRef}
        title={title}
        user={user}
      />
    );
  }, [
    batchSelectionCount,
    dispatch,
    hasPreselectedTargetType,
    relationship,
    releaseHasUnloadedTracks,
    source,
    targetTypeOptions,
    targetTypeRef,
    title,
    user,
  ]);
}

export function useAddRelationshipDialogContent(
  options: $ReadOnly<{
    ...CommonOptionsT,
    +backward?: boolean,
    +buildNewRelationshipData?:
      () => $Partial<RelationshipStateT> | null,
    +preselectedTargetType: CoreEntityTypeT | null,
    +targetTypeOptions?: TargetTypeOptionsT | null,
  }>,
): (
  closeAndReturnFocus: () => void,
) => React.MixedElement {
  const {
    backward,
    buildNewRelationshipData,
    preselectedTargetType,
    releaseHasUnloadedTracks,
    source,
    targetTypeOptions: customTargetTypeOptions,
    ...otherOptions
  } = options;

  const user = useCatalystUser();

  const targetTypeOptions = React.useMemo(() => {
    /*
     * Note: We distinguish between null and undefined here.
     * null: don't allow any target types for selection
     * undefined: no options were provided
     */
    if (customTargetTypeOptions === null) {
      return null;
    }
    return getTargetTypeOptions(user, source.entityType);
  }, [customTargetTypeOptions, user, source.entityType]);

  // Remembers the most recently selected target type.
  const targetTypeRef = React.useRef<CoreEntityTypeT | null>(null);

  const targetType = (
    preselectedTargetType ||
    targetTypeRef.current ||
    (targetTypeOptions?.[0]?.value) ||
    /*
     * targetType may be undefined if the current server doesn't have any
     * available link types for the source entity type.  In that case
     * `defaultTargetObject` won't be used, but a dummy 'artist' type is
     * supplied to simplify type-checking.
     */
    'artist'
  );

  if (backward != null) {
    invariant(
      backward
        ? (source.entityType >= targetType)
        : (source.entityType <= targetType),
    );
  }

  const defaultTargetObject = React.useMemo(() => {
    return createCoreEntityObject(
      targetType,
      {id: uniqueNegativeId(), name: ''},
    );
  }, [targetType]);

  const _backward = backward ?? (source.entityType > targetType);

  const newRelationshipState: RelationshipStateT = {
    ...RELATIONSHIP_DEFAULTS,
    entity0: _backward ? defaultTargetObject : source,
    entity1: _backward ? source : defaultTargetObject,
    id: getRelationshipStateId(null),
    ...(buildNewRelationshipData ? buildNewRelationshipData() : null),
  };

  return useRelationshipDialogContent({
    ...otherOptions,
    hasPreselectedTargetType: preselectedTargetType != null,
    relationship: newRelationshipState,
    releaseHasUnloadedTracks,
    source,
    targetTypeOptions,
    targetTypeRef,
    user,
  });
}
