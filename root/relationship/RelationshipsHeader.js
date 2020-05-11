/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Tabs from '../components/Tabs';
import buildTab from '../utility/buildTab';

const RelationshipTabs = ({page}: {page?: string}) => (
  <>
    {buildTab(
      page,
      l('Relationship Types'),
      '/relationships',
      'relationships',
    )}
    {buildTab(
      page,
      l('Relationship Attributes'),
      '/relationship-attributes',
      'attributes',
    )}
  </>
);

const RelationshipsHeader = ({page}: {page?: string}) => (
  <>
    <div className="relationshipsheader">
      <h1>{l('Relationships')}</h1>
    </div>
    <Tabs>
      <RelationshipTabs page={page} />
    </Tabs>
  </>
);

export default RelationshipsHeader;
