/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function mediumHasMultipleArtists(
  release: ReleaseT,
  medium: MediumT,
): boolean {
  const tracks = medium.tracks;
  if (!tracks || !tracks.length) {
    return false;
  }

  const releaseAcId = release.artistCredit.id;

  for (const track of tracks) {
    if (track.artistCredit.id !== releaseAcId) {
      return true;
    }
  }

  return false;
}
