/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import manifest from '../static/manifest.mjs';
import CollectionEditForm
  from '../static/scripts/collection/components/CollectionEditForm.js';

import CollectionLayout from './CollectionLayout.js';
import type {CollectionEditFormT} from './types.js';

component EditCollection(
  collection: CollectionT,
  collectionTypes: SelectOptionsT,
  form: CollectionEditFormT,
) {
  return (
    <CollectionLayout
      entity={collection}
      fullWidth
      page="edit"
      title={lp('Edit', 'verb, header')}
    >
      <CollectionEditForm collectionTypes={collectionTypes} form={form} />
      {manifest('collection/edit')}
    </CollectionLayout>
  );
}

export default EditCollection;
