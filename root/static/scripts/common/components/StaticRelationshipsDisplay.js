/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RelationshipTargetLinks
  from '../../../../components/RelationshipTargetLinks.js';
import {commaOnlyListText} from '../i18n/commaOnlyList.js';
import {bracketedText} from '../utility/bracketed.js';
import {
  type RelationshipTargetTypeGroupT,
  compareTrackPositions,
} from '../utility/groupRelationships.js';

const detailsTableStyle = Object.freeze({width: '100%'});

function formatTrackRange(range: [TrackT, TrackT | null]) {
  if (range[1] == null) {
    return range[0].number;
  }
  return texp.l('{start_track}–{end_track}', {
    end_track: range[1].number,
    start_track: range[0].number,
  });
}

function getTrackRanges(trackSet: Set<TrackT>) {
  const tracks = [...trackSet].sort(compareTrackPositions);

  let range: [TrackT, TrackT | null] = [tracks[0], null];

  const ranges = [range];

  for (let i = 1; i < tracks.length; i++) {
    const track = tracks[i];
    const difference = track.position -
      (range[1] == null ? range[0].position : range[1].position);
    if (difference > 0) {
      if (difference === 1) {
        range[1] = track;
      } else {
        range = [track, null];
        ranges.push(range);
      }
    }
  }

  return commaOnlyListText(ranges.map(formatTrackRange));
}

type PropsT = {
  +hiddenArtistCredit?: ?ArtistCreditT,
  +relationships: $ReadOnlyArray<RelationshipTargetTypeGroupT>,
};

const StaticRelationshipsDisplay = (React.memo<PropsT>(({
  hiddenArtistCredit,
  relationships: groupedRelationships,
}: PropsT): Array<React.Element<'table'>> => {
  const tables = [];

  for (let i = 0; i < groupedRelationships.length; i++) {
    const targetTypeGroup = groupedRelationships[i];
    const relationshipPhraseGroups = targetTypeGroup.relationshipPhraseGroups;
    const targetTypeRows = [];

    for (let j = 0; j < relationshipPhraseGroups.length; j++) {
      const phraseGroup = relationshipPhraseGroups[j];
      const groupSize = phraseGroup.targetGroups.length;
      const phraseRows = [];

      for (let k = 0; k < groupSize; k++) {
        const targetGroup = phraseGroup.targetGroups[k];
        const linkOrder = targetGroup.linkOrder ?? 0;

        const relationshipLink = (
          <RelationshipTargetLinks
            hiddenArtistCredit={hiddenArtistCredit}
            relationship={targetGroup}
          />
        );

        phraseRows.push(
          <React.Fragment key={targetGroup.key}>
            {linkOrder > 0 ? (
              targetGroup.isOrderable ? (
                exp.l('{num}. {relationship}', {
                  num: linkOrder,
                  relationship: relationshipLink,
                })
              ) : (
                exp.l('{relationship} (order: {num})', {
                  num: linkOrder,
                  relationship: relationshipLink,
                })
              )
            ) : relationshipLink}
            {targetGroup.tracks ? (
              <>
                {' '}
                <span className="comment">
                  {bracketedText(
                    texp.ln(
                      'track {tracks}',
                      'tracks {tracks}',
                      targetGroup.tracks.size,
                      {tracks: getTrackRanges(targetGroup.tracks)},
                    ),
                  )}
                </span>
              </>
            ) : null}
            <br />
          </React.Fragment>,
        );
      }

      targetTypeRows.push(
        <tr key={phraseGroup.key}>
          <th>{addColon(phraseGroup.combinedPhrase)}</th>
          <td style={{wordBreak: 'break-all'}}>{phraseRows}</td>
        </tr>,
      );
    }

    tables.push(
      <table
        className="details"
        key={targetTypeGroup.targetType}
        style={detailsTableStyle}
      >
        <tbody>
          {targetTypeRows}
        </tbody>
      </table>,
    );
  }

  return tables;
}): React.AbstractComponent<PropsT>);

export default StaticRelationshipsDisplay;
