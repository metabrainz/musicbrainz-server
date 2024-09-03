/*
 * @flow strict
 * Copyright (C) 2015—2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import type {ReleaseEditorTrackT} from '../../release-editor/types.js';

import AreaWithContainmentLink from './AreaWithContainmentLink.js';
import ArtistCreditLink from './ArtistCreditLink.js';
import EntityLink from './EntityLink.js';

component DescriptiveLink(
  allowNew?: boolean,
  className?: string,
  content?: Expand2ReactOutput,
  customArtistCredit?: ArtistCreditT,
  deletedCaption?: string,
  disableLink: boolean = false,
  entity: CollectionT | RelatableEntityT | TrackT | ReleaseEditorTrackT,
  showCreditedAs: boolean = false,
  showDeletedArtists: boolean = true,
  showDisambiguation: boolean = true,
  showEditsPending: boolean = true,
  showIcon: boolean = false,
  subPath?: string,
  target?: '_blank',
) {
  const sharedProps = {
    showDisambiguation,
    showEditsPending,
    showIcon,
    target,
  };

  const props = {
    allowNew,
    className,
    content,
    deletedCaption,
    disableLink,
    showCreditedAs,
    subPath,
    target,
    ...sharedProps,
  };

  const artistCredit = customArtistCredit || entity.artistCredit;

  if (entity.entityType === 'area' && entity.gid) {
    return <AreaWithContainmentLink area={entity} {...props} />;
  }

  const link = <EntityLink entity={entity} {...props} />;

  if (artistCredit) {
    return exp.l('{entity} by {artist}', {
      artist: (
        <ArtistCreditLink
          artistCredit={ko.unwrap(artistCredit)}
          showDeleted={showDeletedArtists}
          {...sharedProps}
        />
      ),
      entity: link,
    });
  }

  if (entity.entityType === 'place' && entity.area) {
    return exp.l('{place} in {area}', {
      area: (
        <AreaWithContainmentLink
          area={entity.area}
          showIcon={showIcon}
          {...sharedProps}
        />
      ),
      place: link,
    });
  }

  return link;
}

export default DescriptiveLink;
