/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../context.mjs';
import Layout from '../layout/index.js';
import manifest from '../static/manifest.mjs';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';
import CodeLink from '../static/scripts/common/components/CodeLink.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import ListMergeButtonsRow
  from '../static/scripts/common/components/ListMergeButtonsRow.js';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength.js';
import loopParity from '../utility/loopParity.js';

component Index(
  isrcs: $ReadOnlyArray<IsrcT>,
  recordings: $ReadOnlyArray<RecordingWithArtistCreditT>,
) {
  const $c = React.useContext(SanitizedCatalystContext);
  const userExists = $c.user != null;
  const isrc = isrcs[0];
  return (
    <Layout
      fullWidth
      title={texp.l('ISRC “{isrc}”', {isrc: isrc.isrc})}
    >
      <h1>
        {exp.l(
          'ISRC “{isrc}”',
          {isrc: <CodeLink code={isrc} key="isrc" />},
        )}
      </h1>
      <h2>
        {texp.ln(
          'Associated with {num} recording',
          'Associated with {num} recordings',
          recordings.length,
          {num: recordings.length},
        )}
      </h2>
      <form
        action="/recording/merge_queue"
        method="post"
      >
        <table className="tbl mergeable-table">
          <thead>
            <tr>
              {userExists ? (
                <th>
                  <input type="checkbox" />
                </th>
              ) : null}
              <th>{l('Title')}</th>
              <th>{l('Artist')}</th>
              <th className="treleases">{l('Length')}</th>
            </tr>
          </thead>
          <tbody>
            {recordings.map((recording, index) => (
              <tr
                className={loopParity(index)}
                key={recording.id}
              >
                {userExists ? (
                  <td>
                    <input
                      name="add-to-merge"
                      type="checkbox"
                      value={recording.id}
                    />
                  </td>
                ) : null}
                <td><EntityLink entity={recording} /></td>
                <td>
                  <ArtistCreditLink artistCredit={recording.artistCredit} />
                </td>
                <td>{formatTrackLength(recording.length)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {userExists ? (
          <>
            <ListMergeButtonsRow
              label={l('Add selected recordings for merging')}
            />
            {manifest(
              'common/components/ListMergeButtonsRow',
              {async: 'async'},
            )}
          </>
        ) : null}
      </form>
    </Layout>
  );
}

export default Index;
