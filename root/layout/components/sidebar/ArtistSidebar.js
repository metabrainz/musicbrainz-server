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
} from '../../../artist/utils';
import CommonsImage
  from '../../../static/scripts/common/components/CommonsImage';
import DescriptiveLink
  from '../../../static/scripts/common/components/DescriptiveLink';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import isSpecialPurpose
  from '../../../static/scripts/common/utility/isSpecialPurpose';
import * as age from '../../../utility/age';
import isFutureDate from '../../../utility/isFutureDate';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
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
  +$c: CatalystContextT,
  +artist: ArtistT,
};

const ArtistSidebar = ({$c, artist}: Props): React.Element<'div'> => {
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

      <SidebarTags
        $c={$c}
        aggregatedTags={$c.stash.top_tags}
        entity={artist}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

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
        <SubscriptionLinks $c={$c} entity={artist} />
      )}

      <CollectionLinks entity={artist} />

      <SidebarLicenses entity={artist} />

      <LastUpdated entity={artist} />
    </div>
  );
};

export default ArtistSidebar;
