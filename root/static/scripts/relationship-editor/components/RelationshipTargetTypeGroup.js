/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as tree from 'weight-balanced-tree';

import type {
  RelationshipDialogLocationT,
  RelationshipLinkTypeGroupsT,
} from '../types.js';
import type {RelationshipEditorActionT} from '../types/actions.js';
import {getLinkTypeGroupKey} from '../utility/updateRelationships.js';

import RelationshipLinkTypeGroup from './RelationshipLinkTypeGroup.js';

type Props = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (RelationshipEditorActionT) => void,
  +linkTypeGroups: RelationshipLinkTypeGroupsT,
  +source: CentralEntityT,
  +targetType: CentralEntityTypeT,
  +track: TrackWithRecordingT | null,
};

const RelationshipTargetTypeGroup = (React.memo<Props>(({
  dialogLocation,
  dispatch,
  linkTypeGroups,
  source,
  targetType,
  track,
}: Props) => {
  const elements = [];
  for (const linkTypeGroup of tree.iterate(linkTypeGroups)) {
    elements.push(
      <RelationshipLinkTypeGroup
        dialogLocation={
          (
            dialogLocation != null &&
            dialogLocation.linkTypeId === linkTypeGroup.typeId &&
            dialogLocation.backward === linkTypeGroup.backward
          ) ? dialogLocation : null
        }
        dispatch={dispatch}
        key={getLinkTypeGroupKey(
          linkTypeGroup.typeId,
          linkTypeGroup.backward,
        )}
        linkTypeGroup={linkTypeGroup}
        source={source}
        targetType={targetType}
        track={track}
      />,
    );
  }
  return elements;
}): React.AbstractComponent<Props>);

export default RelationshipTargetTypeGroup;
