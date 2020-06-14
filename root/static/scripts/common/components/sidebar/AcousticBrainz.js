/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import hydrate from '../../../../../utility/hydrate';
import {SidebarProperty, SidebarProperties} from
  '../../../../../layout/components/sidebar/SidebarProperties';

const SidebarAcousticBrainz = ({recording}: {recording: RecordingT}) => {
  const [count, setCount] = React.useState(0);
  const [data, setData] = React.useState(null);

  function fetchAcousticBrainzCount() {
    const countUrl = `//acousticbrainz.org/api/v1/${recording.gid}/count`;
    fetch(countUrl).then(
      resp => resp.json(),
    ).then(
      data => {
        setCount(data.count);
        if (data.count) {
          fetchAcousticBrainzData();
        }
      },
    );
  }

  function fetchAcousticBrainzData() {
    const dataUrl = `//acousticbrainz.org/api/v1/${recording.gid}/low-level`;
    fetch(dataUrl).then(
      resp => resp.json(),
    ).then(
      data => {
        setData(data);
      },
    );
  }

  React.useEffect(fetchAcousticBrainzCount, [recording.gid]);
  return count ? (
    <>
      <h2>
        {l('Acoustic information')}
      </h2>

      <a className="external" href={`//acousticbrainz.org/${recording.gid}`}>
        {texp.ln(
          '{count} submission on AcousticBrainz',
          '{count} submissions on AcousticBrainz',
          count,
          {count},
        )}
      </a>

      {data === null ? null : (
        <SidebarProperties>

          {data.tonal.key_strength > 0.5 ? (
            <SidebarProperty className="acousticbrainz_key" label={l('Key:')}>
              {`${data.tonal.key_key} ${data.tonal.key_scale}`}
            </SidebarProperty>
          ) : null}

          <SidebarProperty className="acousticbrainz_bpm" label={l('BPM:')}>
            {Math.round(data.rhythm.bpm)}
          </SidebarProperty>
        </SidebarProperties>
      )}
    </>
  ) : null;
};

export default (hydrate<{recording: RecordingT}>(
  'div.acousticbrainz',
  SidebarAcousticBrainz,
): React.AbstractComponent<{recording: RecordingT}, void>);
