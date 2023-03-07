/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import EntityLink from '../../static/scripts/common/components/EntityLink.js';
import entityHref from '../../static/scripts/common/utility/entityHref.js';
import {
  isEditingEnabled,
  isLocationEditor,
  isRelationshipEditor,
} from '../../static/scripts/common/utility/privileges.js';

import AliasTable from './AliasTable.js';

function canEdit($c: CatalystContextT, entityType: string) {
  if (isEditingEnabled($c.user)) {
    switch (entityType) {
      case 'area':
        return isLocationEditor($c.user);
      case 'genre':
      case 'instrument':
        return isRelationshipEditor($c.user);
      default:
        return true;
    }
  }
  return false;
}

type Props = {
  +aliases: ?$ReadOnlyArray<AnyAiasT>,
  +entity: CoreEntityT,
};

const Aliases = ({aliases, entity}: Props): React.MixedElement => {
  const $c = React.useContext(CatalystContext);
  const entityType = entity.entityType;
  const allowEditing = canEdit($c, entityType);
  return (
    <>
      <h2>{l('Aliases')}</h2>
      <p>
        {exp.l(
          `An alias is an alternate name for an entity. They typically
           contain common misspellings or variations of the name and are also
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

export default Aliases;
