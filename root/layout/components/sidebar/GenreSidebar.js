/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context';
import {isRelationshipEditor}
  from '../../../static/scripts/common/utility/privileges';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import RemoveLink from './RemoveLink';

type Props = {
  +genre: GenreT,
};

const GenreSidebar = ({genre}: Props): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);

  return (
    <div id="sidebar">
      <ExternalLinks empty entity={genre} />

      {isRelationshipEditor($c.user) ? (
        <EditLinks entity={genre}>
          <AnnotationLinks entity={genre} />

          <RemoveLink entity={genre} />
        </EditLinks>
      ) : null}
      <LastUpdated entity={genre} />
    </div>
  );
};

export default GenreSidebar;
