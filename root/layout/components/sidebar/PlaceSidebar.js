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
import * as age from '../../../utility/age.js';
import isFutureDate from '../../../utility/isFutureDate.js';
import {formatCoordinates, osmUrl} from '../../../utility/coordinates.js';
import ExternalLinks from '../ExternalLinks.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import SidebarBeginDate from './SidebarBeginDate.js';
import SidebarEndDate from './SidebarEndDate.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperty, SidebarProperties} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';
import SidebarType from './SidebarType.js';

type Props = {
  +place: PlaceT,
};

const PlaceSidebar = ({place}: Props): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);
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

      <SidebarRating entity={place} />

      <SidebarTags entity={place} />

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

        <AnnotationLinks entity={place} />

        <MergeLink entity={place} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={place} />

      <SidebarLicenses entity={place} />

      <LastUpdated entity={place} />
    </div>
  );
};

export default PlaceSidebar;
