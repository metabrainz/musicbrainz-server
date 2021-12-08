/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {commaOnlyListText} from '../i18n/commaOnlyList';
import localizeArtistRoles from '../i18n/localizeArtistRoles';

import CollapsibleList from './CollapsibleList';
import EntityLink from './EntityLink';

type RelationT = {
  +credit: string,
  +entity: ArtistT,
  +roles: $ReadOnlyArray<string>,
};

type ArtistRolesProps = {
  +relations: $ReadOnlyArray<RelationT>,
};

const buildArtistRoleRow = (relation: RelationT) => {
  return (
    <li key={relation.entity.id + '-' + relation.credit}>
      {exp.l('{artist} ({roles})', {
        artist: (
          <EntityLink
            content={relation.credit}
            entity={relation.entity}
          />
        ),
        roles: commaOnlyListText(localizeArtistRoles(relation.roles)),
      })}
    </li>
  );
};

const ArtistRoles = ({
  relations,
}: ArtistRolesProps): React.Element<typeof CollapsibleList> => (
  <CollapsibleList
    ariaLabel={l('Artist Roles')}
    buildRow={buildArtistRoleRow}
    className="artist-roles"
    rows={relations}
    showAllTitle={l('Show all artists')}
    showLessTitle={l('Show less artists')}
    toShowAfter={0}
    toShowBefore={4}
  />
);

export default (hydrate<ArtistRolesProps>(
  'div.artist-roles-container',
  ArtistRoles,
): React.AbstractComponent<ArtistRolesProps, void>);
