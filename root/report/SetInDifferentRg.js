/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import ReleaseGroupList from './components/ReleaseGroupList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseGroupT} from './types';

const SetInDifferentRg = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) => (
  <Layout fullWidth title={l('Mismatched release groups')}>
    <h1>{l('Mismatched release groups')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report shows release groups with releases that are linked to
           releases in different release groups by part-of-set or
           transliteration relationships. If a pair of release groups are
           listed here, you should probably merge them. If the releases are
           discs linked with "part of set" relationships, you might want to
           merge them too into one multi-disc release
           (see {how_to_merge_releases|How to Merge Releases}).`,
          {how_to_merge_releases: '/doc/How_to_Merge_Releases'},
        )}
      </li>
      <li>
        {texp.l('Total release groups found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c.user, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseGroupList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(SetInDifferentRg);
