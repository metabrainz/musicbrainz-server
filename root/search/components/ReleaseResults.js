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
import {l} from '../../static/scripts/common/i18n';
import {l_languages} from '../../static/scripts/common/i18n/languages';
import {l_scripts} from '../../static/scripts/common/i18n/scripts';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
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

  return (
    <tr className={loopParity(index)} data-score={score} key={release.id}>
      <td>
        <EntityLink entity={release} />
      </td>
      <td>
        <ArtistCreditLink artistCredit={release.artistCredit} />
      </td>
      <td>{release.combined_format_name}</td>
      <td>{release.combined_track_count}</td>
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
      <td>{formatBarcode(release.barcode)}</td>
      <td>
        {release.language ? (
          <abbr title={l_languages(release.language.name)}>
            {release.language.iso_code_3}
          </abbr>
        ) : null}
        {release.language && release.script ? ' / ' : null}
        {release.script ? (
          <abbr title={l_scripts(release.script.name)}>
            {release.script.iso_code}
          </abbr>
        ) : null}
      </td>
      <td>
        {release.releaseGroup && release.releaseGroup.typeName ? lp_attributes(release.releaseGroup.typeName, 'release_group_primary_type') : null}
      </td>
      <td>
        {release.status ? lp_attributes(release.status.name) : null}
      </td>
      <CatalystContext.Consumer>
        {($c: CatalystContextT) => (
          $c.session && $c.session.tport
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
        {$c && $c.session && $c.session.tport ? <th>{l('Tagger')}</th> : null}
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
        {l('Alternatively, you may {uri|add a new release}.', {
          uri: '/release/add',
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(ReleaseResults);
