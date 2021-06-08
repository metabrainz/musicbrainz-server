/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout';
import * as manifest from '../static/manifest';
import CollectionEditForm
  from '../static/scripts/collection/components/CollectionEditForm';

import type {CollectionEditFormT} from './types';

type Props = {
  +collectionTypes: SelectOptionsT,
  +form: CollectionEditFormT,
};

const CreateCollection = ({
  collectionTypes,
  form,
}: Props): React.Element<typeof Layout> => (
  <Layout
    fullWidth
    title={l('Create a new collection')}
  >
    <div id="content">
      <h1>{l('Create a new collection')}</h1>
      <CollectionEditForm collectionTypes={collectionTypes} form={form} />
      {manifest.js('collection/edit')}
    </div>
  </Layout>
);

export default CreateCollection;
