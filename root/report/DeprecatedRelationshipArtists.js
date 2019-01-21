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

import ArtistRelationshipList from './components/ArtistRelationshipList';
import FilterLink from './FilterLink';
import type {ReportArtistRelationshipT, ReportDataT} from './types';

const DeprecatedRelationshipArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistRelationshipT>) => (
  <Layout fullWidth gettext_domains={['relationships']} title={l('Artists with deprecated relationships')}>
    <h1>{l('Artists with deprecated relationships')}</h1>

    <ul>
      <li>
        {l('This report lists artists which have relationships using deprecated and grouping-only relationship types')}
      </li>
      <li>{l('Total artists found: {count}', {count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ArtistRelationshipList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DeprecatedRelationshipArtists);
