/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {CatalystContext, withCatalystContext} from '../../context';
import {l} from '../../static/scripts/common/i18n';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon';
import formatTrackLength from '../../static/scripts/common/utility/formatTrackLength';
import loopParity from '../../utility/loopParity';
import type {InlineResultsPropsT, ResultsPropsT} from '../types';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import CodeLink from '../../static/scripts/common/components/CodeLink';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';

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

const buildTaggerIcon = entity => (
  <CatalystContext.Consumer>
    {$c => $c.session && $c.session.tport
      ? <td><TaggerIcon entity={entity} /></td>
      : null}
  </CatalystContext.Consumer>
);

function buildResultWithReleases(result, index, tport) {
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
        {buildTaggerIcon(release)}
        <td>
          {extraRow.track_position + '/' + extraRow.medium_track_count}
        </td>
        <td>{extraRow.medium_position}</td>
        <td>
          {releaseGroup && releaseGroup.typeName
            ? lp_attributes(releaseGroup.typeName, 'release_group_primary_type')
            : null}
        </td>
      </tr>
    );
  });
}

function buildResult(result, index) {
  const recording = result.entity;
  const score = result.score;

  return (
    result.extra && result.extra.length
      ? buildResultWithReleases(result, index)
      : (
        <tr
          className={loopParity(linenum++)}
          data-score={score}
          key={recording.id}
        >
          {buildRecordingColumns(recording)}
          <td>{l('(standalone recording)')}</td>
          {buildTaggerIcon(recording)}
          <td colSpan="3">{'\u00A0'}</td>
        </tr>
      )
  );
}

export const RecordingResultsInline = ({
  $c,
  pager,
  query,
  results,
}: InlineResultsPropsT<RecordingT>) => (
  <PaginatedSearchResults
    buildResult={buildResult}
    columns={
      <>
        <th>{l('Name')}</th>
        <th className="treleases">{l('Length')}</th>
        <th>{l('Artist')}</th>
        <th>{l('ISRCs')}</th>
        <th>{l('Release')}</th>
        {$c.session && $c.session.tport ? <th>{l('Tagger')}</th> : null}
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

const RecordingResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<RecordingT>) => {
  linenum = 0;
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <RecordingResultsInline
        $c={$c}
        pager={pager}
        query={query}
        results={results}
      />
      {$c.user && !$c.user.is_editing_disabled ? (
        <p>
          {l('Alternatively, you may {uri|add a new recording}.', {
            uri: '/recording/create?edit-recording.name=' + encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
};

export default withCatalystContext(RecordingResults);
