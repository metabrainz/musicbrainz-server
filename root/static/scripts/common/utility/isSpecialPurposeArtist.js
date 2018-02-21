/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const {DARTIST_ID, VARTIST_ID, VARTIST_GID} = require('../constants');

function isSpecialPurposeArtist(artist: ArtistT): boolean {
  return !!(
    (artist.id && artist.id === DARTIST_ID || artist.id === VARTIST_ID) ||
    (artist.gid && artist.gid === VARTIST_GID)
  );
};

module.exports = isSpecialPurposeArtist;
