/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as tree from 'weight-balanced-tree';

import EntityLink from '../../common/components/EntityLink.js';
import Relationship from '../../common/components/Relationship.js';
import areDatePeriodsEqual
  from '../../common/utility/areDatePeriodsEqual.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import isDisabledLink from '../../common/utility/isDisabledLink.js';
import RelationshipDiff from '../../edit/components/edit/RelationshipDiff.js';
import type {
  RelationshipStateT,
} from '../types.js';
import getBatchSelectionMessage from '../utility/getBatchSelectionMessage.js';
import getRelationshipLinkType from '../utility/getRelationshipLinkType.js';
import relationshipsHaveSamePhraseGroup
  from '../utility/relationshipsHaveSamePhraseGroup.js';

const createRelationshipTFromState = (
  relationship: RelationshipStateT,
  source: RelatableEntityT,
  backward: boolean,
) => {
  const target = backward ? relationship.entity0 : relationship.entity1;
  const linkType = getRelationshipLinkType(relationship);
  const hasDates = linkType ? linkType.has_dates : true;

  return {
    attributes: tree.toArray(relationship.attributes ?? tree.empty),
    backward,
    begin_date: hasDates ? relationship.begin_date : null,
    editsPending: relationship.editsPending,
    end_date: hasDates ? relationship.end_date : null,
    ended: hasDates ? relationship.ended : false,
    entity0: relationship.entity0,
    entity0_credit: relationship.entity0_credit,
    entity0_id: relationship.entity0.id,
    entity1: relationship.entity1,
    entity1_credit: relationship.entity1_credit,
    entity1_id: relationship.entity1.id,
    id: relationship.id ?? 0,
    linkOrder: relationship.linkOrder,
    linkTypeID: relationship.linkTypeID ?? 0,
    source_id: source.id,
    source_type: source.entityType,
    target,
    target_type: target.entityType,
    verbosePhrase: '',
  };
};

function relationshipsAreIdenticalIgnoringLinkOrder(
  relationship1: RelationshipStateT,
  relationship2: RelationshipStateT,
) {
  return (
    relationship1.entity0_credit === relationship2.entity0_credit &&
    relationship1.entity1_credit === relationship2.entity1_credit &&
    relationshipsHaveSamePhraseGroup(relationship1, relationship2) &&
    areDatePeriodsEqual(relationship1, relationship2)
  );
}

component _DialogPreview(
  backward: boolean,
  batchSelectionCount: number | void,
  dispatch: ({+type: 'change-direction'}) => void,
  newRelationship: RelationshipStateT | null,
  oldRelationship: RelationshipStateT | null,
  source: RelatableEntityT,
) {
  function changeDirection() {
    dispatch({type: 'change-direction'});
  }

  const targetType = backward
    ? newRelationship?.entity0.entityType
    : newRelationship?.entity1.entityType;

  const makeEntityLink = (
    entity: RelatableEntityT,
    content: string,
    relationship: RelationshipT,
  ) => (
    <EntityLink
      allowNew
      className="wrap-anywhere"
      content={
        nonEmpty(content)
          ? content
          : (
            (isDatabaseRowId(entity.id) || nonEmpty(entity.name))
              ? '' // have EntityLink determine the content
              : lp('[unknown]', 'generic entity'))
      }
      deletedCaption={
        (batchSelectionCount != null && entity === source)
          ? getBatchSelectionMessage(source.entityType, batchSelectionCount)
          : undefined
      }
      disableLink={isDisabledLink(relationship, entity)}
      entity={entity}
      showDisambiguation
      target="_blank"
    />
  );

  const relationshipPreview = (
    relationship: RelationshipStateT,
    className: string,
    extraRows?: React.Node,
  ) => {
    const fullClassName = 'preview details' +
      (className ? ' ' + className : '');
    return (
      <table className={fullClassName}>
        <tbody>
          <tr>
            <th>{addColonText(l('Relationship'))}</th>
            <td>
              <Relationship
                makeEntityLink={makeEntityLink}
                relationship={createRelationshipTFromState(
                  relationship,
                  source,
                  backward,
                )}
              />
            </td>
          </tr>
          {extraRows}
        </tbody>
      </table>
    );
  };

  const linkOrderDiff = (
    oldLinkOrder: number,
    newLinkOrder: number,
  ) => oldLinkOrder === newLinkOrder ? null : (
    <>
      <tr>
        <th>{addColonText(l('Old order'))}</th>
        <td className="old">{oldLinkOrder}</td>
      </tr>
      <tr>
        <th>{addColonText(l('New order'))}</th>
        <td className="new">{newLinkOrder}</td>
      </tr>
    </>
  );

  return (
    <>
      <h2>
        <div className="heading-line" />
        <span className="heading-text">
          {lp('Preview', 'header')}
        </span>
      </h2>
      {(oldRelationship && newRelationship) ? (
        /*
         * Relationship previews using the long link phrase currently don't
         * display the link order in any way, so we have to diff those
         * separately; and we have to ignore them when diffing the rest of
         * the relationship data, otherwise a "no-op" diff will be displayed
         * to the user.
         */
        relationshipsAreIdenticalIgnoringLinkOrder(
          oldRelationship,
          newRelationship,
        )
          ? (
            relationshipPreview(
              newRelationship,
              '',
              linkOrderDiff(
                oldRelationship.linkOrder,
                newRelationship.linkOrder,
              ),
            )
          )
          : (
            <table className="preview details edit-relationship">
              <tbody>
                <RelationshipDiff
                  makeEntityLink={makeEntityLink}
                  newRelationship={createRelationshipTFromState(
                    newRelationship,
                    source,
                    backward,
                  )}
                  oldRelationship={createRelationshipTFromState(
                    oldRelationship,
                    source,
                    backward,
                  )}
                />
                {linkOrderDiff(
                  oldRelationship.linkOrder,
                  newRelationship.linkOrder,
                )}
              </tbody>
            </table>
          )
      ) : newRelationship ? (
        relationshipPreview(newRelationship, 'add-relationship')
      ) : (
        <p className="required-fields-note">
          {l('Please fill out all required fields.')}
        </p>
      )}

      {source.entityType === targetType ? (
        <>
          {' '}
          <button
            className="styled-button change-direction"
            onClick={changeDirection}
            type="button"
          >
            {l('Change direction')}
          </button>
        </>
      ) : null}
    </>
  );
}

const DialogPreview:
  component(...React.PropsOf<_DialogPreview>) =
  React.memo(_DialogPreview);

export default DialogPreview;
