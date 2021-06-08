/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../static/manifest';
import CollectionEditForm
  from '../static/scripts/collection/components/CollectionEditForm';

import CollectionLayout from './CollectionLayout';
import type {CollectionEditFormT} from './types';

type Props = {
  +collection: CollectionT,
  +collectionTypes: SelectOptionsT,
  +form: CollectionEditFormT,
};

const EditCollection = ({
  collection,
  collectionTypes,
  form,
}: Props): React.Element<typeof CollectionLayout> => (
  <CollectionLayout
    entity={collection}
    fullWidth
    page="edit"
    title={l('Edit')}
  >
    <CollectionEditForm collectionTypes={collectionTypes} form={form} />
    {manifest.js('collection/edit')}
  </CollectionLayout>
);

export default EditCollection;
