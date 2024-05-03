/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityHeader from '../components/EntityHeader.js';
import ArtistCreditLink
  from '../static/scripts/common/components/ArtistCreditLink.js';

component ReleaseGroupHeader(page: string, releaseGroup: ReleaseGroupT) {
  return (
    <EntityHeader
      entity={releaseGroup}
      headerClass="rgheader"
      page={page}
      subHeading={exp.l('Release group by {artist}', {
        artist: (
          <ArtistCreditLink artistCredit={releaseGroup.artistCredit} />
        ),
      })}
    />
  );
}

export default ReleaseGroupHeader;
