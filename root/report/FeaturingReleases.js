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

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const FeaturingReleases = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) => (
  <Layout fullWidth title={l('Releases with titles containing featuring artists')}>
    <h1>{l('Releases with titles containing featuring artists')}</h1>

    <ul>
      <li>
        {exp.l(`This report shows releases with (feat. Artist) in the title. For
            classical releases, consult the {CSG|classical style guidelines}.
            For non-classical releases, this is inherited from an older
            version of MusicBrainz and should be fixed. Consult the
            {featured_artists|page about featured artists} to know more.`,
        {
          CSG: '/doc/Style/Classical',
          featured_artists: '/doc/Style/Artist_Credits#Featured_artists',
        })}
      </li>
      <li>{texp.l('Total releases found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(FeaturingReleases);
