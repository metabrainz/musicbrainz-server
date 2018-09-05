/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../context';
import {l} from '../../static/scripts/common/i18n';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import ArtistCreditLink from '../../static/scripts/common/components/ArtistCreditLink';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const releaseGroup = result.entity;
  const score = result.score;

  return (
    <tr
      className={loopParity(index)}
      data-score={score}
      key={releaseGroup.id}
    >
      <td>
        <EntityLink entity={releaseGroup} />
      </td>
      <td>
        <ArtistCreditLink artistCredit={releaseGroup.artistCredit} />
      </td>
      <td>
        {releaseGroup.typeName
          ? lp_attributes(releaseGroup.typeName, 'release_group_primary_type')
          : null}
      </td>
    </tr>
  );
}

const ReleaseGroupResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<ReleaseGroupT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={[
        l('Release Group'),
        l('Artist'),
        l('Type'),
      ]}
      pager={pager}
      query={query}
      results={results}
    />
    {$c.user && !$c.user.is_editing_disabled ? (
      <p>
        {l('Alternatively, you may {uri|add a new release group}.', {
          __react: true,
          uri: '/release-group/create?edit-release-group.name=' + encodeURIComponent(query),
        })}
      </p>
    ) : null}
  </ResultsLayout>
);

export default withCatalystContext(ReleaseGroupResults);
