/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import * as manifest from '../../static/manifest.mjs';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges';
import loopParity from '../../utility/loopParity';
import type {
  InlineResultsPropsWithContextT,
  ResultsPropsWithContextT,
} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import CodeLink from '../../static/scripts/common/components/CodeLink';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

let linenum = 0;

const buildRecordingColumns = recording => (
  <>
    <td>
      <EntityLink entity={recording} />
    </td>
    <td>{formatTrackLength(recording.length)}</td>
    <td>
      <ArtistCreditLink artistCredit={recording.artistCredit} />
    </td>
    <td>
      <ul>
        {recording.isrcs.map(isrc => (
          <li key={isrc.isrc}>
            <CodeLink code={isrc} />
          </li>
        ))}
      </ul>
    </td>
  </>
);

const buildTaggerIcon = ($c, entityType, gid) => (
  $c.session?.tport == null ? null : (
    <td>
      <TaggerIcon entityType={entityType} gid={gid} />
    </td>
  )
);

function buildResultWithReleases($c, result) {
  const recording = result.entity;
  const score = result.score;

  return result.extra.map((extraRow, extraIndex) => {
    const release = extraRow.release;
    const releaseGroup = release.releaseGroup;
    const key = String(recording.id) + '-' + String(release.id);

    return (
      <tr className={loopParity(linenum++)} data-score={score} key={key}>
        {extraIndex === 0
          ? buildRecordingColumns(recording)
          : <td colSpan="4">{'\u00A0'}</td>}
        <td>
          <EntityLink entity={release} />
        </td>
        {buildTaggerIcon($c, 'release', release.gid)}
        <td>
          {extraRow.track_position + '/' + extraRow.medium_track_count}
        </td>
        <td>{extraRow.medium_position}</td>
        <td>
          {releaseGroup && nonEmpty(releaseGroup.typeName)
            ? lp_attributes(
              releaseGroup.typeName, 'release_group_primary_type',
            )
            : null}
        </td>
      </tr>
    );
  });
}

function buildResult($c, result) {
  const recording = result.entity;
  const score = result.score;

  return (
    result.extra?.length
      ? buildResultWithReleases($c, result)
      : (
        <tr
          className={loopParity(linenum++)}
          data-score={score}
          key={recording.id}
        >
          {buildRecordingColumns(recording)}
          <td>{l('(standalone recording)')}</td>
          {buildTaggerIcon($c, 'recording', recording.gid)}
          <td colSpan="3">{'\u00A0'}</td>
        </tr>
      )
  );
}

export const RecordingResultsInline = ({
  pager,
  query,
  results,
}: InlineResultsPropsWithContextT<RecordingWithArtistCreditT>):
React.Element<typeof PaginatedSearchResults> => {
  const $c = React.useContext(CatalystContext);

  return (
    <PaginatedSearchResults
      buildResult={result => buildResult($c, result)}
      columns={
        <>
          <th>{l('Name')}</th>
          <th className="treleases">{l('Length')}</th>
          <th>{l('Artist')}</th>
          <th>{l('ISRCs')}</th>
          <th>{l('Release')}</th>
          {$c?.session?.tport == null ? null : <th>{l('Tagger')}</th>}
          <th className="t pos">{l('Track')}</th>
          <th>{l('Medium')}</th>
          <th>{l('Type')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  );
};

const RecordingResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<RecordingWithArtistCreditT>):
React.Element<typeof ResultsLayout> => {
  linenum = 0;
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <RecordingResultsInline
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new recording}.', {
            uri: '/recording/create?edit-recording.name=' +
              encodeURIComponent(query),
          })}
        </p>
      ) : null}
      {manifest.js('common/components/TaggerIcon', {async: 'async'})}
    </ResultsLayout>
  );
};

export default RecordingResults;
