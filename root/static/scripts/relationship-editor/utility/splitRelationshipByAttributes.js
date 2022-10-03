/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';
import {
  onConflictThrowError,
} from 'weight-balanced-tree/update';

import {INSTRUMENT_ROOT_ID, VOCAL_ROOT_ID} from '../../common/constants.js';
import linkedEntities from '../../common/linkedEntities.mjs';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {uniqueNegativeId} from '../../common/utility/numbers.js';
import {
  REL_STATUS_ADD,
  REL_STATUS_NOOP,
} from '../constants.js';
import type {
  RelationshipStateT,
} from '../types.js';

import {cloneRelationshipState} from './cloneState.js';
import {compareLinkAttributeIds} from './compareRelationships.js';
import getRelationshipEditStatus from './getRelationshipEditStatus.js';

/*
 * Implement MBS-1377 in the relationship editor UI. (This is also handled
 * separately on the server.)
 */
export default function splitRelationshipByAttributes(
  relationship: RelationshipStateT,
): $ReadOnlyArray<RelationshipStateT> {
  const splitRelationships = [];
  const existingInstrumentAndVocalIds = new Set();
  const addedInstrumentsAndVocals = [];
  let preservedInstrumentsAndVocals = null;
  let otherLinkAttributes = null;

  /*
   * If this is an existing relationship, split any newly-added instrument
   * and vocal attributes, but preserve existing ones.  Existing ones can be
   * removed/split manually, but it's better not to enter any edits the user
   * didn't intend to, as this can cause confusion.
   */
  const isExistingRelationship = isDatabaseRowId(relationship.id);
  if (isExistingRelationship) {
    /*:: invariant(relationship._original); */
    for (
      const linkAttribute of tree.iterate(relationship._original.attributes)
    ) {
      const linkAttributeType =
        linkedEntities.link_attribute_type[linkAttribute.typeID];
      const rootId = linkAttributeType.root_id;
      if (
        rootId === INSTRUMENT_ROOT_ID ||
        rootId === VOCAL_ROOT_ID
      ) {
        existingInstrumentAndVocalIds.add(linkAttribute.typeID);
      }
    }
  }

  for (const linkAttribute of tree.iterate(relationship.attributes)) {
    const linkAttributeType =
      linkedEntities.link_attribute_type[linkAttribute.typeID];
    const rootId = linkAttributeType.root_id;
    if (
      rootId === INSTRUMENT_ROOT_ID || rootId === VOCAL_ROOT_ID
    ) {
      if (existingInstrumentAndVocalIds.has(linkAttribute.typeID)) {
        /*
         * The attribute type exists on the original relationship, but the
         * new version may have a different attribute credit, which we want
         * to preserve.
         */
        preservedInstrumentsAndVocals = tree.insert(
          preservedInstrumentsAndVocals,
          linkAttribute,
          compareLinkAttributeIds,
        );
      } else {
        addedInstrumentsAndVocals.push(linkAttribute);
      }
    } else {
      otherLinkAttributes = tree.insert(
        otherLinkAttributes,
        linkAttribute,
        compareLinkAttributeIds,
      );
    }
  }

  if (isExistingRelationship) {
    const newRelationship = cloneRelationshipState(relationship);
    newRelationship.attributes = tree.union(
      preservedInstrumentsAndVocals,
      otherLinkAttributes,
      compareLinkAttributeIds,
      onConflictThrowError,
    );
    newRelationship._status = getRelationshipEditStatus(newRelationship);
    if (newRelationship._status === REL_STATUS_NOOP) {
      /*:: invariant(relationship._original); */
      splitRelationships.push(relationship._original);
    } else {
      splitRelationships.push(newRelationship);
    }
  }

  for (const linkAttribute of addedInstrumentsAndVocals) {
    const newRelationship = cloneRelationshipState(relationship);
    newRelationship.id = uniqueNegativeId();
    newRelationship.attributes = tree.insert(
      otherLinkAttributes,
      linkAttribute,
      compareLinkAttributeIds,
    );
    newRelationship._original = null;
    newRelationship._status = REL_STATUS_ADD;
    splitRelationships.push(newRelationship);
  }

  if (!splitRelationships.length) {
    splitRelationships.push(relationship);
  }

  return splitRelationships;
}
