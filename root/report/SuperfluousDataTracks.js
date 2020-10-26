/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const SuperfluousDataTracks = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof Layout> => (
  <Layout
    $c={$c}
    fullWidth
    title={l('Releases with superfluous data tracks')}
  >
    <h1>{l('Releases with superfluous data tracks')}</h1>

    <ul>
      <li>
        {exp.l(
          `This report lists releases without any disc IDs that probably
           contain data tracks (like videos) at the end of a medium, but have
           no tracks marked as data tracks. A data track should be marked as
           such if it is the last track of the CD and contains audio or video.
           Otherwise, it should just be removed. See the
           {data_track_guidelines|data track guidelines}.`,
          {
            data_track_guidelines:
              '/doc/Style/Unknown_and_untitled/' +
              'Special_purpose_track_title#Data_tracks',
          },
        )}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>

      {canBeFiltered ? <FilterLink $c={$c} filtered={filtered} /> : null}
    </ul>

    <ReleaseList items={items} pager={pager} />

  </Layout>
);

export default SuperfluousDataTracks;
