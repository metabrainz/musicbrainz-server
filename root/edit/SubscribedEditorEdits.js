/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';

import EditList from './components/EditList';

type Props = {
  +$c: CatalystContextT,
  +editCountLimit: number,
  +edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  +pager: PagerT,
  +refineUrlArgs?: {+[argument: string]: string},
};

const SubscribedEditorEdits = ({
  $c,
  editCountLimit,
  edits,
  pager,
  refineUrlArgs,
}: Props): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Edits by Your Subscribed Editors')}>
    <div id="content">
      <h1>{l('Edits by Your Subscribed Editors')}</h1>
      <EditList
        $c={$c}
        editCountLimit={editCountLimit}
        edits={edits}
        guessSearch
        page="subscribed_editors"
        pager={pager}
        refineUrlArgs={refineUrlArgs}
      />
    </div>
  </Layout>
);

export default SubscribedEditorEdits;
