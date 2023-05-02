/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink.js';

import typeof EntityTabLink from './EntityTabLink.js';
import EntityTabs from './EntityTabs.js';
import SubHeader from './SubHeader.js';

type Props = {
  +editTab?: React$Element<EntityTabLink>,
  +entity: RelatableEntityT,
  +headerClass: string,
  +heading?: Expand2ReactOutput,
  +page?: string,
  +preHeader?: Expand2ReactOutput,
  +subHeading: Expand2ReactOutput,
};

const EntityHeader = ({
  editTab,
  entity,
  headerClass,
  heading,
  page,
  preHeader,
  subHeading,
}: Props): React$Element<typeof React.Fragment> => (
  <>
    <div className={'wrap-anywhere ' + headerClass}>
      {nonEmpty(preHeader) ? preHeader : null}
      <h1>
        {nonEmpty(heading) ? heading : <EntityLink entity={entity} />}
      </h1>
      <SubHeader subHeading={subHeading} />
    </div>
    <EntityTabs
      editTab={editTab}
      entity={entity}
      page={page}
    />
  </>
);

export default EntityHeader;
