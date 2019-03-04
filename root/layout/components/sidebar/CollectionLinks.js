/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import EntityLink from '../../../static/scripts/common/components/EntityLink';

import CollectionList from './CollectionList';

type Props = {|
  +$c: CatalystContextT,
  +entity: CoreEntityT,
|};

const CollectionLinks = ({$c, entity}: Props) => (
  ($c.user_exists && $c.stash.all_collections) ? (
    <>
      <h2 className="collections">
        {l('Collections')}
      </h2>
      <CollectionList
        addText={l('Add to a new collection')}
        entity={entity}
        noneText={l('You have no collections!')}
        usersLink={
          <EntityLink
            content={texp.ln(
              'Found in {num} user collection',
              'Found in {num} user collections',
              // $FlowFixMe
              $c.stash.all_collections.length,
              // $FlowFixMe
              {num: $c.stash.all_collections.length},
            )}
            entity={entity}
            subPath="collections"
          />
        }
      />
    </>
  ) : null
);

export default withCatalystContext(CollectionLinks);
