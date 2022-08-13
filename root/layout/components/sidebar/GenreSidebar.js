/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import {isRelationshipEditor}
  from '../../../static/scripts/common/utility/privileges.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import RemoveLink from './RemoveLink.js';

type Props = {
  +genre: GenreT,
};

const GenreSidebar = ({genre}: Props): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);

  return (
    <div id="sidebar">
      <ExternalLinks empty entity={genre} />

      <EditLinks entity={genre} requiresPrivileges>
        {isRelationshipEditor($c.user) ? (
          <>
            <AnnotationLinks entity={genre} />

            <RemoveLink entity={genre} />
          </>
        ) : null}
      </EditLinks>
      <LastUpdated entity={genre} />
    </div>
  );
};

export default GenreSidebar;
