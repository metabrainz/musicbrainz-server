/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {withCatalystContext} from '../../../context';
import CommonsImage from '../../../static/scripts/common/components/CommonsImage';
import {l} from '../../../static/scripts/common/i18n';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import * as age from '../../../utility/age';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarBeginDate from './SidebarBeginDate';
import SidebarEndDate from './SidebarEndDate';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {|
  +$c: CatalystContextT,
  +area: AreaT,
|};

const AreaSidebar = ({$c, area}: Props) => {
  const areaAge = age.age(area);

  return (
    <div id="sidebar">
      <CommonsImage
        entity={area}
        image={$c.stash.commons_image}
      />

      <h2 className="area-information">
        {l('Area information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={area} typeType="area_type" />

        <SidebarBeginDate age={areaAge} entity={area} label={l('Begin date:')} />

        <SidebarEndDate age={areaAge} entity={area} label={l('End date:')} />

        {area.iso_3166_1_codes.map(code => (
          <SidebarProperty
            className="iso-3166-1"
            key={'iso-3166-1-' + code}
            label={l('ISO 3166-1:')}
          >
            {code}
          </SidebarProperty>
        ))}

        {area.iso_3166_2_codes.map(code => (
          <SidebarProperty
            className="iso-3166-2"
            key={'iso-3166-2-' + code}
            label={l('ISO 3166-2:')}
          >
            {code}
          </SidebarProperty>
        ))}

        {area.iso_3166_3_codes.map(code => (
          <SidebarProperty
            className="iso-3166-3"
            key={'iso-3166-3-' + code}
            label={l('ISO 3166-3:')}
          >
            {code}
          </SidebarProperty>
        ))}
      </SidebarProperties>

      <SidebarTags
        aggregatedTags={$c.stash.top_tags}
        entity={area}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

      <ExternalLinks empty entity={area} />

      <EditLinks entity={area}>
        {$c.user && $c.user.is_location_editor ? (
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
};

export default withCatalystContext(AreaSidebar);
