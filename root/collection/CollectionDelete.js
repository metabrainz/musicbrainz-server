/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../context';
import FormSubmit from '../components/FormSubmit';
import EntityLink from '../static/scripts/common/components/EntityLink';

import CollectionLayout from './CollectionLayout';

type Props = {|
  +$c: CatalystContextT,
  +collection: CollectionT,
|};

const CollectionDelete = ({$c, collection}: Props) => (
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
    <form action={$c.req.uri} method="post">
      <FormSubmit label={l('Remove collection')} />
    </form>

  </CollectionLayout>
);

export default withCatalystContext(CollectionDelete);
