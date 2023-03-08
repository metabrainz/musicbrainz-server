/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseCatnoList from '../../components/ReleaseCatnoList.js';
import ReleaseLabelList from '../../components/ReleaseLabelList.js';
import ReleaseLanguageScript from '../../components/ReleaseLanguageScript.js';
import {CatalystContext} from '../../context.mjs';
import * as manifest from '../../static/manifest.mjs';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink.js';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents.js';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon.js';
import formatBarcode
  from '../../static/scripts/common/utility/formatBarcode.js';
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

function buildResult(
  $c: CatalystContextT,
  result: SearchResultT<ReleaseT>,
  index: number,
) {
  const release = result.entity;
  const score = result.score;
  const typeName = release.releaseGroup?.typeName;

  return (
    <tr className={loopParity(index)} data-score={score} key={release.id}>
      <td>
        <EntityLink entity={release} showCaaPresence />
      </td>
      <td>
        <ArtistCreditLink artistCredit={release.artistCredit} />
      </td>
      <td>
        {nonEmpty(release.combined_format_name)
          ? release.combined_format_name
          : l('[missing media]')}
      </td>
      <td>
        {nonEmpty(release.combined_track_count)
          ? release.combined_track_count
          : lp('-', 'missing data')}
      </td>
      <td>
        <ReleaseEvents events={release.events} />
        {manifest.js(
          'common/components/ReleaseEvents',
          {async: 'async'},
        )}
      </td>
      <td>
        <ReleaseLabelList labels={release.labels} />
      </td>
      <td>
        <ReleaseCatnoList labels={release.labels} />
      </td>
      <td className="barcode-cell">{formatBarcode(release.barcode)}</td>
      <td>
        <ReleaseLanguageScript release={release} />
      </td>
      <td>
        {nonEmpty(typeName)
          ? lp_attributes(typeName, 'release_group_primary_type')
          : null}
      </td>
      <td>
        {release.status
          ? lp_attributes(release.status.name, 'release_status') : null}
      </td>
      {$c.session?.tport == null ? null : (
        <td>
          <TaggerIcon entityType="release" gid={release.gid} />
        </td>
      )}
    </tr>
  );
}

export const ReleaseResultsInline = ({
  pager,
  query,
  results,
}: InlineResultsPropsT<ReleaseT>):
React$Element<typeof PaginatedSearchResults> => {
  const $c = React.useContext(CatalystContext);

  return (
    <PaginatedSearchResults
      buildResult={(result, index) => buildResult($c, result, index)}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Artist')}</th>
          <th>{l('Format')}</th>
          <th>{l('Tracks')}</th>
          <th>{l('Country') + lp('/', 'and') + l('Date')}</th>
          <th>{l('Label')}</th>
          <th>{l('Catalog#')}</th>
          <th>{l('Barcode')}</th>
          <th>{l('Language')}</th>
          <th>{l('Type')}</th>
          <th>{l('Status')}</th>
          {$c?.session?.tport == null
            ? null
            : <th>{l('Tagger')}</th>}
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  );
};

const ReleaseResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<ReleaseT>): React$Element<typeof ResultsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <ReleaseResultsInline
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new release}.', {
            uri: '/release/add',
          })}
        </p>
      ) : null}
      {manifest.js('common/components/TaggerIcon', {async: 'async'})}
    </ResultsLayout>
  );
};

export default ReleaseResults;
