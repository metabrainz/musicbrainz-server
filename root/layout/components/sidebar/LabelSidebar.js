/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../../context';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink';
import isSpecialPurpose
  from '../../../static/scripts/common/utility/isSpecialPurpose';
import * as age from '../../../utility/age';
import formatLabelCode from '../../../utility/formatLabelCode';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarBeginDate from './SidebarBeginDate';
import SidebarEndDate from './SidebarEndDate';
import SidebarIpis from './SidebarIpis';
import SidebarIsnis from './SidebarIsnis';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';
import SubscriptionLinks from './SubscriptionLinks';

type Props = {
  +label: LabelT,
};

const LabelSidebar = ({label}: Props): React.Element<'div'> => {
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

        <RemoveLink entity={label} />

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
