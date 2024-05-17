/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';

import EditList from './components/EditList.js';

component SubscribedEditorEdits(
  editCountLimit: number,
  edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  pager: PagerT,
  refineUrlArgs?: {+[argument: string]: string},
) {
  return (
    <Layout fullWidth title={l('Edits by your subscribed editors')}>
      <div id="content">
        <h1>{l('Edits by your subscribed editors')}</h1>
        <EditList
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
}

export default SubscribedEditorEdits;
