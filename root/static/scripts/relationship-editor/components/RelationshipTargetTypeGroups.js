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

import ButtonPopover from '../../common/components/ButtonPopover.js';
import {
  useAddRelationshipDialogContent,
} from '../hooks/useRelationshipDialogContent.js';
import type {
  RelationshipDialogLocationT,
  RelationshipTargetTypeGroupsT,
} from '../types.js';
import type {RelationshipEditorActionT} from '../types/actions.js';
import {
  iterateRelationshipsInTargetTypeGroup,
} from '../utility/findState.js';

import RelationshipTargetTypeGroup from './RelationshipTargetTypeGroup.js';

type PropsT = {
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (RelationshipEditorActionT) => void,
  +filter?: (CoreEntityTypeT) => boolean,
  +releaseHasUnloadedTracks: boolean,
  +source: CoreEntityT,
  +targetTypeGroups: RelationshipTargetTypeGroupsT,
  +track: TrackWithRecordingT | null,
};

const RelationshipTargetTypeGroups = (React.memo<PropsT>(({
  dialogLocation,
  dispatch,
  filter,
  releaseHasUnloadedTracks,
  source,
  targetTypeGroups,
  track,
}: PropsT): React.MixedElement => {
  const addButtonRef = React.useRef<HTMLButtonElement | null>(null);

  const buildPopoverContent = useAddRelationshipDialogContent({
    defaultTargetType: null,
    dispatch,
    releaseHasUnloadedTracks,
    source,
    title: l('Add Relationship'),
  });

  const sections = [];
  for (const targetTypeGroup of tree.iterate(targetTypeGroups)) {
    const [targetType, linkTypeGroups] = targetTypeGroup;
    if (filter != null && !filter(targetType)) {
      continue;
    }
    const isLinkTypeGroupEmpty = iterateRelationshipsInTargetTypeGroup(
      targetTypeGroup,
    ).next().done;
    if (!isLinkTypeGroupEmpty) {
      sections.push(
        <RelationshipTargetTypeGroup
          dialogLocation={
            (
              dialogLocation != null &&
              dialogLocation.targetType === targetType
            ) ? dialogLocation : null
          }
          dispatch={dispatch}
          key={targetType}
          linkTypeGroups={linkTypeGroups}
          releaseHasUnloadedTracks={releaseHasUnloadedTracks}
          source={source}
          targetType={targetType}
          track={track}
        />,
      );
    }
  }

  const isAddDialogOpen = (
    dialogLocation != null &&
    dialogLocation.targetType == null
  );

  const setAddDialogOpen = React.useCallback((open) => {
    dispatch({
      location: open ? {source, track: track} : null,
      type: 'update-dialog-location',
    });
  }, [dispatch, source, track]);

  return (
    <table className="rel-editor-table">
      <tbody>
        {sections}
        <tr>
          <td className="add-relationship">
            <ButtonPopover
              buildChildren={buildPopoverContent}
              buttonContent={l('Add relationship')}
              buttonProps={{
                className: 'add-item with-label add-relationship',
              }}
              buttonRef={addButtonRef}
              className="relationship-dialog"
              closeOnOutsideClick={false}
              id="add-relationship-dialog"
              isDisabled={false}
              isOpen={isAddDialogOpen}
              toggle={setAddDialogOpen}
            />
          </td>
          <td />
        </tr>
      </tbody>
    </table>
  );
}): React.AbstractComponent<PropsT>);

export default RelationshipTargetTypeGroups;
