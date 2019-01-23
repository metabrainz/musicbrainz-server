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

import EditorList from './components/EditorList';
import type {ReportDataT, ReportEditorT} from './types';

const LimitedEditors = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEditorT>) => (
  <Layout fullWidth title={l('Beginner/limited editors')}>
    <h1>{l('Beginner/limited editors')}</h1>

    <ul>
      <li>
        {l('This report lists {url|beginner/limited editors}.',
          {url: '/doc/How_to_Create_an_Account'})}
      </li>
      <li>{l('Total editors found: {count}', {count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {date: formatUserDate($c.user, generated)})}</li>
    </ul>

    {$c.user && $c.user.is_account_admin ? (
      <EditorList items={items} pager={pager} />
    ) : (
      <p>{l('Sorry, you are not authorized to view this page.')}</p>
    )}

  </Layout>
);

export default withCatalystContext(LimitedEditors);
