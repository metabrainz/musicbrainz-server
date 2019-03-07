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

const DiscogsLinksWithMultipleReleases = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>) => (
  <Layout fullWidth title={l('Discogs URLs linked to multiple releases')}>
    <h1>{l('Discogs URLs linked to multiple releases')}</h1>

    <ul>
      <li>
        {exp.l(`This report shows Discogs URLs which are linked to multiple
            releases. In most cases Discogs releases should map to MusicBrainz
            releases 1:1, so only one of the links will be correct. Just check
            which MusicBrainz release fits the release in Discogs (look at the
            format, tracklist, release country, etc.). You might also find
            some Discogs URLs linked to several discs of a multi-disc release:
            just merge those (see
            {how_to_merge_releases|How to Merge Releases}).`,
        {how_to_merge_releases: '/doc/How_to_Merge_Releases'})}
      </li>
      <li>{texp.l('Total releases found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseUrlList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DiscogsLinksWithMultipleReleases);
