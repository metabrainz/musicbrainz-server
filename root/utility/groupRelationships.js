/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {INSTRUMENT_ROOT_ID} from '../static/scripts/common/constants';
import linkedEntities from '../static/scripts/common/linkedEntities';
import {interpolate, interpolateText}
  from '../static/scripts/edit/utility/linkPhrase';

export type GroupedRelationshipsT = {
  [CoreEntityTypeT]: {
    [string]: {
      linkType: LinkTypeT,
      phrase: Expand2ReactOutput,
      relationships: Array<RelationshipT>,
      ...,
    },
    ...,
  },
  ...,
};

export default function groupRelationships(
  relationships: ?$ReadOnlyArray<RelationshipT>,
  types?: ?$ReadOnlyArray<CoreEntityTypeT>,
): GroupedRelationshipsT {
  const result: GroupedRelationshipsT = {};

  if (!relationships) {
    return result;
  }

  for (let i = 0; i < relationships.length; i++) {
    const relationship = relationships[i];
    const targetType = relationship.target.entityType;

    if (types && !types.includes(targetType)) {
      continue;
    }

    const linkPhraseGroup = result[targetType] || (result[targetType] = {});
    const backward = relationship.direction === 'backward';
    const linkType = linkedEntities.link_type[relationship.linkTypeID];

    /*
     * In order to group relationships by link phrase, the link phrase
     * must be a string. However, phrases with instruments contain
     * links, so produce a React element from `interpolate`. We can't
     * use a React element as a grouping key for obvious reasons. (We
     * could convert it to HTML and use that as the key, but the HTML
     * would be more difficult to sort properly.) The solution is to
     * always call `interpolateText` to produce a rendered phrase
     * suitable for grouping. If the relationship contains instruments,
     * we additionally call `interpolate` to produce a phrase with
     * links for display. There's currently no other case where
     * `interpolateText` doesn't suffice for display, so we otherwise
     * just use the `textPhrase` for display if the relationship is
     * instrument-free.
     */
    let hasInstruments = false;
    const linkAttrs = relationship.attributes;
    if (linkAttrs) {
      for (let i = 0; i < linkAttrs.length; i++) {
        const linkAttr = linkAttrs[i];
        const linkAttrType =
          linkedEntities.link_attribute_type[linkAttr.typeID];
        if (linkAttrType.root_id === INSTRUMENT_ROOT_ID) {
          hasInstruments = true;
          break;
        }
      }
    }

    let textPhrase = interpolateText(
      relationship,
      backward ? 'reverse_link_phrase' : 'link_phrase',
      true, /* forGrouping */
    );
    let phrase;

    if (hasInstruments) {
      phrase = interpolate(
        relationship,
        backward ? 'reverse_link_phrase' : 'link_phrase',
        true, /* forGrouping */
      );
    }

    const sourceCredit = backward
      ? relationship.entity1_credit
      : relationship.entity0_credit;

    if (sourceCredit) {
      textPhrase = texp.l('{role} (as {credited_name})', {
        credited_name: sourceCredit,
        role: textPhrase,
      });

      if (hasInstruments /*:: && phrase */) {
        phrase = exp.l('{role} (as {credited_name})', {
          credited_name: sourceCredit,
          role: phrase,
        });
      }
    }

    let group = linkPhraseGroup[textPhrase];
    if (!group) {
      group = {
        linkType,
        phrase: phrase || textPhrase,
        relationships: [],
      };
      linkPhraseGroup[textPhrase] = group;
    }
    group.relationships.push(relationship);
  }

  return result;
}
