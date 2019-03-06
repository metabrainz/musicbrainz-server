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

import RecordingList from './components/RecordingList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportRecordingT} from './types';

const FeaturingRecordings = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>) => (
  <Layout fullWidth title={l('Recordings with titles containing featuring artists')}>
    <h1>{l('Recordings with titles containing featuring artists')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report shows recordings with (feat. Artist) in the
           title. For classical recordings, consult the
           {CSG|classical style guidelines}. For non-classical recordings,
           this is inherited from an older version of MusicBrainz
           and should be fixed (both on the recordings and on the tracks!).
           Consult the {featured_artists|page about featured artists}
           to know more.`,
          {
            CSG: '/doc/Style/Classical',
            featured_artists: '/doc/Style/Artist_Credits#Featured_artists',
          },
        )}
      </li>
      <li>{texp.l('Total recordings found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <RecordingList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(FeaturingRecordings);
