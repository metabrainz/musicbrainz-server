/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';
import commaList from '../static/scripts/common/i18n/commaList';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import {bracketedText} from '../static/scripts/common/utility/bracketed';
import {interpolate} from '../static/scripts/edit/utility/linkPhrase';
import groupRelationships, {
  type RelationshipPhraseGroupT,
  type RelationshipTargetGroupT,
} from '../utility/groupRelationships';
import relationshipDateText from '../utility/relationshipDateText';

import RelationshipTargetLinks from './RelationshipTargetLinks';

type Props = {
  +source: CoreEntityT,
};

const renderTargetGroup = (targetGroup: RelationshipTargetGroupT) => (
  <RelationshipTargetLinks relationship={targetGroup} />
);

const renderPhraseGroup = (phraseGroup: RelationshipPhraseGroupT) => (
  <React.Fragment key={phraseGroup.key}>
    <dt>{addColon(phraseGroup.combinedPhrase)}</dt>
    <dd>
      {commaList(
        phraseGroup.targetGroups.map(renderTargetGroup),
      )}
    </dd>
  </React.Fragment>
);

const renderWorkRelationship = (relationship: RelationshipT) => {
  const work = relationship.target;
  const phrase = interpolate(
    linkedEntities.link_type[relationship.linkTypeID],
    relationship.attributes,
    relationship.backward ? 'reverse_link_phrase' : 'link_phrase',
    /*
     * Work relationships are not grouped together on a single line,
     * because we have to output the relationships of the work under
     * its parent recording-work relationship. So it's intentional that
     * we use forGrouping=false here.
     */
    false, /* forGrouping */
  );

  const title = relationship.editsPending
    ? <span className="mp">{phrase}</span>
    : phrase;

  const targetCredit = relationship.backward
    ? relationship.entity0_credit
    : relationship.entity1_credit;

  return (
    <React.Fragment key={relationship.id}>
      <dt>{addColon(title)}</dt>
      <dd>
        <EntityLink content={targetCredit} entity={work} showIcon />
        {' '}
        {bracketedText(relationshipDateText(
          relationship,
          false /* bracketEnded */,
        ))}
        <GroupedTrackRelationships source={work} />
      </dd>
    </React.Fragment>
  );
};

/*
 * Specifically ignore rels that do not give information
 * relevant to this track, such as other arrangements of the work,
 * all the parts of the work linked, or all remixes of this recording.
 *
 * The format of the map is [id, is backward (direction)]
 */
const irrelevantLinkTypes: {
  [entity: CoreEntityTypeT]: Map<number, boolean>,
} = {
  recording: new Map([
    [226, false], // karaoke versions of this
    [227, true], // DJ-mixes of this
    [228, true], // recordings compiling this one
    [230, true], // remixes of this
    [231, true], // recordings sampling this one
    [232, true], // mash-ups of this
    [309, true], // edits of this
  ]),
  work: new Map([
    [239, true], // medleys including this
    [241, false], // generic later versions
    [281, false], // parts
    [314, false], // works based on this
    [315, false], // revisions
    [316, false], // orchestrations
    [350, false], // arrangements
  ]),
};

export function isIrrelevantLinkType(
  relationship: RelationshipT,
  targetType: CoreEntityTypeT,
): boolean {
  const irrelevantTypesForTargetType = irrelevantLinkTypes[targetType];
  if (irrelevantTypesForTargetType == null) {
    return false;
  }
  return irrelevantTypesForTargetType.get(relationship.linkTypeID) ===
    relationship.backward;
}

const GroupedTrackRelationships = ({
  source,
}: Props): Array<React.Element<'dl'>> => {
  const workRelationships = [];

  const groupedRelationships = groupRelationships(
    source.relationships,
    {
      filter: (
        relationship: RelationshipT,
        target: CoreEntityT,
        targetType: CoreEntityTypeT,
      ) => {
        if (targetType === 'work') {
          if (!isIrrelevantLinkType(relationship, targetType)) {
            workRelationships.push(relationship);
          }
          return false;
        }
        if (targetType === 'url') {
          return false;
        }
        if (!isIrrelevantLinkType(relationship, targetType)) {
          return true;
        }
        return false;
      },
    },
  );

  const arsList = [];

  for (const targetTypeGroup of groupedRelationships) {
    const targetType = targetTypeGroup.targetType;
    if (targetType === 'url') {
      continue;
    }
    arsList.push(
      <dl className="ars" key={targetType}>
        {targetTypeGroup.relationshipPhraseGroups.map(renderPhraseGroup)}
      </dl>,
    );
  }

  if (workRelationships.length) {
    arsList.push(
      <dl className="ars" key="work">
        {workRelationships.map(renderWorkRelationship)}
      </dl>,
    );
  }

  return arsList;
};

export default GroupedTrackRelationships;
