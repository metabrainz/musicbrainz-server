/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015—2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import React from 'react';

import AreaWithContainmentLink from './AreaWithContainmentLink';
import ArtistCreditLink from './ArtistCreditLink';
import EntityLink from './EntityLink';

const DescriptiveLink = ({
  allowNew = false,
  entity, content,
  showDeletedArtists = true,
}) => {
  const props = {allowNew, content, showDisambiguation: true};

  if (entity.entityType === 'area' && entity.gid) {
    return <AreaWithContainmentLink area={entity} {...props} />;
  }

  props.key = 0;
  const link = <EntityLink entity={entity} {...props} />;

  if (entity.artistCredit) {
    return exp.l('{entity} by {artist}', {
      artist: (
        <ArtistCreditLink
          artistCredit={ko.unwrap(entity.artistCredit)}
          key={1}
          showDeleted={showDeletedArtists}
        />
      ),
      entity: link,
    });
  }

  if (entity.entityType === 'place' && entity.area) {
    return exp.l('{place} in {area}', {
      area: <AreaWithContainmentLink area={entity.area} key="area" />,
      place: link,
    });
  }

  return link;
};

export default DescriptiveLink;
