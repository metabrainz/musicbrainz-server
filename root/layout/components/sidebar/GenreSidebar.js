/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../../context';

import LastUpdated from './LastUpdated';
import RemoveLink from './RemoveLink';

type Props = {|
  +$c: CatalystContextT,
  +genre: GenreT,
|};

const GenreSidebar = ({$c, genre}: Props) => {
  return (
    <div id="sidebar">
      {$c.user && $c.user.is_relationship_editor ? (
        <>
          <h2 className="editing">{l('Editing')}</h2>
          <ul className="links">
            <RemoveLink entity={genre} />
          </ul>
        </>
      ) : null}
      <LastUpdated entity={genre} />
    </div>
  );
};

export default withCatalystContext(GenreSidebar);
