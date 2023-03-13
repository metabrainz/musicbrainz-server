/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../static/scripts/common/components/EntityLink.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import CollectionLayout from './CollectionLayout.js';

type Props = {
  +collection: CollectionT,
};

const DeleteCollection = ({
  collection,
}: Props): React$Element<typeof CollectionLayout> => (
  <CollectionLayout
    entity={collection}
    fullWidth
    page="delete"
    title={l('Remove')}
  >
    <h2>{l('Remove collection')}</h2>
    <p>
      {exp.l('Are you sure you want to remove the collection {collection}?',
             {collection: <EntityLink entity={collection} />})}
    </p>
    <form method="post">
      <FormSubmit label={l('Remove collection')} />
    </form>

  </CollectionLayout>
);

export default DeleteCollection;
