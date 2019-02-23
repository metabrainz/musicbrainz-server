/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015—2016 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import React from 'react';

import {l} from '../i18n';
import {artistCreditFromArray} from '../immutable-entities';

import AreaWithContainmentLink from './AreaWithContainmentLink';
import ArtistCreditLink from './ArtistCreditLink';
import EntityLink from './EntityLink';

const DescriptiveLink = ({entity, content, showDeletedArtists = true}) => {
  const props = {content, showDisambiguation: true};

  if (entity.entityType === 'area' && entity.gid) {
    return <AreaWithContainmentLink area={entity} {...props} />;
  }

  props.key = 0;
  const link = <EntityLink entity={entity} {...props} />;

  if (entity.artistCredit) {
    let artistCredit = ko.unwrap(entity.artistCredit);
    if (Array.isArray(artistCredit)) {
      artistCredit = artistCreditFromArray(artistCredit);
    }
    return l('{entity} by {artist}', {
      entity: link,
      artist: (
        <ArtistCreditLink
          artistCredit={artistCredit}
          key={1}
          showDeleted={showDeletedArtists}
        />
      ),
    });
  }

  if (entity.entityType === 'place' && entity.area) {
    return l('{place} in {area}', {
      place: link,
      area: <AreaWithContainmentLink area={entity.area} key="area" />,
    });
  }

  return link;
};

export default DescriptiveLink;
