/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import uniq from 'lodash/uniq';

import {l} from '../i18n';
import commaOnlyList from '../i18n/commaOnlyList';

import EntityLink from './EntityLink';

type Props = {|
  +relations: $ReadOnlyArray<{|
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  |}>,
|};

const ArtistRoles = ({relations}: Props) => (
  <ul>
    {relations.map(r =>(
      <li key={r.entity.id}>
        {l('{artist} ({roles})', {
          artist: <EntityLink entity={r.entity} />,
          roles: r.roles.length > 1
            // $FlowFixMe
            ? commaOnlyList(uniq(r.roles))
            : r.roles[0],
        })}
      </li>
    ))}
  </ul>
);

export default ArtistRoles;
