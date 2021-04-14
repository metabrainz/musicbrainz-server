/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context';
import EntityLink from '../../../static/scripts/common/components/EntityLink';

import CollectionList from './CollectionList';

type Props = {
  +entity: CoreEntityT,
};

const CollectionLinks = ({
  entity,
}: Props): React.Element<typeof CollectionList> | null => {
  const $c = React.useContext(CatalystContext);
  const numberOfCollections = $c.stash.number_of_collections || 0;
  if (!$c.user) {
    return null;
  }
  return (
    <CollectionList
      addCollectionText={l('Add to a new collection')}
      collaborativeCollections={$c.stash.collaborative_collections}
      collaborativeCollectionsHeader={l('Collaborative collections')}
      entity={entity}
      header={l('Collections')}
      ownCollections={$c.stash.own_collections}
      ownCollectionsHeader={l('My collections')}
      ownCollectionsNoneText={l('You have no collections!')}
      sectionClass="collections"
      usersLink={
        <EntityLink
          content={texp.ln(
            'Found in {num} user collection',
            'Found in {num} user collections',
            numberOfCollections,
            {num: numberOfCollections},
          )}
          entity={entity}
          subPath="collections"
        />
      }
      usersLinkHeader={l('Other collections')}
    />
  );
};

export default CollectionLinks;
