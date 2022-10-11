/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import EntityLink
  from '../../../static/scripts/common/components/EntityLink.js';

import CollectionList from './CollectionList.js';

type Props = {
  +entity: CollectableCoreEntityT,
};

const noCollectionsStrings = {
  area: N_l('You have no area collections!'),
  artist: N_l('You have no artist collections!'),
  event: N_l('You have no event collections!'),
  instrument: N_l('You have no instrument collections!'),
  label: N_l('You have no label collections!'),
  place: N_l('You have no place collections!'),
  recording: N_l('You have no recording collections!'),
  release: N_l('You have no release collections!'),
  release_group: N_l('You have no release group collections!'),
  series: N_l('You have no series collections!'),
  work: N_l('You have no work collections!'),
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
      ownCollectionsNoneText={noCollectionsStrings[entity.entityType]()}
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
