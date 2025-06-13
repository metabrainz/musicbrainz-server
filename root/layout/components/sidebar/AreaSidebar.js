/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context.mjs';
import manifest from '../../../static/manifest.mjs';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage.js';
import {
  WIKIMEDIA_COMMONS_IMAGES_ENABLED,
} from '../../../static/scripts/common/DBDefs.mjs';
import {isLocationEditor}
  from '../../../static/scripts/common/utility/privileges.js';
import * as age from '../../../utility/age.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import RemoveLink from './RemoveLink.js';
import SidebarBeginDate from './SidebarBeginDate.js';
import SidebarEndDate from './SidebarEndDate.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';

component AreaSidebar(area: AreaT) {
  const $c = React.useContext(CatalystContext);
  const areaAge = age.age(area);

  return (
    <div id="sidebar">
      {WIKIMEDIA_COMMONS_IMAGES_ENABLED ? (
        <>
          <CommonsImage
            cachedImage={$c.stash.commons_image}
            entity={area}
          />
          {manifest('common/components/CommonsImage', {async: true})}
        </>
      ) : null}

      <h2 className="area-information">
        {l('Area information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={area} typeType="area_type" />

        <SidebarBeginDate
          age={areaAge}
          entity={area}
          label={addColonText(l('Begin date'))}
        />

        <SidebarEndDate
          age={areaAge}
          entity={area}
          label={addColonText(l('End date'))}
        />

        {area.iso_3166_1_codes.map(code => (
          <SidebarProperty
            className="iso-3166-1"
            key={'iso-3166-1-' + code}
            label={addColonText(l('ISO 3166-1'))}
          >
            {code}
          </SidebarProperty>
        ))}

        {area.iso_3166_2_codes.map(code => (
          <SidebarProperty
            className="iso-3166-2"
            key={'iso-3166-2-' + code}
            label={addColonText(l('ISO 3166-2'))}
          >
            {code}
          </SidebarProperty>
        ))}

        {area.iso_3166_3_codes.map(code => (
          <SidebarProperty
            className="iso-3166-3"
            key={'iso-3166-3-' + code}
            label={addColonText(l('ISO 3166-3'))}
          >
            {code}
          </SidebarProperty>
        ))}
      </SidebarProperties>

      <SidebarTags entity={area} />

      <ExternalLinks empty entity={area} />

      <EditLinks entity={area} requiresPrivileges>
        {isLocationEditor($c.user) ? (
          <>
            <AnnotationLinks entity={area} />

            <MergeLink entity={area} />

            <RemoveLink entity={area} />

            <li className="separator" role="separator" />
          </>
        ) : null}
      </EditLinks>

      <CollectionLinks entity={area} />

      <SidebarLicenses entity={area} />

      <LastUpdated entity={area} />
    </div>
  );
}

export default AreaSidebar;
