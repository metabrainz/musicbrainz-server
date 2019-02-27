/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import EntityLink from '../static/scripts/common/components/EntityLink';

import EntityTabs from './EntityTabs';
import SubHeader from './SubHeader';

type Props = {|
  +editTab?: React.Node,
  +entity: CoreEntityT,
  +headerClass: string,
  +heading?: React.Node,
  +page: string,
  +preHeader?: React.Node,
  +subHeading: React.Node,
|};

const EntityHeader = ({
  editTab,
  entity,
  headerClass,
  heading,
  page,
  preHeader,
  subHeading,
}: Props) => (
  <>
    <div className={headerClass}>
      {preHeader || null}
      <h1>
        {heading || <EntityLink entity={entity} />}
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
