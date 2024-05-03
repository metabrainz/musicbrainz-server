/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistLayout from './ArtistLayout.js';

component SpecialPurpose(artist: ArtistT) {
  return (
    <ArtistLayout
      entity={artist}
      fullWidth
      page="special_purpose"
      title={l('Cannot edit')}
    >
      <h2>{l('You may not edit special purpose artists')}</h2>
      <p>
        {l(`The artist you are trying to edit is a special purpose artist,
            and you may not make direct changes to this data.`)}
      </p>
    </ArtistLayout>
  );
}

export default SpecialPurpose;
