/*
 * @flow
 * Copyright (C) 2015—2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as React from 'react';

import AreaWithContainmentLink from './AreaWithContainmentLink.js';
import ArtistCreditLink from './ArtistCreditLink.js';
import EntityLink from './EntityLink.js';

type DescriptiveLinkProps = {
  +allowNew?: boolean,
  +content?: Expand2ReactOutput,
  +customArtistCredit?: ArtistCreditT,
  +deletedCaption?: string,
  +disableLink?: boolean,
  +entity: CollectionT | CoreEntityT,
  +showDeletedArtists?: boolean,
  +showIcon?: boolean,
  +subPath?: string,
  +target?: '_blank',
};

const DescriptiveLink = ({
  allowNew,
  content,
  customArtistCredit,
  deletedCaption,
  disableLink = false,
  entity,
  showDeletedArtists = true,
  showIcon = false,
  subPath,
  target,
}: DescriptiveLinkProps): Expand2ReactOutput | React.Node => {
  const props = {
    allowNew,
    content,
    deletedCaption,
    disableLink,
    showDisambiguation: true,
    showIcon,
    subPath,
    target,
  };

  // $FlowFixMe
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
        />
      ),
      entity: link,
    });
  }

  if (entity.entityType === 'place' && entity.area) {
    return exp.l('{place} in {area}', {
      area: (
        <AreaWithContainmentLink area={entity.area} showIcon={showIcon} />
      ),
      place: link,
    });
  }

  return link;
};

export default DescriptiveLink;
