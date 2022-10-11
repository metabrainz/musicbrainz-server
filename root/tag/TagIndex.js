/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import TagEntitiesList from '../components/TagEntitiesList.js';
import EntityLink
  from '../static/scripts/common/components/EntityLink.js';

import TagLayout from './TagLayout.js';

type Props = {
  +tag: TagT,
  +taggedEntities: {
    +[entityType: string]: {
      +count: number,
      +tags: $ReadOnlyArray<{
        +count: number,
        +entity: CoreEntityT,
        +entity_id: number,
      }>,
    },
  },
};

const TagIndex = (props: Props): React.Element<typeof TagLayout> => {
  const genre = props.tag.genre;
  return (
    <TagLayout page="" tag={props.tag}>
      {genre ? (
        <>
          <h2>{l('Genre')}</h2>
          <p>
            {exp.l('This tag is associated with the genre {genre}.',
                   {genre: <EntityLink entity={genre} />})}
          </p>
        </>
      ) : null}
      <TagEntitiesList {...props} />
    </TagLayout>
  );
};

export default TagIndex;
