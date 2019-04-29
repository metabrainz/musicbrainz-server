/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import CollectionEditForm from './CollectionEditForm';
import CollectionLayout from './CollectionLayout';
import type {CollectionFormT} from './types';

type Props = {|
  +collection: CollectionT,
  +collectionTypes: SelectOptionsT,
  +form: CollectionFormT,
|};

const CollectionEdit = ({collection, collectionTypes, form}: Props) => (
  <CollectionLayout
    entity={collection}
    fullWidth
    page="edit"
    title={l('Edit Collection')}
  >
    <CollectionEditForm collectionTypes={collectionTypes} form={form} />
  </CollectionLayout>
);

export default CollectionEdit;
