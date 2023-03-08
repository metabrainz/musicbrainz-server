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

import warningIconUrl from '../../../images/icons/warning.png';
import ButtonPopover from '../../common/components/ButtonPopover.js';
import DescriptiveLink from '../../common/components/DescriptiveLink.js';
import {bracketedText} from '../../common/utility/bracketed.js';
import {displayLinkAttributesText}
  from '../../common/utility/displayLinkAttribute.js';
import {
  performReactUpdateAndMaintainFocus,
} from '../../common/utility/focusManagement.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {
  isLinkTypeOrderableByUser,
} from '../../common/utility/isLinkTypeDirectionOrderable.js';
import relationshipDateText
  from '../../common/utility/relationshipDateText.js';
import Tooltip from '../../edit/components/Tooltip.js';
import {
  getPhraseAndExtraAttributesText,
} from '../../edit/utility/linkPhrase.js';
import {
  REL_STATUS_REMOVE,
} from '../constants.js';
import useCatalystUser from '../hooks/useCatalystUser.js';
import useRelationshipDialogContent
  from '../hooks/useRelationshipDialogContent.js';
import type {
  RelationshipStateT,
} from '../types.js';
import type {
  RelationshipEditorActionT,
} from '../types/actions.js';
import getLinkPhrase from '../utility/getLinkPhrase.js';
import getOpenEditsLink from '../utility/getOpenEditsLink.js';
import getRelationshipKey from '../utility/getRelationshipKey.js';
import getRelationshipLinkType from '../utility/getRelationshipLinkType.js';
import getRelationshipStatusName
  from '../utility/getRelationshipStatusName.js';
import isRelationshipBackward from '../utility/isRelationshipBackward.js';

import NewWorkLink from './NewWorkLink.js';

type PropsT = {
  +canBeOrdered: boolean,
  +dispatch: (RelationshipEditorActionT) => void,
  +hasOrdering: boolean,
  +isDialogOpen: boolean,
  +relationship: RelationshipStateT,
  +releaseHasUnloadedTracks: boolean,
  +source: CoreEntityT,
  +track: TrackWithRecordingT | null,
};

