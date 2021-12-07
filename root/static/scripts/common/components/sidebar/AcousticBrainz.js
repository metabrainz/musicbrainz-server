/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SidebarProperty, SidebarProperties} from
  '../../../../../layout/components/sidebar/SidebarProperties';

const KEY_LABELS = {
  'A#': 'A♯/B♭',
  'C#': 'C♯/D♭',
  'D#': 'D♯/E♭',
  'F#': 'F♯/G♭',
  'G#': 'G♯/A♭',
};

const SidebarAcousticBrainz = ({recording}: {recording: RecordingT}) => {
  const [count, setCount] = React.useState(0);
  const [data, setData] = React.useState(null);

  const fetchAcousticBrainzData = React.useCallback(() => {
    const dataUrl = '//acousticbrainz.org/api/v1/low-level?' +
      `recording_ids=${recording.gid}&` +
      'features=tonal.key_key;tonal.key_scale;tonal.key_strength;rhythm.bpm';
    fetch(dataUrl).then(
      resp => resp.json(),
    ).then(
      data => {
        setData(data[recording.gid][0]);
      },
    );
  }, [recording.gid]);

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

  function keyLabel(key) {
    return key.includes('#') ? KEY_LABELS[key] : key;
  }

  function roundedBPM(data) {
    return Math.round(data.tonal.key_strength * 100) / 100;
  }

  React.useEffect(
    fetchAcousticBrainzCount,
    [recording.gid, fetchAcousticBrainzData],
  );

  return count ? (
    <>
      <h2>
        {l('Acoustic analysis')}
      </h2>

      <a className="external" href={`//acousticbrainz.org/${recording.gid}`}>
        {l('AcousticBrainz entry')}
      </a>

      {data === null ? null : (
        <SidebarProperties>

          {data.tonal.key_strength > 0.5 ? (
            <SidebarProperty className="acousticbrainz_key" label={l('Key:')}>
              <abbr
                title={
                  texp.l(`Automatic suggestion from entry #1/{count}
                          (key strength: {key_strength})`, {
                    count: count,
                    key_strength: roundedBPM(data),
                  })
                }
              >
                {texp.l('{key} {scale}', {
                  key: keyLabel(data.tonal.key_key),
                  scale: data.tonal.key_scale,
                })}
              </abbr>
            </SidebarProperty>
          ) : null}

          <SidebarProperty className="acousticbrainz_bpm" label={l('BPM:')}>
            <abbr
              title={texp.l('Automatic suggestion from entry #1/{count}',
                            {count: count})}
            >
              {Math.round(data.rhythm.bpm)}
            </abbr>
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
