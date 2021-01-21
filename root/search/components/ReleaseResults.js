/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import ReleaseEvents
  from '../../static/scripts/common/components/ReleaseEvents';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';
import loopParity from '../../utility/loopParity';
import ReleaseCatnoList from '../../components/ReleaseCatnoList';
import ReleaseLabelList from '../../components/ReleaseLabelList';
import ReleaseLanguageScript from '../../components/ReleaseLanguageScript';
import type {
  InlineResultsPropsWithContextT,
  ResultsPropsWithContextT,
} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult($c, result, index) {
  const release = result.entity;
  const score = result.score;
  const typeName = release.releaseGroup?.typeName;

  return (
    <tr className={loopParity(index)} data-score={score} key={release.id}>
      <td>
        <EntityLink entity={release} />
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
      {$c?.session?.tport == null
        ? null
        : <td><TaggerIcon entity={release} /></td>}
    </tr>
  );
}

export const ReleaseResultsInline = ({
  $c,
  pager,
  query,
  results,
}: InlineResultsPropsWithContextT<ReleaseT>):
React.Element<typeof PaginatedSearchResults> => (
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

const ReleaseResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsWithContextT<ReleaseT>):
React.Element<typeof ResultsLayout> => (
  <ResultsLayout $c={$c} form={form} lastUpdated={lastUpdated}>
    <ReleaseResultsInline
      $c={$c}
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {exp.l('Alternatively, you may {uri|add a new release}.', {
          uri: '/release/add',
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default ReleaseResults;
