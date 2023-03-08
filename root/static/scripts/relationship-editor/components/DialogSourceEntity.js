/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../../common/components/EntityLink.js';
import {
  ENTITIES_WITH_RELATIONSHIP_CREDITS,
  ENTITY_NAMES,
} from '../../common/constants.js';
import * as URLCleanup from '../../edit/URLCleanup.js';
import type {
  DialogSourceEntityStateT,
  RelationshipStateT,
} from '../types.js';
import type {
  DialogEntityCreditActionT,
} from '../types/actions.js';
import getBatchSelectionMessage from '../utility/getBatchSelectionMessage.js';
import getRelationshipLinkType from '../utility/getRelationshipLinkType.js';
import isRelationshipBackward from '../utility/isRelationshipBackward.js';

import DialogEntityCredit, {
  createInitialState as createDialogEntityCreditState,
  reducer as dialogEntityCreditReducer,
} from './DialogEntityCredit.js';

type PropsT = {
  +backward: boolean,
  +batchSelectionCount?: number,
  +dispatch: (DialogEntityCreditActionT) => void,
  +linkType: ?LinkTypeT,
  +source: CoreEntityT,
  +state: DialogSourceEntityStateT,
  +targetType: CoreEntityTypeT,
};

export function getSourceError(
  source: CoreEntityT | null,
  linkType: LinkTypeT | null,
): React$Node {
  if (
    source &&
    linkType &&
    source.entityType === 'url'
  ) {
    const targetType = linkType.type0 === 'url'
      ? linkType.type1
      : linkType.type0;
    const checker = new URLCleanup.Checker(source.name, targetType);
    const check = checker.checkRelationship(linkType.gid);

    if (!check.result) {
      return nonEmpty(check.error) ? check.error : l(
        `This URL is not allowed for the selected link type,
         or is incorrectly formatted.`,
      );
    }
  }
  return '';
}

export function createInitialState(
  releaseHasUnloadedTracks: boolean,
  sourceType: CoreEntityTypeT,
  relationship: RelationshipStateT,
  source: CoreEntityT,
): DialogSourceEntityStateT {
  const linkType = getRelationshipLinkType(relationship);
  const backward = isRelationshipBackward(relationship, source);
  return {
    entityType: sourceType,
    error: getSourceError(source, linkType),
    ...createDialogEntityCreditState(
      backward
        ? relationship.entity1_credit
        : relationship.entity0_credit,
      releaseHasUnloadedTracks,
    ),
  };
}

export function reducer(
  state: DialogSourceEntityStateT,
  action: DialogEntityCreditActionT,
): DialogSourceEntityStateT {
  return dialogEntityCreditReducer(state, action);
}

const DialogSourceEntity = (React.memo<PropsT>(({
  backward,
  batchSelectionCount,
  dispatch,
  linkType,
  source,
  state,
  targetType,
}: PropsT): React$MixedElement => {
  const sourceType = source.entityType;
  return (
    <tr>
      <td className="required section">
        {ENTITY_NAMES[sourceType]()}
      </td>
      <td className="fields">
        {source && batchSelectionCount == null ? (
          <>
            <EntityLink
              allowNew
              content={source.name || l('[unknown]')}
              entity={source}
              target="_blank"
            />
            <div className="error">
              {state.error}
            </div>
          </>
        // $FlowIgnore[sketchy-null-number]
        ) : batchSelectionCount ? (
          getBatchSelectionMessage(sourceType, batchSelectionCount)
        ) : null}

        {ENTITIES_WITH_RELATIONSHIP_CREDITS[sourceType] ? (
          <DialogEntityCredit
            backward={backward}
            dispatch={dispatch}
            entityName={source.name}
            forEntity="source"
            linkType={linkType}
            state={state}
            targetType={targetType}
          />
        ) : null}
      </td>
    </tr>
  );
}): React.AbstractComponent<PropsT>);

export default DialogSourceEntity;
