/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import chooseLayoutComponent from '../utility/chooseLayoutComponent.js';
import {MainTagEditor}
  from '../static/scripts/common/components/TagEditor.js';

type Props = {
  +$c: CatalystContextT,
  +allTags: $ReadOnlyArray<AggregatedTagT>,
  +entity: CoreEntityT,
  +moreTags: boolean,
  +userTags: $ReadOnlyArray<UserTagT>,
};

const Tags = ({
  $c,
  allTags,
  entity,
  moreTags,
  userTags,
}: Props): React.MixedElement => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent entity={entity} page="tags" title={l('Tags')}>
      <MainTagEditor
        $c={$c}
        aggregatedTags={allTags}
        entity={entity}
        genreMap={$c.stash.genre_map}
        more={moreTags}
        userTags={userTags}
      />
    </LayoutComponent>
  );
};

export default Tags;
