/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import TrackDurationChanges from '../edit/components/TrackDurationChanges.js';
import Layout from '../layout/index.js';
import MediumTracklist from '../medium/MediumTracklist.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';
import {arraysEqual} from '../static/scripts/common/utility/arrays.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';
import mediumFormatName
  from '../static/scripts/common/utility/mediumFormatName.js';

type AttachCDTocConfirmationProps = {
  +cdToc: CDTocT,
  +form: ConfirmFormT,
  +medium: $ReadOnly<{...MediumT, +cdtoc_tracks: $ReadOnlyArray<TrackT>}>,
};

const AttachCDTocConfirmation = ({
  cdToc,
  form,
  medium,
}: AttachCDTocConfirmationProps): React.Element<typeof Layout> => {
  const newLengths = cdToc.track_details.map(track => track.length_time);
  const oldLengths = medium.cdtoc_tracks.map(track => track.length);
  const release = linkedEntities.release[medium.release_id];
  const areFormattedLengthsEqual = arraysEqual(
    oldLengths,
    newLengths,
    (a, b) => formatTrackLength(a) === formatTrackLength(b),
  );

  return (
    <Layout fullWidth title={lp('Attach CD TOC', 'header')}>
      <h1>{lp('Attach CD TOC', 'header')}</h1>

      <p>
        {exp.l(
          `Are you sure that you wish to attach the disc ID
           <code>{discid}</code> to {format} {pos} of {release} by {artist}?`,
          {
            artist: <ArtistCreditLink artistCredit={release.artistCredit} />,
            discid: cdToc.discid,
            format: mediumFormatName(medium),
            pos: medium.position,
            release: <EntityLink entity={release} />,
          },
        )}
      </p>

      <h2>{l('Medium')}</h2>
      <table className="tbl">
        <thead>
          <tr>
            <th>{l('#')}</th>
            <th>{l('Title')}</th>
            <th>{l('Artist')}</th>
            <th>{l('Length')}</th>
          </tr>
        </thead>
        <tbody>
          <MediumTracklist showArtists tracks={medium.tracks} />
        </tbody>
      </table>

      <h2>{l('Track duration comparison')}</h2>

      {areFormattedLengthsEqual ? (
        <p>
          {l('This edit would only make subsecond changes to track lengths.')}
        </p>
      ) : (
        <TrackDurationChanges
          newLabel={addColonText(l('CD TOC track lengths'))}
          newLengths={newLengths}
          oldLabel={addColonText(l('Medium track lengths'))}
          oldLengths={oldLengths}
        />
      )}

      <form method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </Layout>
  );
};

export default AttachCDTocConfirmation;
