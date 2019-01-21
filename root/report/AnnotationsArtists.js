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

import ArtistAnnotationList from './components/ArtistAnnotationList';
import FilterLink from './FilterLink';
import type {ReportArtistAnnotationT, ReportDataT} from './types';

const AnnotationsArtists = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistAnnotationT>) => (
  <Layout fullWidth title={l('Artist annotations')}>
    <h1>{l('Artist annotations')}</h1>

    <ul>
      <li>
        {l('This report lists artists with annotations.')}
      </li>
      <li>{l('Total artists found: {count}', {count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ArtistAnnotationList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(AnnotationsArtists);
