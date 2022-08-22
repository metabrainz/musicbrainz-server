/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';

import EditList from './components/EditList.js';

type Props = {
  +editCountLimit: number,
  +edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  +pager: PagerT,
  +refineUrlArgs: {+[argument: string]: string},
};

const OpenEdits = ({
  editCountLimit,
  edits,
  pager,
  refineUrlArgs,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Open Edits')}>
    <div id="content">
      <h1>{l('Open Edits')}</h1>
      <EditList
        editCountLimit={editCountLimit}
        edits={edits}
        guessSearch
        page="open"
        pager={pager}
        refineUrlArgs={refineUrlArgs}
      />
    </div>
  </Layout>
);

export default OpenEdits;
