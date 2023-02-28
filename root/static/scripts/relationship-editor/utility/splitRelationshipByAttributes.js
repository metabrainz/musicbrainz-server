/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as tree from 'weight-balanced-tree';
import {onConflictThrowError} from 'weight-balanced-tree/update';

import {expect} from '../../../../utility/invariant.js';
import {
  INSTRUMENT_ROOT_ID,
  VOCAL_ROOT_ID,
} from '../../common/constants.js';
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
import {
  areLinkAttributesEqual,
  compareLinkAttributeIds,
  compareLinkAttributeRootIds,
  compareLinkAttributes,
} from './compareRelationships.js';
import getRelationshipEditStatus from './getRelationshipEditStatus.js';
import relationshipsAreIdentical from './relationshipsAreIdentical.js';

const isInstrumentOrVocal = (linkAttribute: LinkAttrT): boolean => {
  const linkAttributeType =
    linkedEntities.link_attribute_type[linkAttribute.typeID];
  const rootTypeId = linkAttributeType.root_id;
  return (
    rootTypeId === INSTRUMENT_ROOT_ID ||
    rootTypeId === VOCAL_ROOT_ID
  );
};

/*
 * Implement MBS-1377 in the relationship editor UI. (This is also handled
 * separately on the server.)
 */
export default function splitRelationshipByAttributes(
  relationship: RelationshipStateT,
): $ReadOnlyArray<RelationshipStateT> {
  const splitRelationships = [];
  const origRelationship = isDatabaseRowId(relationship.id)
    ? relationship._original
    : null;
  const newLinkType = expect(
    relationship.linkTypeID == null
      ? null
      : linkedEntities.link_type[relationship.linkTypeID],
  );
  /*
   * Attributes that will be preserved on the original relationship,
   * if this is an existing relationship in the database.
   */
  let attributesForExistingRelationship = null;
  /*
   * Individual instrument and vocal attributes that are to be split
   * into separate relationships.
   */
  let newAttributesToSplit = null;
  // Common attributes that will exist on all split relationships.
  let commonAttributes = null;
  let newAttributes = relationship.attributes;
  let origInstrumentsAndVocals = tree.fromDistinctAscArray(
    tree.toArray(origRelationship ? origRelationship.attributes : null)
      .filter(isInstrumentOrVocal),
  );
  const hasOrigInstrumentsAndVocals = origInstrumentsAndVocals != null;

  /*
   * If this is an existing relationship, split any newly-added instrument
   * and vocal attributes, but preserve existing ones.  Existing ones can be
   * removed/split manually, but it's better not to enter any edits the user
   * didn't intend to, as this can cause confusion.
   */
  for (
    const comparator of [
      /*
       * First, look for an identical attribute in the new set of attributes
       * (including the credited-as field).
       */
      compareLinkAttributes,
      // Otherwise, look for an attribute with just the same type ID.
      compareLinkAttributeIds,
      // Otherwise, use the first attribute with the same root type ID.
      compareLinkAttributeRootIds,
    ]
  ) {
    for (const origAttribute of tree.iterate(origInstrumentsAndVocals)) {
      let preservedAttribute: LinkAttrT | void = tree.find(
        newAttributes,
        origAttribute,
        comparator,
      );
      if (preservedAttribute) {
        const newAttributesForExistingRelationship =
          tree.insertIfNotExists(
            attributesForExistingRelationship,
            preservedAttribute,
            compareLinkAttributeIds,
          );
        /*
         * Note that the relationship dialog also allows adding two of the
         * same instrument or vocal with different credits.  This isn't
         * allowed by our database schema, so such attributes are also split
         * into separate relationships.
         */
        if (
          newAttributesForExistingRelationship ===
          attributesForExistingRelationship
        ) {
          newAttributesToSplit = tree.insertOrThrowIfExists(
            newAttributesToSplit,
            preservedAttribute,
            compareLinkAttributes,
          );
        } else {
          attributesForExistingRelationship =
            newAttributesForExistingRelationship;
        }
        // Remove the attribute we've preserved, so that it's not used twice.
        newAttributes = tree.remove(
          newAttributes,
          preservedAttribute,
          compareLinkAttributes,
        );
        origInstrumentsAndVocals = tree.remove(
          origInstrumentsAndVocals,
          origAttribute,
          compareLinkAttributeIds,
        );
      }
    }
  }

  for (const newAttribute of tree.iterate(newAttributes)) {
    if (isInstrumentOrVocal(newAttribute)) {
      newAttributesToSplit = tree.insertOrThrowIfExists(
        newAttributesToSplit,
        newAttribute,
        compareLinkAttributes,
      );
    } else {
      const newCommonAttributes = tree.insertIfNotExists(
        commonAttributes,
        newAttribute,
        compareLinkAttributeIds,
      );
      if (commonAttributes === newCommonAttributes) {
        const linkAttributeType =
          linkedEntities.link_attribute_type[newAttribute.typeID];
        const rootTypeId = linkAttributeType.root_id;
        const linkTypeAttribute = newLinkType.attributes[rootTypeId];
        if (
          linkTypeAttribute.max == null ||
          linkTypeAttribute.max > 1
        ) {
          const rootAttributeType =
            linkedEntities.link_attribute_type[rootTypeId];
          invariant(
            rootAttributeType.creditable ||
            rootAttributeType.free_text,
            'Got multiple attributes with the same type ID, but they ' +
            'aren\'t creditable or free-text.',
          );
          newAttributesToSplit = tree.insertOrThrowIfExists(
            newAttributesToSplit,
            newAttribute,
            compareLinkAttributes,
          );
        }
      } else {
        commonAttributes = newCommonAttributes;
      }
    }
  }

  if (origRelationship) {
    const newRelationship = cloneRelationshipState(relationship);
    newRelationship._lineage = [
      ...newRelationship._lineage,
      'split attribute onto existing relationship',
    ];
    /*
     * If the existing relationship has no instruments or vocals, add the
     * first new instrument or vocal to it (MBS-12787).
     */
    if (
      newAttributesToSplit != null &&
      !hasOrigInstrumentsAndVocals
    ) {
      let firstInstrumentOrVocalToSplit;
      for (const attribute of tree.iterate(newAttributesToSplit)) {
        if (isInstrumentOrVocal(attribute)) {
          firstInstrumentOrVocalToSplit = attribute;
          break;
        }
      }
      if (firstInstrumentOrVocalToSplit) {
        newAttributesToSplit = tree.remove(
          newAttributesToSplit,
          firstInstrumentOrVocalToSplit,
          compareLinkAttributes,
        );
        attributesForExistingRelationship = tree.insertIfNotExists(
          attributesForExistingRelationship,
          firstInstrumentOrVocalToSplit,
          compareLinkAttributeIds,
        );
      }
    }
    newRelationship.attributes = tree.union(
      attributesForExistingRelationship,
      commonAttributes,
      compareLinkAttributeIds,
      onConflictThrowError,
    );
    newRelationship._status = getRelationshipEditStatus(newRelationship);
    if (newRelationship._status === REL_STATUS_NOOP) {
      splitRelationships.push(origRelationship);
    } else if (relationshipsAreIdentical(newRelationship, relationship)) {
      splitRelationships.push(relationship);
    } else {
      splitRelationships.push(newRelationship);
    }
  }

  /*
   * If (1) this is a new relationship, (2) `newAttributesToSplit` contains a
   * single attribute, and (3) it's identical to `newAttributes`, then
   * there's nothing to split; we can just return the relationship as-is.
   * (Triggered MBS-12874 in a roundabout way.)
   */
  if (
    origRelationship == null &&
    newAttributesToSplit != null &&
    newAttributesToSplit.size === 1 &&
    areLinkAttributesEqual(newAttributes, newAttributesToSplit)
  ) {
    newAttributesToSplit = null;
  }

  for (const linkAttribute of tree.iterate(newAttributesToSplit)) {
    const newRelationship = cloneRelationshipState(relationship);
    newRelationship._lineage = [
      ...newRelationship._lineage,
      'split attribute onto new relationship',
    ];
    newRelationship.id = uniqueNegativeId();
    newRelationship.attributes = tree.insert(
      commonAttributes,
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
