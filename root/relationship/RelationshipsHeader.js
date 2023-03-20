/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Tabs from '../components/Tabs.js';
import buildTab from '../utility/buildTab.js';

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

type Props = {
  +page?: string,
};

const RelationshipsHeader = ({page}: Props): React$MixedElement => (
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
