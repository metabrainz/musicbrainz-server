/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Layout from '../layout';

import CollectionEditForm from './CollectionEditForm';
import type {CollectionFormT} from './types';

type Props = {|
  +collectionTypes: SelectOptionsT,
  +form: CollectionFormT,
|};

const CollectionCreate = ({collectionTypes, form}: Props) => (
  <Layout
    fullWidth
    title={l('Create a new collection')}
  >
    <div id="content">
      <h1>{l('Create a new collection')}</h1>
      <CollectionEditForm collectionTypes={collectionTypes} form={form} />
    </div>
  </Layout>
);

export default CollectionCreate;
