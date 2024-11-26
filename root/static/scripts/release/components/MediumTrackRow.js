/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import GroupedTrackRelationships
  from '../../../../components/GroupedTrackRelationships.js';
import {SanitizedCatalystContext} from '../../../../context.mjs';
import loopParity from '../../../../utility/loopParity.js';
import ArtistCreditLink
  from '../../common/components/ArtistCreditLink.js';
import EntityLink from '../../common/components/EntityLink.js';
import RatingStars from '../../common/components/RatingStars.js';
import formatTrackLength
  from '../../common/utility/formatTrackLength.js';
import type {CreditsModeT} from '../types.js';

component _MediumTrackRow(
  creditsMode: CreditsModeT,
  index: number,
  showArtists: boolean = false,
  track: TrackWithRecordingT,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const recordingAC = track.recording?.artistCredit;
  const recordingAlias = track.recording?.primaryAlias;

  return (
    <tr
      className={loopParity(index) + (track.editsPending ? ' mp' : '')}
      id={track.gid}
    >
      <td className="pos t">
        <a href={'/track/' + track.gid}>{track.number}</a>
      </td>

      <td className="title wrap-anywhere">
        <EntityLink
          content={track.name}
          entity={track.recording}
        />

        {/* Show recording primary alias only to logged in users to avoid
          * confusing visitors with recordings.
          */}
        {(
          $c.user &&
          nonEmpty(recordingAlias) &&
          track.name !== recordingAlias
        ) ? (
          <div className="small">
            {texp.l(
              'Recording alias: {alias}',
              {alias: recordingAlias},
            )}
          </div>
          ) : null}

        {/* Show recording artist only to logged in users to avoid confusing
          * visitors with recordings.
          */}
        {(
          $c.user &&
          recordingAC &&
          track.artistCredit.id !== recordingAC.id
        ) ? (
          <div className="small">
            {l('Recording artist:')}
            {' '}
            <ArtistCreditLink artistCredit={recordingAC} />
          </div>
          ) : null}

        {creditsMode === 'inline' ? (
          <div className="ars">
            <GroupedTrackRelationships source={track.recording} />
          </div>
        ) : null}
      </td>

      {showArtists ? (
        <td className="wrap-anywhere">
          <ArtistCreditLink artistCredit={track.artistCredit} />
        </td>
      ) : null}

      <td className="rating c">
        <RatingStars entity={track.recording} />
      </td>

      <td className="treleases">
        {formatTrackLength(track.length)}
      </td>
    </tr>
  );
}

const MediumTrackRow: React.AbstractComponent<
  React.PropsOf<_MediumTrackRow>
> = React.memo(_MediumTrackRow);

export default MediumTrackRow;
