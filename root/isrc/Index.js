/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const Layout = require('../layout');
const ArtistCreditLink = require('../static/scripts/common/components/ArtistCreditLink');
const CodeLink = require('../static/scripts/common/components/CodeLink');
const EntityLink = require('../static/scripts/common/components/EntityLink');
const {l, ln} = require('../static/scripts/common/i18n');
const {artistCreditFromArray} = require('../static/scripts/common/immutable-entities');
const formatTrackLength = require('../static/scripts/common/utility/formatTrackLength');

type PropsT = {|
  +isrcs: $ReadOnlyArray<IsrcT>,
  +recordings: $ReadOnlyArray<RecordingT>,
|};

const Index = ({isrcs, recordings}: PropsT) => {
  const userExists = $c.user_exists;
  const isrc = isrcs[0];
  return (
    <Layout fullWidth title={l('ISRC “{isrc}”', {isrc: isrc.isrc})}>
      <h1>
        {l('ISRC “{isrc}”',
          {__react: true, isrc: <CodeLink code={isrc} key="isrc" />})}
      </h1>
      <h2>
        {ln(
          'Associated with {num} recording',
          'Associated with {num} recordings',
          recordings.length,
          {num: recordings.length},
        )}
      </h2>
      <form action="/recording/merge_queue" method="post">
        <table className="tbl">
          <thead>
            <tr>
              {userExists ? (
                <th style={{width: '1em'}}>
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
                className={(index + 1) % 2 ? 'odd' : 'even'}
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
                  <ArtistCreditLink
                    artistCredit={
                      artistCreditFromArray(recording.artistCredit)
                    }
                  />
                </td>
                <td>{formatTrackLength(recording.length)}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {userExists ? (
          <div className="row">
            <span className="buttons">
              <button type="submit">{l('Add selected recordings for merging')}</button>
            </span>
          </div>
        ) : null}
      </form>
    </Layout>
  );
};

module.exports = Index;
