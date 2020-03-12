/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../context';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import entityHref from '../../static/scripts/common/utility/entityHref';

import AliasTable from './AliasTable';

function canEdit($c: CatalystContextT, entityType: string) {
  if ($c.user && !$c.user.is_editing_disabled) {
    switch (entityType) {
      case 'area':
        return $c.user.is_location_editor;
      case 'instrument':
        return $c.user.is_relationship_editor;
      default:
        return true;
    }
  }
  return false;
}

type Props = {
  +$c: CatalystContextT,
  +aliases: ?$ReadOnlyArray<AliasT>,
  +entity: CoreEntityT,
};

const Aliases = ({$c, aliases, entity}: Props) => {
  const entityType = entity.entityType;
  const allowEditing = canEdit($c, entityType);
  return (
    <>
      <h2>{l('Aliases')}</h2>
      <p>
        {exp.l(
          `An alias is an alternate name for an entity. They typically
           contain common mispellings or variations of the name and are also 
           used to improve search results. View the {doc|alias documentation}
           for more details.`,
          {doc: '/doc/Aliases'},
        )}
      </p>
      {aliases?.length ? (
        <AliasTable
          aliases={aliases}
          allowEditing={allowEditing}
          entity={entity}
        />
      ) : (
        <p>
          {exp.l('{entity} has no aliases.',
                 {entity: <EntityLink entity={entity} key="entity" />})}
        </p>
      )}
      {allowEditing
        ? (
          <p>
            <a href={entityHref(entity, `/add-alias`)}>
              {l('Add a new alias')}
            </a>
          </p>
        )
        : null}
    </>
  );
};

export default withCatalystContext(Aliases);
