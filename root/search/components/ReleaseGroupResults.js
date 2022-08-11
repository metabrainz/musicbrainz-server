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
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import ArtistCreditLink
  from '../../static/scripts/common/components/ArtistCreditLink.js';
import {isEditingEnabled}
  from '../../static/scripts/common/utility/privileges.js';
import loopParity from '../../utility/loopParity.js';
import type {ResultsPropsT, SearchResultT} from '../types.js';

import PaginatedSearchResults from './PaginatedSearchResults.js';
import ResultsLayout from './ResultsLayout.js';

function buildResult(result: SearchResultT<ReleaseGroupT>, index: number) {
  const releaseGroup = result.entity;
  const score = result.score;

  return (
    <tr
      className={loopParity(index)}
      data-score={score}
      key={releaseGroup.id}
    >
      <td>
        <EntityLink entity={releaseGroup} showCaaPresence />
      </td>
      <td>
        <ArtistCreditLink artistCredit={releaseGroup.artistCredit} />
      </td>
      <td>
        {nonEmpty(releaseGroup.typeName)
          ? lp_attributes(releaseGroup.typeName, 'release_group_primary_type')
          : null}
      </td>
    </tr>
  );
}

const ReleaseGroupResults = ({
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<ReleaseGroupT>):
React.Element<typeof ResultsLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
    <ResultsLayout form={form} lastUpdated={lastUpdated}>
      <PaginatedSearchResults
        buildResult={buildResult}
        columns={
          <>
            <th>{l('Release Group')}</th>
            <th>{l('Artist')}</th>
            <th>{l('Type')}</th>
          </>
        }
        pager={pager}
        query={query}
        results={results}
      />
      {isEditingEnabled($c.user) ? (
        <p>
          {exp.l('Alternatively, you may {uri|add a new release group}.', {
            uri: '/release-group/create?edit-release-group.name=' +
              encodeURIComponent(query),
          })}
        </p>
      ) : null}
    </ResultsLayout>
  );
};

export default ReleaseGroupResults;
