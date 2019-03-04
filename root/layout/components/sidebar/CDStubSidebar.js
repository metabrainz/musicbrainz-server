/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDStubLink from '../../../static/scripts/common/components/CDStubLink';
import escapeLuceneValue from '../../../static/scripts/common/utility/escapeLuceneValue';
import parseDate from '../../../static/scripts/common/utility/parseDate';
import {age, displayAgeAgo} from '../../../utility/age';

import {SidebarProperties, SidebarProperty} from './SidebarProperties';

type Props = {|
  +cdstub: CDStubT,
|};

const CDStubSidebar = ({cdstub}: Props) => {
  const now = parseDate((new Date()).toISOString().slice(0, 10));

  const addedAge = cdstub.date_added ? age({
    begin_date: parseDate(cdstub.date_added.slice(0, 10)),
    end_date: now,
    ended: true,
  }) : null;

  const lastModifiedAge = cdstub.last_modified ? age({
    begin_date: parseDate(cdstub.last_modified.slice(0, 10)),
    end_date: now,
    ended: true,
  }) : null;

  const searchQuery = (
    'artist:(' + escapeLuceneValue(cdstub.artist || l('Various Artists')) + ') ' +
    'release:(' + escapeLuceneValue(cdstub.title) + ') ' +
    'tracksmedium:(' + escapeLuceneValue(cdstub.track_count) + ')' +
    (cdstub.barcode ? ' barcode:(' + escapeLuceneValue(cdstub.barcode) + ')' : '')
  );

  return (
    <div id="sidebar">
      <SidebarProperties>
        <SidebarProperty className="" label={l('Added:')}>
          {addedAge ? displayAgeAgo(addedAge) : null}
        </SidebarProperty>

        <SidebarProperty className="" label={l('Last modified:')}>
          {lastModifiedAge ? displayAgeAgo(lastModifiedAge) : null}
        </SidebarProperty>

        <SidebarProperty className="" label={l('Lookup count:')}>
          {cdstub.lookup_count}
        </SidebarProperty>

        <SidebarProperty className="" label={l('Modify count:')}>
          {cdstub.modify_count}
        </SidebarProperty>

        {cdstub.barcode ? (
          <SidebarProperty className="" label={l('Barcode:')}>
            {cdstub.barcode}
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <ul className="links">
        <li>
          <CDStubLink
            cdstub={cdstub}
            content={l('Import as MusicBrainz release')}
            subPath="import"
          />
        </li>
        {cdstub.toc ? (
          <li>
            {/* $FlowFixMe */}
            <a href={'/cdtoc/attach?toc=' + encodeURIComponent(cdstub.toc)}>
              {l('Add disc ID to an existing release')}
            </a>
          </li>
        ) : null}
        <li>
          <a href={'/search?advanced=1&type=release&query=' + encodeURIComponent(searchQuery)}>
            {l('Search the database for this CD')}
          </a>
        </li>
      </ul>
    </div>
  );
};

export default CDStubSidebar;
