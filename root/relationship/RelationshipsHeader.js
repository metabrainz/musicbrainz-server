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

component RelationshipTabs(page?: string) {
  return (
    <>
      {buildTab(
        page,
        l('Relationship types'),
        '/relationships',
        'relationships',
      )}
      {buildTab(
        page,
        l('Relationship attributes'),
        '/relationship-attributes',
        'attributes',
      )}
    </>
  );
}

component RelationshipsHeader(page?: string) {
  return (
    <>
      <div className="relationshipsheader">
        <h1>{l('Relationships')}</h1>
      </div>
      <Tabs>
        <RelationshipTabs page={page} />
      </Tabs>
    </>
  );
}

export default RelationshipsHeader;
