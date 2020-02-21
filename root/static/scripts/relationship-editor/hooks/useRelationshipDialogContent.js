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
  +source: CoreEntityT,
  +title: string,
};

export default function useRelationshipDialogContent(
  options: $ReadOnly<{
    ...CommonOptionsT,
    +relationship: RelationshipStateT,
    +targetTypeOptions: TargetTypeOptionsT | null,
    +targetTypeRef: {-current: CoreEntityTypeT} | null,
    +user: ActiveEditorT,
  }>,
): (
  closeAndReturnFocus: () => void,
) => React.Element<typeof RelationshipDialogContent> {
  const {
    batchSelectionCount,
    dispatch,
    relationship,
    source,
    targetTypeOptions,
    targetTypeRef,
    title,
    user,
  } = options;

  return React.useCallback((closeAndReturnFocus) => (
    <RelationshipDialogContent
      batchSelectionCount={batchSelectionCount}
      closeDialog={closeAndReturnFocus}
      initialRelationship={relationship}
      source={source}
      sourceDispatch={dispatch}
      targetTypeOptions={targetTypeOptions}
      targetTypeRef={targetTypeRef}
      title={title}
      user={user}
    />
  ), [
    batchSelectionCount,
    dispatch,
    relationship,
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
    +defaultTargetType: CoreEntityTypeT | null,
  }>,
): (
  closeAndReturnFocus: () => void,
) => React.Element<typeof RelationshipDialogContent> {
  const {
    backward,
    defaultTargetType,
    buildNewRelationshipData,
    source,
    ...otherOptions
  } = options;

  const user = useCatalystUser();

  const targetTypeOptions = React.useMemo(() => {
    return getTargetTypeOptions(user, source.entityType);
  }, [user, source.entityType]);

  // Remembers the most recently selected target type.
  const targetTypeRef = React.useRef<CoreEntityTypeT | null>(null);

  const targetType = (
    targetTypeRef.current ||
    defaultTargetType ||
    (targetTypeOptions?.[0].value)
  );

  invariant(targetType);

  const defaultTargetObject = React.useMemo(() => {
    return createCoreEntityObject(
      targetType,
      {id: uniqueNegativeId(), name: ''},
    );
  }, [targetType]);

  if (backward != null) {
    invariant(
      backward
        ? (source.entityType >= targetType)
        : (source.entityType <= targetType),
    );
  }

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
    relationship: newRelationshipState,
    source,
    targetTypeOptions,
    targetTypeRef,
    user,
  });
}
