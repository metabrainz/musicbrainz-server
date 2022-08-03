/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import * as manifest from '../../../static/manifest.mjs';
import ArtistCreditLink
  from '../../../static/scripts/common/components/ArtistCreditLink';
import formatTrackLength
  from '../../../static/scripts/common/utility/formatTrackLength';
import IsrcList from '../../../static/scripts/common/components/IsrcList';
import ExternalLinks from '../ExternalLinks';

import AnnotationLinks from './AnnotationLinks';
import CollectionLinks from './CollectionLinks';
import EditLinks from './EditLinks';
import LastUpdated from './LastUpdated';
import MergeLink from './MergeLink';
import RemoveLink from './RemoveLink';
import SidebarLicenses from './SidebarLicenses';
import {SidebarProperty, SidebarProperties} from './SidebarProperties';
import SidebarRating from './SidebarRating';
import SidebarTags from './SidebarTags';

type Props = {
  +recording: RecordingWithArtistCreditT,
};

const RecordingSidebar = ({recording}: Props): React.Element<'div'> => {
  const firstReleaseYear = recording.first_release_date?.year;

  return (
    <div id="sidebar">
      <h2 className="recording-information">
        {l('Recording information')}
      </h2>

      <SidebarProperties>
        <SidebarProperty className="artist" label={l('Artist:')}>
          <ArtistCreditLink artistCredit={recording.artistCredit} />
        </SidebarProperty>

        {recording.length ? (
          <SidebarProperty className="length" label={l('Length:')}>
            {formatTrackLength(recording.length)}
          </SidebarProperty>
        ) : null}

        {firstReleaseYear == null ? null : (
          <SidebarProperty
            className="first-release-year"
            label={addColonText(l('First release year'))}
          >
            {firstReleaseYear}
          </SidebarProperty>
        )}

        {recording.isrcs.length ? (
          <>
            <IsrcList isSidebar isrcs={recording.isrcs} />
            {manifest.js(
              'common/components/IsrcList',
              {async: 'async'},
            )}
          </>
        ) : null}

      </SidebarProperties>

      <SidebarRating entity={recording} />

      <SidebarTags entity={recording} />

      <ExternalLinks empty entity={recording} />

      <EditLinks entity={recording}>
        <AnnotationLinks entity={recording} />

        <MergeLink entity={recording} />

        <RemoveLink entity={recording} />

        <li className="separator" role="separator" />
      </EditLinks>

      <CollectionLinks entity={recording} />

      <SidebarLicenses entity={recording} />

      <LastUpdated entity={recording} />
    </div>
  );
};

export default RecordingSidebar;
