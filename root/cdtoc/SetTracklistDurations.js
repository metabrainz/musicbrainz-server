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
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import linkedEntities from '../static/scripts/common/linkedEntities.mjs';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';
import {arraysEqual} from '../static/scripts/common/utility/arrays.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';

import CDTocInfo from './CDTocInfo.js';

type SetTracklistDurationsProps = {
  +cdToc: CDTocT,
  +form: ConfirmFormT,
  +medium: $ReadOnly<{...MediumT, +cdtoc_tracks: $ReadOnlyArray<TrackT>}>,
};

const SetTracklistDurations = ({
  cdToc,
  form,
  medium,
}: SetTracklistDurationsProps): React.Element<typeof Layout> => {
  const newLengths = cdToc.track_details.map(track => track.length_time);
  const oldLengths = medium.cdtoc_tracks.map(track => track.length);
  const release = linkedEntities.release[medium.release_id];
  const areFormattedLengthsEqual = arraysEqual(
    oldLengths,
    newLengths,
    (a, b) => formatTrackLength(a) === formatTrackLength(b),
  );

  return (
    <Layout fullWidth title={l('Set Tracklist Durations')}>
      <h1>{l('Set Tracklist Durations')}</h1>

      <p>
        {l(`You are about to enter an edit that will change
            the durations of tracks to match that of the below disc ID.`)}
      </p>

      <CDTocInfo cdToc={cdToc} />

      <h2>{l('Medium')}</h2>
      <table className="tbl">
        <tbody>
          <MediumTracklist showArtists tracks={medium.tracks} />
        </tbody>
      </table>

      <h2>{l('Changes')}</h2>

      {areFormattedLengthsEqual ? (
        <p>
          {l('This edit would only make subsecond changes to track lengths.')}
        </p>
      ) : (
        <TrackDurationChanges
          newLengths={newLengths}
          oldLengths={oldLengths}
        />
      )}

      <p>
        {exp.l(
          `The medium you are altering
           is part of the following release: {release}`,
          {release: <DescriptiveLink entity={release} />},
        )}
      </p>

      <form method="post">
        <EnterEditNote field={form.field.edit_note} />
        <EnterEdit form={form} />
      </form>
    </Layout>
  );
};

export default SetTracklistDurations;
