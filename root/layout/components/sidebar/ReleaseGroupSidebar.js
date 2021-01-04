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
  from '../../../static/scripts/common/components/ArtistCreditLink';
import entityHref from '../../../static/scripts/common/utility/entityHref';
import ExternalLinks from '../ExternalLinks';
import releaseGroupType from '../../../utility/releaseGroupType';
import {Artwork} from '../../../components/Artwork';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';

type Props = {
  +$c: CatalystContextT,
  +releaseGroup: ReleaseGroupT,
};

const ReleaseGroupSidebar = ({
  $c,
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

      <SidebarTags
        $c={$c}
        aggregatedTags={$c.stash.top_tags}
        entity={releaseGroup}
        more={!!$c.stash.more_tags}
        userTags={$c.stash.user_tags}
      />

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

        <AnnotationLinks $c={$c} entity={releaseGroup} />

        <MergeLink entity={releaseGroup} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks $c={$c} entity={releaseGroup} />

      <SidebarLicenses entity={releaseGroup} />

      <LastUpdated entity={releaseGroup} />
    </div>
  );
};

export default ReleaseGroupSidebar;
