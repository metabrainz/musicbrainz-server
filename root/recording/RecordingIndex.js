/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../components/PaginatedResults';
import Relationships from '../components/Relationships';
import ReleaseLabelList from '../components/ReleaseLabelList';
import ReleaseCatnoList from '../components/ReleaseCatnoList';
import Annotation from '../static/scripts/common/components/Annotation';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import ReleaseEvents from '../static/scripts/common/components/ReleaseEvents';
import linkedEntities from '../static/scripts/common/linkedEntities';
import isolateText from '../static/scripts/common/utility/isolateText';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength';
import loopParity from '../utility/loopParity';

import RecordingLayout from './RecordingLayout';

type Props = {
  +$c: CatalystContextT,
  +numberOfRevisions: number,
  +pager: PagerT,
  +recording: RecordingWithArtistCreditT,
  +tracks: $ReadOnlyArray<$ReadOnlyArray<{...TrackT, +medium: MediumT}>>,
};

const RecordingAppearancesTable = ({
  recording,
  tracks,
}: {
  recording: RecordingWithArtistCreditT,
  tracks: $ElementType<Props, 'tracks'>,
}) => (
  <table className="tbl">
    <thead>
      <tr>
        <th className="t pos">{l('#')}</th>
        <th>{l('Title')}</th>
        <th className="treleases">{l('Length')}</th>
        <th>{l('Track Artist')}</th>
        <th>{l('Release Title')}</th>
        <th>{l('Release Artist')}</th>
        <th>{l('Release Group Type')}</th>
        <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
        <th>{l('Label')}</th>
        <th>{l('Catalog#')}</th>
      </tr>
    </thead>
    <tbody>
      {tracks.map((tracksWithReleaseStatus) => {
        const sampleRelease =
          linkedEntities.release[
            tracksWithReleaseStatus[0].medium.release_id
          ];
        const status = sampleRelease.status;
        return (
          <React.Fragment key={status ? status.name : 'no-status'}>
            <tr className="subh">
              <th colSpan="10">
                {status
                  ? lp_attributes(status.name, 'release_status')
                  : lp('(unknown)', 'release status')
                }
              </th>
            </tr>
            {tracksWithReleaseStatus.map((track, index) => {
              const release =
                linkedEntities.release[track.medium.release_id];
              return (
                <tr className={loopParity(index)} key={track.gid}>
                  <td>
                    <a
                      href={`/track/${track.gid}`}
                      title={texp.l(
                        'Medium {medium_num}, track {track_num}',
                        {
                          medium_num: track.medium.position,
                          track_num: track.position,
                        },
                      )}
                    >
                      {`${track.medium.position}.${track.position}`}
                    </a>
                  </td>
                  <td>{isolateText(track.name)}</td>
                  <td>{formatTrackLength(track.length)}</td>
                  {/* The class being added is for usage with userscripts */}
                  <td className={
                    track.artistCredit.id === recording.artistCredit.id
                      ? null
                      : 'artist-credit-variation'}
                  >
                    <ArtistCreditLink artistCredit={track.artistCredit} />
                  </td>
                  <td>
                    <EntityLink entity={release} />
                  </td>
                  <td>
                    <ArtistCreditLink artistCredit={release.artistCredit} />
                  </td>
                  <td>
                    {release.releaseGroup &&
                      nonEmpty(release.releaseGroup.typeName)
                      ? lp_attributes(
                        release.releaseGroup.typeName,
                        'release_group_primary_type',
                      )
                      : null}
                  </td>
                  <td>
                    <ReleaseEvents events={release.events} />
                  </td>
                  <td>
                    <ReleaseLabelList labels={release.labels} />
                  </td>
                  <td>
                    <ReleaseCatnoList labels={release.labels} />
                  </td>
                </tr>
              );
            })}
          </React.Fragment>
        );
      })}
    </tbody>
  </table>
);

const RecordingIndex = ({
  $c,
  numberOfRevisions,
  pager,
  recording,
  tracks,
}: Props): React.Element<typeof RecordingLayout> => (
  <RecordingLayout $c={$c} entity={recording} page="index">
    <Annotation
      annotation={recording.latest_annotation}
      collapse
      entity={recording}
      numberOfRevisions={numberOfRevisions}
    />
    <h2 className="appears-on-releases">{l('Appears on releases')}</h2>
    <PaginatedResults pager={pager}>
      {tracks?.length ? (
        <RecordingAppearancesTable recording={recording} tracks={tracks} />
      ) : (
        <p>{l('No releases found which feature this recording.')}</p>
      )}
    </PaginatedResults>
    <Relationships source={recording} />
  </RecordingLayout>
);

export default RecordingIndex;
