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

const ReleasesMissingDiscIds = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) => (
  <Layout fullWidth title={l('Releases missing disc IDs')}>
    <h1>{l('Releases missing disc IDs')}</h1>

    <ul>
      <li>
        {l(`This report shows releases (official and promotional only) that
            have at least one medium with a format that supports disc IDs,
            but is missing one.`)}
      </li>
      <li>
        {exp.l(`For instructions on how to add one, see the
            {add_discids|documentation page}.`,
        {add_discids: '/doc/How_to_Add_Disc_IDs'})}
      </li>
      <li>{texp.l('Total releases found: {count}', {count: pager.total_entries})}</li>
      <li>{texp.l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(ReleasesMissingDiscIds);
