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
import {l} from '../static/scripts/common/i18n';

import ReleaseGroupUrlList from './components/ReleaseGroupUrlList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseGroupUrlT} from './types';

const DiscogsLinksWithMultipleReleaseGroups = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupUrlT>) => (
  <Layout fullWidth title={l('Discogs URLs linked to multiple release groups')}>
    <h1>{l('Discogs URLs linked to multiple release groups')}</h1>

    <ul>
      <li>
        {l(`This report shows Discogs URLs which are linked
            to multiple release groups.`)}
      </li>
      <li>{l('Total release groups found: {count}', {count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseGroupUrlList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DiscogsLinksWithMultipleReleaseGroups);
