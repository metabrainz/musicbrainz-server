/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistLayout from './ArtistLayout.js';

component CannotSplit(artist: ArtistT, isEmpty?: boolean) {
  return (
    <ArtistLayout entity={artist} page="cannot_split">
      <h2>{l('Split into separate artists')}</h2>
      <p>
        {isEmpty /*:: === true */ ? (
          l(`This artist is already empty
             and is awaiting automatic deletion.`)
        ) : (
          exp.l(
            `This artist has relationships other than collaboration
             relationships, and cannot be split until these are
             removed. {relationships|View all relationships}.`,
            {relationships: `/artist/${artist.gid}/relationships`},
          )
        )}
      </p>
    </ArtistLayout>
  );
}

export default CannotSplit;
