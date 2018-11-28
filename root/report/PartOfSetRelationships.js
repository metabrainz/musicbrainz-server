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

import ReleaseList from './components/ReleaseList';
import FilterLink from './FilterLink';
import type {ReportDataT, ReportReleaseT} from './types';

const PartOfSetRelationships = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) => (
  <Layout fullWidth title={l('Releases with "part of set" relationships')}>
    <h1>{l('Releases with "part of set" relationships')}</h1>

    <ul>
      <li>{l('This report shows releases that still have the deprecated "part \
              of set" relationship and should probably be merged. For instructions \
              on how to fix them, please see the documentation about \
              {how_to_merge_releases|how to merge releases}. If the releases are \
              not really part of a set (for example, if they are \
              independently-released volumes in a series) just remove the relationship.',
              {__react: true, how_to_merge_releases: '/doc/How_to_Merge_Releases'})}
      </li>
      <li>{l('Total releases found: {count}', {__react: true, count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

      {canBeFiltered ? <FilterLink filtered={filtered} /> : null}
    </ul>

    <ReleaseList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(PartOfSetRelationships);
