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
  isLinkTypeOrderableByUser,
} from '../../common/utility/isLinkTypeDirectionOrderable.js';
import {kebabCase} from '../../common/utility/strings.js';
import {useAddRelationshipDialogContent}
  from '../hooks/useRelationshipDialogContent.js';
import type {
  RelationshipDialogLocationT,
  RelationshipPhraseGroupT,
  RelationshipStateT,
} from '../types.js';
import type {
  RelationshipEditorActionT,
} from '../types/actions.js';
import {compareLinkAttributeIds} from '../utility/compareRelationships.js';

import RelationshipItem from './RelationshipItem.js';

const addAnotherEntityLabels = {
  area: N_l('Add another area'),
  artist: N_l('Add another artist'),
  event: N_l('Add another event'),
  genre: N_l('Add another genre'),
  instrument: N_l('Add another instrument'),
  label: N_l('Add another label'),
  place: N_l('Add another place'),
  recording: N_l('Add another recording'),
  release: N_l('Add another release'),
  release_group: N_l('Add another release group'),
  series: N_l('Add another series'),
  url: () => '',
  work: N_l('Add another work'),
};

type PropsT = {
  +backward: boolean,
  +dialogLocation: RelationshipDialogLocationT | null,
  +dispatch: (RelationshipEditorActionT) => void,
  +linkPhraseGroup: RelationshipPhraseGroupT,
  +linkTypeId: number,
  +source: CoreEntityT,
  +targetType: CoreEntityTypeT,
  +track: TrackWithRecordingT | null,
};

function someRelationshipsHaveLinkOrder(
  relationships: tree.ImmutableTree<RelationshipStateT> | null,
): boolean {
  for (const relationship of tree.iterate(relationships)) {
    if (relationship.linkOrder) {
      return true;
    }
  }
  return false;
}

const RelationshipPhraseGroup = (React.memo<PropsT>(({
  backward,
  dialogLocation,
  dispatch,
  linkPhraseGroup,
  linkTypeId,
  source,
  targetType,
  track,
}: PropsT) => {
  const relationships = linkPhraseGroup.relationships;
  const relationshipCount = relationships?.size || 0;

  const [isExpanded, setExpanded] = React.useState(relationshipCount <= 10);

  const addButtonRef = React.useRef<HTMLButtonElement | null>(null);

  const canBeOrdered =
    isLinkTypeOrderableByUser(linkTypeId, source, backward);
  const hasOrdering = React.useMemo(() => (
    canBeOrdered &&
    someRelationshipsHaveLinkOrder(relationships)
  ), [canBeOrdered, relationships]);

  const buildNewRelationshipData = React.useCallback(() => {
    let maxLinkOrder = 0;
    let newAttributesData = null;

    for (const relationship of tree.iterate(relationships)) {
      if (canBeOrdered) {
        maxLinkOrder = Math.max(maxLinkOrder, relationship.linkOrder);
      }
      // Drop number attribute for part of series - useless to reuse
      const relationshipAttributesForReuse = tree.removeIfExists(
        relationship.attributes,
        {
          type: {gid: 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a'},
          typeID: 788,
          typeName: 'number',
        },
        compareLinkAttributeIds,
      );
      newAttributesData = tree.union(
        newAttributesData,
        relationshipAttributesForReuse,
        compareLinkAttributeIds,
      );
    }

    return {
      // $FlowIgnore[invalid-computed-prop]
      [backward ? 'entity1' : 'entity0']: source,
      attributes: newAttributesData,
      linkOrder: maxLinkOrder > 0 ? (maxLinkOrder + 1) : 0,
      linkTypeID: linkTypeId,
    };
  }, [
    canBeOrdered,
    relationships,
    backward,
    linkTypeId,
    source,
  ]);

  const buildPopoverContent = useAddRelationshipDialogContent({
    backward,
    buildNewRelationshipData,
    defaultTargetType: targetType,
    dispatch,
    source,
    targetTypeOptions: null,
    title: l('Add Relationship'),
  });

  const setAddDialogOpen = React.useCallback((open) => {
    dispatch({
      location: open ? {
        backward,
        linkTypeId,
        source,
        targetType,
        textPhrase: linkPhraseGroup.textPhrase,
        track,
      } : null,
      type: 'update-dialog-location',
    });
  }, [
    dispatch,
    backward,
    linkTypeId,
    source,
    targetType,
    linkPhraseGroup.textPhrase,
    track,
  ]);

  const toggleOrdering = React.useCallback(function (
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    dispatch({
      hasOrdering: event.currentTarget.checked,
      linkPhraseGroup,
      source,
      type: 'toggle-ordering',
    });
  }, [dispatch, linkPhraseGroup, source]);

  const handleSeeAllClick = React.useCallback((
    event: SyntheticMouseEvent<HTMLAnchorElement>,
  ) => {
    event.preventDefault();
    setExpanded(true);
  }, [setExpanded]);

  const relationshipItemElements = [];
  for (const relationship of tree.iterate(relationships)) {
    relationshipItemElements.push(
      <RelationshipItem
        canBeOrdered={canBeOrdered}
        dispatch={dispatch}
        hasOrdering={hasOrdering}
        isDialogOpen={
          dialogLocation != null &&
          dialogLocation.relationshipId === relationship.id
        }
        key={relationship.id}
        relationship={relationship}
        source={source}
        track={track}
      />,
    );
    if (!isExpanded && relationshipItemElements.length === 10) {
      break;
    }
  }

  let textPhraseLabel = null;
  let textPhraseClassName = null;
  if (linkPhraseGroup.textPhrase) {
    textPhraseLabel = addColonText(linkPhraseGroup.textPhrase);
    textPhraseClassName = kebabCase(linkPhraseGroup.textPhrase);
  }
  const textPhraseElement = (
    <>
      <label>
        {textPhraseLabel ?? (
          <span className="no-value">
            {addColonText(l('no type'))}
          </span>
        )}
      </label>
      {' '}
      <ButtonPopover
        buildChildren={buildPopoverContent}
        buttonContent={null}
        buttonProps={{
          className: 'icon add-item add-another-entity',
          title: addAnotherEntityLabels[targetType](),
        }}
        buttonRef={addButtonRef}
        className="relationship-dialog"
        closeOnOutsideClick={false}
        id="add-relationship-dialog"
        isDisabled={false}
        isOpen={
          dialogLocation != null &&
          dialogLocation.relationshipId == null
        }
        toggle={setAddDialogOpen}
      />
    </>
  );
  const relationshipListElement = (
    <td className="relationship-list">
      {relationshipItemElements}
      {isExpanded ? null : (
        <p>
          <a href="#" onClick={handleSeeAllClick}>
            {texp.l(
              'See all {num} relationships',
              {num: relationshipCount},
            )}
          </a>
        </p>
      )}
    </td>
  );

  return relationshipCount ? (
    <>
      <tr className={textPhraseClassName}>
        <th className="link-phrase">
          {textPhraseElement}
        </th>
        {relationshipListElement}
      </tr>
      {canBeOrdered ? (
        <tr>
          <td />
          <td>
            <label style={{padding: '6px'}}>
              <input
                checked={hasOrdering}
                onChange={toggleOrdering}
                type="checkbox"
              />
              {' '}
              {l('These relationships have a specific ordering')}
            </label>
          </td>
        </tr>
      ) : null}
    </>
  ) : null;
}): React.AbstractComponent<PropsT>);

export default RelationshipPhraseGroup;
