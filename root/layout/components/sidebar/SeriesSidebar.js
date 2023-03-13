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
import linkedEntities
  from '../../../static/scripts/common/linkedEntities.mjs';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperties, SidebarProperty} from './SidebarProperties.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';
import SubscriptionLinks from './SubscriptionLinks.js';

type Props = {
  +series: SeriesT,
};

const SeriesSidebar = ({series}: Props): React$Element<'div'> => {
  const $c = React.useContext(CatalystContext);

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={series}
      />

      <h2 className="series-information">
        {l('Series information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={series} typeType="series_type" />

        <SidebarProperty
          className="series-code"
          label={addColonText(l('Ordering Type'))}
        >
          {lp_attributes(
            linkedEntities.series_ordering_type[series.orderingTypeID].name,
            'series_ordering_type',
          )}
        </SidebarProperty>
      </SidebarProperties>

      <SidebarTags entity={series} />

      <ExternalLinks empty entity={series} />

      <EditLinks entity={series}>
        <AnnotationLinks entity={series} />

        <MergeLink entity={series} />

        <li className="separator" role="separator" />
      </EditLinks>

      <SubscriptionLinks entity={series} />

      <CollectionLinks entity={series} />

      <SidebarLicenses entity={series} />

      <LastUpdated entity={series} />
    </div>
  );
};

export default SeriesSidebar;
