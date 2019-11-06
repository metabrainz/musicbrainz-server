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

const DuplicateReleaseGroups = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) => (
  <Layout fullWidth title={l('Possible duplicate release groups')}>
    <h1>{l('Possible duplicate release groups')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report lists release groups with very similar names and
           artists. If the releases in the release groups should be grouped
           together (see the {url|guidelines}), they can be merged. If they
           shouldn\'t be grouped together but they can be distinguished by
           the release group types, e.g. when an artist has an album and
           single with the same name, then there is usually no need to
           change anything. In other cases, a disambiguation comment may be
           helpful.`,
          {url: '/doc/Style/Release_Group'},
        )}
      </li>
      <li>
        {texp.l('Total release groups found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseGroupList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DuplicateReleaseGroups);
