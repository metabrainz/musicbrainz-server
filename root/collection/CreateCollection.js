/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Layout from '../layout/index.js';
import * as manifest from '../static/manifest.mjs';
import CollectionEditForm
  from '../static/scripts/collection/components/CollectionEditForm.js';

import type {CollectionEditFormT} from './types.js';

component CreateCollection(
  collectionTypes: SelectOptionsT,
  form: CollectionEditFormT,
) {
  return (
    <Layout
      fullWidth
      title={lp('Add a new collection', 'header')}
    >
      <div id="content">
        <h1>{lp('Add a new collection', 'header')}</h1>
        <CollectionEditForm collectionTypes={collectionTypes} form={form} />
        {manifest.js('collection/edit')}
      </div>
    </Layout>
  );
}

export default CreateCollection;
