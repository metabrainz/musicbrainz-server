/*
 * @flow strict-local
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink';
import CodeLink from '../static/scripts/common/components/CodeLink';
import EntityLink from '../static/scripts/common/components/EntityLink';
import formatTrackLength
  from '../static/scripts/common/utility/formatTrackLength';
import loopParity from '../utility/loopParity';
import {returnToCurrentPage} from '../utility/returnUri';

type PropsT = {
  +$c: CatalystContextT,
  +isrcs: $ReadOnlyArray<IsrcT>,
  +recordings: $ReadOnlyArray<RecordingT>,
};

const Index = ({
  $c,
  isrcs,
  recordings,
}: PropsT): React.Element<typeof Layout> => {
  const userExists = !!$c.user;
  const isrc = isrcs[0];
  return (
    <Layout
      $c={$c}
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
        action={'/recording/merge_queue?' + returnToCurrentPage($c)}
        method="post"
      >
        <table className="tbl">
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
          <div className="row">
            <span className="buttons">
              <button type="submit">
                {l('Add selected recordings for merging')}
              </button>
            </span>
          </div>
        ) : null}
      </form>
    </Layout>
  );
};

export default Index;
