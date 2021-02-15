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
import {isAccountAdmin} from '../static/scripts/common/utility/privileges';
import formatUserDate from '../utility/formatUserDate';

import EditorList from './components/EditorList';
import type {ReportDataT, ReportEditorT} from './types';

const LimitedEditors = ({
  $c,
  generated,
  items,
  pager,
}: ReportDataT<ReportEditorT>): React.Element<typeof Layout> => (
  <Layout $c={$c} fullWidth title={l('Beginner/limited editors')}>
    <h1>{l('Beginner/limited editors')}</h1>

    <ul>
      <li>
        {exp.l('This report lists {url|beginner/limited editors}.',
               {url: '/doc/How_to_Create_an_Account'})}
      </li>
      <li>
        {texp.l('Total editors found: {count}',
                {count: pager.total_entries})}
      </li>
      <li>
        {texp.l('Generated on {date}',
                {date: formatUserDate($c, generated)})}
      </li>
    </ul>

    {isAccountAdmin($c.user) ? (
      <EditorList items={items} pager={pager} />
    ) : (
      <p>{l('Sorry, you are not authorized to view this page.')}</p>
    )}

  </Layout>
);

export default LimitedEditors;
