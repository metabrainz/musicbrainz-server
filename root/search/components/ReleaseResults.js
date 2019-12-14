/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext, withCatalystContext} from '../../context';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import TaggerIcon from '../../static/scripts/common/components/TaggerIcon';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';
import loopParity from '../../utility/loopParity';
import ReleaseCatnoList from '../../components/ReleaseCatnoList';
import ReleaseCountries from '../../components/ReleaseCountries';
import ReleaseDates from '../../components/ReleaseDates';
import ReleaseLabelList from '../../components/ReleaseLabelList';
import type {InlineResultsPropsT, ResultsPropsWithContextT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const release = result.entity;
  const score = result.score;
  const {language, script} = release;
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
        {release.combined_format_name || l('[missing media]')}
      </td>
      <td>
        {release.combined_track_count || lp('-', 'missing data')}
      </td>
      <td>
        <ReleaseDates events={release.events} />
      </td>
      <td>
        <ReleaseCountries events={release.events} />
      </td>
      <td>
        <ReleaseLabelList labels={release.labels} />
      </td>
      <td>
        <ReleaseCatnoList labels={release.labels} />
      </td>
      <td className="barcode-cell">{formatBarcode(release.barcode)}</td>
      <td>
        {language ? (
          <abbr title={l_languages(language.name)}>
            {language.iso_code_3}
          </abbr>
        ) : null}
        {language && script ? ' / ' : null}
        {script ? (
          <abbr title={l_scripts(script.name)}>
            {script.iso_code}
          </abbr>
        ) : null}
      </td>
      <td>
        {typeName
          ? lp_attributes(typeName, 'release_group_primary_type')
          : null}
      </td>
      <td>
        {release.status
          ? lp_attributes(release.status.name, 'release_status') : null}
      </td>
      <CatalystContext.Consumer>
        {($c: CatalystContextT) => (
          $c.session?.tport
            ? <td><TaggerIcon entity={release} /></td>
            : null
        )}
      </CatalystContext.Consumer>
    </tr>
  );
}

export const ReleaseResultsInline = ({
  $c,
  pager,
  query,
  results,
}: InlineResultsPropsT<ReleaseT>) => (
  <PaginatedSearchResults
    buildResult={buildResult}
    columns={
      <>
        <th>{l('Name')}</th>
        <th>{l('Artist')}</th>
        <th>{l('Format')}</th>
        <th>{l('Tracks')}</th>
        <th>{l('Date')}</th>
        <th>{l('Country')}</th>
        <th>{l('Label')}</th>
        <th>{l('Catalog#')}</th>
        <th>{l('Barcode')}</th>
        <th>{l('Language')}</th>
        <th>{l('Type')}</th>
        <th>{l('Status')}</th>
        {$c?.session?.tport ? <th>{l('Tagger')}</th> : null}
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
}: ResultsPropsWithContextT<ReleaseT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
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

export default withCatalystContext(ReleaseResults);
