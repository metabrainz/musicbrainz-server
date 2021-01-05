/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {isAccountAdmin} from '../static/scripts/common/utility/privileges';

import EditorList from './components/EditorList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportEditorT} from './types';

const LimitedEditors = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEditorT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      'This report lists {url|beginner/limited editors}.',
      {url: '/doc/How_to_Create_an_Account'},
    )}
    entityType="editor"
    filtered={filtered}
    generated={generated}
    title={l('Beginner/limited editors')}
    totalEntries={pager.total_entries}
  >
    {isAccountAdmin($c.user) ? (
      <EditorList items={items} pager={pager} />
    ) : (
      <p>{l('Sorry, you are not authorized to view this page.')}</p>
    )}
  </ReportLayout>
);

export default LimitedEditors;
