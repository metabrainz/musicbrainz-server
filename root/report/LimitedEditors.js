/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../context.mjs';
import {isAccountAdmin} from '../static/scripts/common/utility/privileges.js';

import EditorList from './components/EditorList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportEditorT} from './types.js';

const LimitedEditors = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportEditorT>): React$Element<typeof ReportLayout> => {
  const $c = React.useContext(CatalystContext);
  return (
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
};

export default LimitedEditors;