const RelationshipItem = (React.memo<PropsT>(({
  canBeOrdered,
  dispatch,
  isDialogOpen,
  hasOrdering,
  relationship,
  releaseHasUnloadedTracks,
  source,
  track,
}: PropsT): React$MixedElement => {
  const backward = isRelationshipBackward(relationship, source);
  const target: CoreEntityT = backward
    ? relationship.entity0
    : relationship.entity1;
  const [sourceCredit, targetCredit] = backward
    ? [relationship.entity1_credit, relationship.entity0_credit]
    : [relationship.entity0_credit, relationship.entity1_credit];
  const hasPendingEdits = relationship.editsPending;
  const openEditsLink = getOpenEditsLink(relationship);
  const isRemoved = relationship._status === REL_STATUS_REMOVE;
  const removeButtonId =
    'remove-relationship-' + getRelationshipKey(relationship);
  let targetDisplay: Expand2ReactOutput | null = null;

  if (
    target.entityType === 'work' &&
    target._fromBatchCreateWorksDialog === true
  ) {
    targetDisplay = <NewWorkLink work={target} />;
  } else if (target.gid) {
    targetDisplay = (
      <DescriptiveLink
        content={targetCredit}
        entity={target}
        showDisambiguation
        /*
         * The entity pending edits display conflicts with the relationship
         * editor's display of pending (unsubmitted) relationship edits.
         */
        showEditsPending={false}
        target="_blank"
      />
    );
  } else {
    targetDisplay = (
      <span className="no-value">
        {target.name || l('no entity')}
      </span>
    );
  }

  if (nonEmpty(sourceCredit)) {
    targetDisplay = exp.l('{target} (as {credited_name})', {
      credited_name: sourceCredit,
      target: targetDisplay,
    });
  }

  const editButtonRef = React.useRef<HTMLButtonElement | null>(null);

  function removeRelationship(): void {
    performReactUpdateAndMaintainFocus(removeButtonId, function () {
      dispatch({
        relationship,
        type: 'remove-relationship',
      });
    });
  }

  function moveEntityDown() {
    dispatch({relationship, source, type: 'move-relationship-down'});
  }

  function moveEntityUp() {
    dispatch({relationship, source, type: 'move-relationship-up'});
  }

  const dateText = bracketedText(
    relationshipDateText(relationship, /* brackedEnded = */ false),
  );
  const linkType = getRelationshipLinkType(relationship);

  const attributeText = React.useMemo(() => {
    if (!linkType) {
      return '';
    }
    return bracketedText(
      displayLinkAttributesText(getPhraseAndExtraAttributesText(
        linkType,
        tree.toArray(relationship.attributes),
        backward ? 'reverse_link_phrase' : 'link_phrase',
        canBeOrdered /* forGrouping */,
      )[1]),
    );
  }, [
    linkType,
    relationship.attributes,
    backward,
    canBeOrdered,
  ]);

  const isIncomplete = (
    relationship.linkTypeID == null ||
    (
      !isDatabaseRowId(target.id) &&
      /*
       * Incomplete works are allowed to be added by the batch-create-works
       * dialog, and will be created once submitted.
       */
      !(target.entityType === 'work' && target._fromBatchCreateWorksDialog)
    )
  );

  const user = useCatalystUser();

  const buildPopoverContent = useRelationshipDialogContent({
    dispatch,
    hasPreselectedTargetType: true,
    relationship,
    releaseHasUnloadedTracks,
    source,
    targetTypeOptions: null,
    targetTypeRef: null,
    title: l('Edit Relationship'),
    user,
  });

  const setDialogOpen = React.useCallback((
    open: boolean,
  ) => {
    dispatch({
      location: open ? {
        backward,
        linkTypeId: linkType ? linkType.id : 0,
        relationshipId: relationship.id,
        source,
        targetType: target.entityType,
        textPhrase: getLinkPhrase(relationship, backward),
        track,
      } : null,
      type: 'update-dialog-location',
    });
  }, [
    dispatch,
    backward,
    linkType,
    source,
    target.entityType,
    relationship,
    track,
  ]);

  const datesAndAttributes = ' ' + (
    dateText
      ? (dateText + (attributeText ? ' ' + attributeText : ''))
      : attributeText
  );

  return (
    <>
      <div className="relationship-item">
        <button
          className="icon remove-item"
          id={removeButtonId}
          onClick={removeRelationship}
          type="button"
        />
        <ButtonPopover
          buildChildren={buildPopoverContent}
          buttonContent={null}
          buttonProps={{
            className: 'icon edit-item',
            id: 'edit-relationship-' + getRelationshipKey(relationship),
          }}
          buttonRef={editButtonRef}
          className="relationship-dialog"
          closeOnOutsideClick={false}
          id="edit-relationship-dialog"
          isDisabled={isRemoved}
          isOpen={isDialogOpen}
          toggle={setDialogOpen}
        />
        {' '}
        {hasOrdering ? (
          <>
            <button
              className="icon move-down"
              disabled={isRemoved}
              onClick={moveEntityDown}
              title={l('Move entity down')}
              type="button"
            />
            <button
              className="icon move-up"
              disabled={isRemoved}
              onClick={moveEntityUp}
              title={l('Move entity up')}
              type="button"
            />
            {' '}
          </>
        ) : null}
        <span className={getRelationshipStyling(relationship)}>
          {(
            relationship.linkOrder &&
            isLinkTypeOrderableByUser(
              relationship.linkTypeID,
              source,
              backward,
            )
          ) ? (
              exp.l('{num}. {relationship}', {
                num: relationship.linkOrder,
                relationship: targetDisplay,
              })
            )
            : targetDisplay}
          {hasPendingEdits && nonEmpty(openEditsLink) ? (
            <>
              {' '}
              <Tooltip
                content={exp.l(
                  'This relationship has {edit_search|pending edits}.',
                  {edit_search: openEditsLink},
                )}
                target={
                  <img
                    alt={l('This relationship has pending edits.')}
                    className="info"
                    src={warningIconUrl}
                    style={{verticalAlign: 'middle'}}
                    width={14}
                  />
                }
              />
            </>
          ) : null}
          {datesAndAttributes}
        </span>
      </div>

      {isIncomplete ? (
        <p className="error">
          {l(`You must select a relationship type and target entity for
              every relationship.`)}
        </p>
      ) : null}
    </>
  );
}): React.AbstractComponent<PropsT>);

function getRelationshipStyling(relationship: RelationshipStateT) {
  return 'rel-' + getRelationshipStatusName(relationship);
}

export default RelationshipItem;
