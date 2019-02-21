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

import ReleaseUrlList from './components/ReleaseUrlList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseUrlT} from './types';

const AsinsWithMultipleReleases = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>) => (
  <Layout fullWidth title={l('Amazon URLs linked to multiple releases')}>
    <h1>{l('Amazon URLs linked to multiple releases')}</h1>

    <ul>
      <li>
        {exp.l(`This report shows Amazon URLs which are linked to multiple
            releases. In most cases Amazon ASINs should map to MusicBrainz
            releases 1:1, so only one of the links will be correct. Just
            check which MusicBrainz release fits the release in Amazon (look
            at the format, tracklist, etc). If the release has a barcode,
            you can also search Amazon for it and see which ASIN matches.
            You might also find some ASINs linked to several discs
            of a multi-disc release: just merge those (see
            {how_to_merge_releases|How to Merge Releases}).`,
               {how_to_merge_releases: '/doc/How_to_Merge_Releases'})}
      </li>
      <li>
        {texp.l('Total releases found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c.user, generated)})}
      </li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseUrlList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(AsinsWithMultipleReleases);
