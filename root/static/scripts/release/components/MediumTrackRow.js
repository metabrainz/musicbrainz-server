/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import GroupedTrackRelationships
  from '../../../../components/GroupedTrackRelationships';
import {SanitizedCatalystContext} from '../../../../context.mjs';
import loopParity from '../../../../utility/loopParity';
import ArtistCreditLink
  from '../../common/components/ArtistCreditLink';
import EntityLink from '../../common/components/EntityLink';
import RatingStars from '../../common/components/RatingStars';
import formatTrackLength
  from '../../common/utility/formatTrackLength';
import type {CreditsModeT} from '../types';

type PropsT = {
  +creditsMode: CreditsModeT,
  +index: number,
  +showArtists?: boolean,
  +track: TrackWithRecordingT,
};

const MediumTrackRow = (React.memo<PropsT>(({
  creditsMode,
  index,
  track,
  showArtists,
}: PropsT) => {
  const $c = React.useContext(SanitizedCatalystContext);
  const recordingAC = track.recording?.artistCredit;

  return (
    <tr
      className={loopParity(index) + (track.editsPending ? ' mp' : '')}
      id={track.gid}
    >
      <td className="pos t">
        <a href={'/track/' + track.gid}>{track.number}</a>
      </td>

      <td className="title">
        <EntityLink
          content={track.name}
          entity={track.recording}
        />

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
        <td>
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
}): React.AbstractComponent<PropsT>);

export default MediumTrackRow;
