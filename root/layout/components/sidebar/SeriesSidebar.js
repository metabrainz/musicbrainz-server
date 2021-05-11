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
import linkedEntities from '../../../static/scripts/common/linkedEntities';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';
import SubscriptionLinks from './SubscriptionLinks';

type Props = {
  +series: SeriesT,
};

const SeriesSidebar = ({series}: Props): React.Element<'div'> => {
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
