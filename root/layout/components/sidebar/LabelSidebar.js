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
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage.js';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import isSpecialPurpose
  from '../../../static/scripts/common/utility/isSpecialPurpose.js';
import * as age from '../../../utility/age.js';
import formatLabelCode from '../../../utility/formatLabelCode.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import SidebarBeginDate from './SidebarBeginDate.js';
import SidebarEndDate from './SidebarEndDate.js';
import SidebarIpis from './SidebarIpis.js';
import SidebarIsnis from './SidebarIsnis.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';
import SubscriptionLinks from './SubscriptionLinks.js';

type Props = {
  +label: LabelT,
};

const LabelSidebar = ({label}: Props): React$Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const labelAge = age.age(label);
  const gid = encodeURIComponent(label.gid);
  const area = label.area;
  const isSpecialPurposeLabel = isSpecialPurpose(label);

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={label}
      />

      <h2 className="label-information">
        {l('Label information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={label} typeType="label_type" />

        <SidebarBeginDate
          age={labelAge}
          entity={label}
          label={l('Founded:')}
        />

        <SidebarEndDate
          age={labelAge}
          entity={label}
          label={l('Defunct:')}
        />

        <SidebarIpis entity={label} />

        <SidebarIsnis entity={label} />

        {label.label_code ? (
          <SidebarProperty className="label-code" label={l('Label code:')}>
            {formatLabelCode(label.label_code)}
          </SidebarProperty>
        ) : null}

        {area ? (
          <SidebarProperty className="area" label={l('Area:')}>
            <DescriptiveLink entity={area} />
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <SidebarRating entity={label} />

      <SidebarTags entity={label} />

      <ExternalLinks empty entity={label} />

      <EditLinks entity={label}>
        <li>
          <a href={`/release/add?label=${gid}`}>
            {l('Add release')}
          </a>
        </li>

        <li className="separator" role="separator" />

        <AnnotationLinks entity={label} />

        <MergeLink entity={label} />

        <li className="separator" role="separator" />
      </EditLinks>

      {isSpecialPurposeLabel
        ? null
        : <SubscriptionLinks entity={label} />}

      <CollectionLinks entity={label} />

      <SidebarLicenses entity={label} />

      <LastUpdated entity={label} />
    </div>
  );
};

export default LabelSidebar;
