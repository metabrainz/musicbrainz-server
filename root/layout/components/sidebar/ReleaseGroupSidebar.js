/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ArtistCreditLink
  from '../../../static/scripts/common/components/ArtistCreditLink.js';
import entityHref from '../../../static/scripts/common/utility/entityHref.js';
import ExternalLinks from '../ExternalLinks.js';
import releaseGroupType from '../../../utility/releaseGroupType.js';
import {Artwork} from '../../../components/Artwork.js';

import AnnotationLinks from './AnnotationLinks.js';
import CollectionLinks from './CollectionLinks.js';
import EditLinks from './EditLinks.js';
import LastUpdated from './LastUpdated.js';
import MergeLink from './MergeLink.js';
import PlayOnListenBrainzButton from './PlayOnListenBrainzButton.js';
import SidebarLicenses from './SidebarLicenses.js';
import {SidebarProperty, SidebarProperties} from './SidebarProperties.js';
import SidebarRating from './SidebarRating.js';
import SidebarTags from './SidebarTags.js';

type Props = {
  +firstReleaseGid?: string | null,
  +releaseGroup: ReleaseGroupT,
};

const ReleaseGroupSidebar = ({
  firstReleaseGid,
  releaseGroup,
}: Props): React.Element<'div'> => {
  const gid = encodeURIComponent(releaseGroup.gid);
  const typeName = releaseGroupType(releaseGroup);

  return (
    <div id="sidebar">
      {releaseGroup.cover_art ? (
        <div className="cover-art">
          <Artwork artwork={releaseGroup.cover_art} />
        </div>
      ) : null}

      {nonEmpty(firstReleaseGid) ? (
        <PlayOnListenBrainzButton
          entityType="release"
          mbids={firstReleaseGid}
        />
      ) : null}

      <h2 className="release-group-information">
        {l('Release group information')}
      </h2>

      <SidebarProperties>
        <SidebarProperty className="artist" label={l('Artist:')}>
          <ArtistCreditLink artistCredit={releaseGroup.artistCredit} />
        </SidebarProperty>

        {typeName ? (
          <SidebarProperty className="type" label={l('Type:')}>
            {typeName}
          </SidebarProperty>
        ) : null}
      </SidebarProperties>

      <SidebarRating entity={releaseGroup} />

      <SidebarTags entity={releaseGroup} />

      <ExternalLinks empty entity={releaseGroup} />

      <EditLinks entity={releaseGroup}>
        <li>
          <a href={`/release/add?release-group=${gid}`}>
            {l('Add release')}
          </a>
        </li>

        <li className="separator" role="separator" />

        <li>
          <a href={entityHref(releaseGroup, 'set-cover-art')}>
            {l('Set cover art')}
          </a>
        </li>

        <AnnotationLinks entity={releaseGroup} />

        <MergeLink entity={releaseGroup} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={releaseGroup} />

      <SidebarLicenses entity={releaseGroup} />

      <LastUpdated entity={releaseGroup} />
    </div>
  );
};

export default ReleaseGroupSidebar;
