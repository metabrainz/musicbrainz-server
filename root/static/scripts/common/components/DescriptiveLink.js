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

import AreaWithContainmentLink from './AreaWithContainmentLink';
import ArtistCreditLink from './ArtistCreditLink';
import EntityLink from './EntityLink';

type DescriptiveLinkProps = {
  +content?: React.Node,
  +entity: CoreEntityT,
  +showDeletedArtists?: boolean,
  +target?: '_blank',
};

const DescriptiveLink = ({
  content,
  entity,
  showDeletedArtists = true,
  target,
}: DescriptiveLinkProps) => {
  const props = {content, showDisambiguation: true, target};

  if (entity.entityType === 'area' && entity.gid) {
    return <AreaWithContainmentLink area={entity} {...props} />;
  }

  const link = <EntityLink entity={entity} {...props} />;

  if (entity.artistCredit) {
    return exp.l('{entity} by {artist}', {
      artist: (
        <ArtistCreditLink
          artistCredit={ko.unwrap(entity.artistCredit)}
          showDeleted={showDeletedArtists}
        />
      ),
      entity: link,
    });
  }

  if (entity.entityType === 'place' && entity.area) {
    return exp.l('{place} in {area}', {
      area: <AreaWithContainmentLink area={entity.area} />,
      place: link,
    });
  }

  return link;
};

export default DescriptiveLink;
