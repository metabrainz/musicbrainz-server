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

import ReleaseGroupList from './components/ReleaseGroupList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseGroupT} from './types';

const DuplicateRelationshipsReleaseGroups = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) => (
  <Layout fullWidth title={l('Release groups with possible duplicate relationships')}>
    <h1>{l('Release groups with possible duplicate relationships')}</h1>

    <ul>
      <li>{l('This report lists release groups which have multiple relationships to the same entity using the same relationship type.')}</li>
      <li>{l('Total release groups found: {count}', {__react: true, count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseGroupList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(DuplicateRelationshipsReleaseGroups);
