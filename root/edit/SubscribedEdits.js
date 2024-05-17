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

component SubscribedEdits(
  editCountLimit: number,
  edits: $ReadOnlyArray<$ReadOnly<{...EditT, +id: number}>>,
  pager: PagerT,
  refineUrlArgs?: {+[argument: string]: string},
) {
  return (
    <Layout fullWidth title={l('Edits for your subscribed entities')}>
      <div id="content">
        <h1>{l('Edits for your subscribed entities')}</h1>

        <p>
          {l(`This page lists edits linked to entities you are directly
              subscribed to, as well as edits linked to entities which are
              part of a collection you are subscribed to.`)}
        </p>

        <EditList
          editCountLimit={editCountLimit}
          edits={edits}
          guessSearch
          page="subscribed"
          pager={pager}
          refineUrlArgs={refineUrlArgs}
        />
      </div>
    </Layout>
  );
}

export default SubscribedEdits;
