/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import * as manifest from '../../static/manifest.mjs';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import IsrcList from '../../static/scripts/common/components/IsrcList.js';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import loopParity from '../../utility/loopParity.js';
import type {
  InlineResultsPropsT,
  ResultsPropsT,
  SearchResultT,
} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

let linenum = 0;

const buildRecordingColumns = (recording: RecordingWithArtistCreditT) => (
  <>
    <td>
      <EntityLink entity={recording} />
    </td>
    <td>{formatTrackLength(recording.length)}</td>
    <td>
      <ArtistCreditLink artistCredit={recording.artistCredit} />
    </td>
    <td>
      <IsrcList isrcs={recording.isrcs} />
      {manifest.js(
        'common/components/IsrcList',
        {async: 'async'},
      )}
    </td>
  </>
);

const buildTaggerIcon = (
  $c: CatalystContextT,
  entityType: 'recording' | 'release',
  gid: string,
) => (
  $c.session?.tport == null ? null : (
    <td>
      <TaggerIcon entityType={entityType} gid={gid} />
    </td>
  )
);

function buildResultWithReleases(
  $c: CatalystContextT,
  result: SearchResultT<RecordingWithArtistCreditT>,
) {
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

function buildResult(
  $c: CatalystContextT,
  result: SearchResultT<RecordingWithArtistCreditT>,
) {
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
}: InlineResultsPropsT<RecordingWithArtistCreditT>):
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
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<RecordingWithArtistCreditT>):
React.Element<typeof ResultsLayout> => {
  const $c = React.useContext(CatalystContext);
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
