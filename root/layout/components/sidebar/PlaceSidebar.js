/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink';
import * as age from '../../../utility/age';
import isFutureDate from '../../../utility/isFutureDate';
import {formatCoordinates, osmUrl} from '../../../utility/coordinates';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import SidebarBeginDate from './SidebarBeginDate';
import SidebarEndDate from './SidebarEndDate';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarTags from './SidebarTags';
import SidebarType from './SidebarType';

type Props = {
  +$c: CatalystContextT,
  +place: PlaceT,
};

const PlaceSidebar = ({$c, place}: Props): React.Element<'div'> => {
  const placeAge = age.age(place);
  const gid = encodeURIComponent(place.gid);
  const {area, coordinates} = place;
  const heldAtRelGid = 'e2c6f697-07dc-38b1-be0b-83d740165532';

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={place}
      />

      <h2 className="place-information">
        {l('Place information')}
      </h2>

      <SidebarProperties>
        <SidebarType entity={place} typeType="place_type" />

        <SidebarBeginDate
          age={placeAge}
          entity={place}
          label={
            isFutureDate(place.begin_date)
              ? addColonText(lp('Opening', 'place'))
              : addColonText(lp('Opened', 'place'))
          }
        />

        <SidebarEndDate
          age={placeAge}
          entity={place}
          label={
            isFutureDate(place.end_date)
              ? addColonText(lp('Closing', 'place'))
              : addColonText(lp('Closed', 'place'))
          }
        />

        {place.address ? (
          <SidebarProperty className="address" label={l('Address:')}>
            {place.address}
          </SidebarProperty>
        ) : null}

        {area ? (
          <SidebarProperty className="area" label={l('Area:')}>
            <DescriptiveLink entity={area} />
          </SidebarProperty>
        ) : null}

        {coordinates ? (
          <SidebarProperty className="coordinates" label={l('Coordinates:')}>
            <a href={osmUrl(coordinates, 16)}>
              {formatCoordinates(coordinates)}
            </a>
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <SidebarTags
        $c={$c}
        aggregatedTags={$c.stash.top_tags}
        entity={place}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

      <ExternalLinks empty entity={place} />

      <EditLinks entity={place}>
        <li>
          <a
            href={
              `/event/create?rels.0.target=${gid}&rels.0.type=${heldAtRelGid}`
            }
          >
            {l('Add event')}
          </a>
        </li>

        <li className="separator" role="separator" />

        <AnnotationLinks $c={$c} entity={place} />

        <MergeLink entity={place} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks $c={$c} entity={place} />

      <SidebarLicenses entity={place} />

      <LastUpdated entity={place} />
    </div>
  );
};

export default PlaceSidebar;
