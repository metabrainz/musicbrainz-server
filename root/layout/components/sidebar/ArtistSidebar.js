/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  artistBeginAreaLabel,
  artistBeginLabel,
  artistEndAreaLabel,
  artistEndLabel,
} from '../../../artist/utils.js';
import {CatalystContext} from '../../../context.mjs';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage.js';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink.js';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';
import isFutureDate
  from '../../../static/scripts/common/utility/isFutureDate.js';
import isSpecialPurpose
  from '../../../static/scripts/common/utility/isSpecialPurpose.js';
import * as age from '../../../utility/age.js';
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
  +artist: ArtistT,
};

const ArtistSidebar = ({artist}: Props): React.Element<'div'> => {
  const $c = React.useContext(CatalystContext);
  const artistAge = age.age(artist);
  const gid = encodeURIComponent(artist.gid);
  const isSpecialPurposeArtist = isSpecialPurpose(artist);
  const {
    area,
    begin_area: beginArea,
    end_area: endArea,
    gender,
  } = artist;

  return (
    <div id="sidebar">
      <CommonsImage
        cachedImage={$c.stash.commons_image}
        entity={artist}
      />

      <h2 className="artist-information">
        {l('Artist information')}
      </h2>

      <SidebarProperties>
        {artist.name === artist.sort_name ? null : (
          <SidebarProperty className="sort-name" label={l('Sort name:')}>
            {artist.sort_name}
          </SidebarProperty>
        )}

        <SidebarType entity={artist} typeType="artist_type" />

        {gender ? (
          <SidebarProperty className="gender" label={l('Gender:')}>
            {lp_attributes(gender.name, 'gender')}
          </SidebarProperty>
        ) : null}

        <SidebarBeginDate
          age={artistAge}
          entity={artist}
          label={artistBeginLabel(artist.typeID)}
        />

        {beginArea ? (
          <SidebarProperty
            className="begin_area"
            label={artistBeginAreaLabel(artist.typeID)}
          >
            <DescriptiveLink entity={beginArea} />
          </SidebarProperty>
        ) : null}

        <SidebarEndDate
          age={artistAge}
          entity={artist}
          label={artistEndLabel(artist.typeID, isFutureDate(artist.end_date))}
        />

        {endArea ? (
          <SidebarProperty
            className="end_area"
            label={artistEndAreaLabel(artist.typeID)}
          >
            <DescriptiveLink entity={endArea} />
          </SidebarProperty>
        ) : null}

        {area ? (
          <SidebarProperty className="area" label={l('Area:')}>
            <DescriptiveLink entity={area} />
          </SidebarProperty>
        ) : null}

        <SidebarIpis entity={artist} />

        <SidebarIsnis entity={artist} />
      </SidebarProperties>

      <SidebarRating entity={artist} />

      <SidebarTags entity={artist} />

      <ExternalLinks empty entity={artist} />

      <EditLinks entity={artist}>
        {isSpecialPurposeArtist ? null : (
          <>
            <li>
              <a href={`/release-group/create?artist=${gid}`}>
                {l('Add release group')}
              </a>
            </li>
            <li>
              <a href={`/release/add?artist=${gid}`}>
                {l('Add release')}
              </a>
            </li>
            <li>
              <a href={`/recording/create?artist=${gid}`}>
                {l('Add recording')}
              </a>
            </li>
            <li>
              <a href={`/work/create?rels.0.target=${gid}`}>
                {l('Add work')}
              </a>
            </li>
            <li>
              <a href={`/event/create?rels.0.target=${gid}`}>
                {l('Add event')}
              </a>
            </li>

            <li className="separator" role="separator" />

            <li>
              <a href={entityHref(artist, 'split')}>
                {l('Split into separate artists')}
              </a>
            </li>
          </>
        )}

        {isSpecialPurposeArtist ? null : (
          <AnnotationLinks entity={artist} />
        )}

        <MergeLink entity={artist} />

        <li className="separator" role="separator" />
      </EditLinks>

      {isSpecialPurposeArtist ? null : (
        <SubscriptionLinks entity={artist} />
      )}

      <CollectionLinks entity={artist} />

      <SidebarLicenses entity={artist} />

      <LastUpdated entity={artist} />
    </div>
  );
};

export default ArtistSidebar;
