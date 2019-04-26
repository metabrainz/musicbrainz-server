/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import EntityHeader from '../components/EntityHeader';
import ArtistCreditLink from '../static/scripts/common/components/ArtistCreditLink';
import {artistCreditFromArray} from '../static/scripts/common/immutable-entities';

type Props = {|
  page: string,
  releaseGroup: ReleaseGroupT,
|};

const ReleaseGroupHeader = ({releaseGroup, page}: Props) => {
  const artistCredit = (
    <ArtistCreditLink
      artistCredit={artistCreditFromArray(releaseGroup.artistCredit)}
    />
  );
  return (
    <EntityHeader
      entity={releaseGroup}
      headerClass="rgheader"
      page={page}
      subHeading={exp.l('Release group by {artist}', {
        artist: artistCredit,
      })}
    />
  );
};

export default ReleaseGroupHeader;
