/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import CDStubLink
  from '../../../static/scripts/common/components/CDStubLink.js';
import escapeLuceneValue
  from '../../../static/scripts/common/utility/escapeLuceneValue.js';
import {
  getCDStubAddedAgeAgo,
  getCDStubModifiedAgeAgo,
} from '../../../utility/getCDStubAge.js';

import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';

type Props = {
  +cdstub: CDStubT,
};

const CDStubSidebar = ({cdstub}: Props): React$Element<'div'> => {
  const artistField =
    escapeLuceneValue(cdstub.artist || l('Various Artists'));
  const releaseField = escapeLuceneValue(cdstub.title);
  const tracksMediumField = escapeLuceneValue(cdstub.track_count);
  const barcodeField = cdstub.barcode
    ? escapeLuceneValue(cdstub.barcode)
    : null;

  const searchQuery = (
    `artist:(${artistField}) ` +
    `release:(${releaseField}) ` +
    `tracksmedium:(${tracksMediumField})` +
    (nonEmpty(barcodeField) ? ` barcode:(${barcodeField})` : '')
  );

  const toc = cdstub.toc;

  return (
    <div id="sidebar">
      <SidebarProperties>
        <SidebarProperty className="" label={l('Added:')}>
          {getCDStubAddedAgeAgo(cdstub)}
        </SidebarProperty>

        <SidebarProperty className="" label={l('Last modified:')}>
          {getCDStubModifiedAgeAgo(cdstub)}
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
        {nonEmpty(toc) ? (
          <li>
            <a href={'/cdtoc/attach?toc=' + encodeURIComponent(toc)}>
              {l('Add disc ID to an existing release')}
            </a>
          </li>
        ) : null}
        <li>
          <a
            href={'/search?advanced=1&type=release&query=' +
              encodeURIComponent(searchQuery)}
          >
            {l('Search the database for this CD')}
          </a>
        </li>
      </ul>
    </div>
  );
};

export default CDStubSidebar;
