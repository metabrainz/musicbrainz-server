/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import chooseLayoutComponent from '../utility/chooseLayoutComponent';
import {withCatalystContext} from '../context';
import {MainTagEditor} from '../static/scripts/common/components/TagEditor';


type Props = {|
  +$c: CatalystContextT,
  +allTags: $ReadOnlyArray<AggregatedTagT>,
  +entity: CoreEntityT,
  +lastUpdated: string,
  +moreTags: boolean,
  +userTags: $ReadOnlyArray<UserTagT>,
|};

const Tags = ({
  $c,
  allTags,
  entity,
  lastUpdated,
  moreTags,
  userTags,
}: Props) => {
  const entityType = entity.entityType;
  const LayoutComponent = chooseLayoutComponent(entityType);

  return (
    <LayoutComponent entity={entity} page="tags" title={l('Tags')}>
      <MainTagEditor
        $c={$c}
        aggregatedTags={allTags}
        entity={entity}
        more={moreTags}
        userTags={userTags}
      />
    </LayoutComponent>
  );
};

export default withCatalystContext(Tags);
