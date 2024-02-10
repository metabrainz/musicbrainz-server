/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {reduceArtistCreditNames} from '../../common/immutable-entities.js';
import {arraysEqual} from '../../common/utility/arrays.js';
import {cloneArrayDeep} from '../../common/utility/cloneDeep.mjs';

/**
 * Returns true if the first n artists in a and b have the same GIDs.
 * If n is 0 or negative, compares the entire arrays.
 */
const sameEntities = (
  a: $ReadOnlyArray<ArtistCreditNameT>,
  b: $ReadOnlyArray<ArtistCreditNameT>,
  n: number,
): boolean => arraysEqual(
  n > 0 ? a.slice(0, n) : a,
  n > 0 ? b.slice(0, n) : b,
  (a, b) => a.artist && b.artist && a.artist.gid === b.artist.gid,
);

/*
 * Returns a copy of orig with its first numToReplace names changed to
 * replacement, preserving the original join phrase from the end of the
 * replaced names.
 */
const replacePrefix = (
  orig: $ReadOnlyArray<ArtistCreditNameT>,
  numToReplace: number,
  replacement: $ReadOnlyArray<ArtistCreditNameT>,
): $ReadOnlyArray<ArtistCreditNameT> => {
  const updated = cloneArrayDeep(replacement)
    .concat(orig.slice(numToReplace));
  updated[replacement.length - 1] = {
    ...updated[replacement.length - 1],
    joinPhrase: orig[numToReplace - 1].joinPhrase,
  };
  return updated;
};

/*
 * Returns updated artist credits for a track that's part of a release whose
 * credits are being changed from oldArtists to newArtists.
 *
 * If the track's credits should not be changed, the original trackArtists
 * array is returned.
 */
export default function getUpdatedTrackArtists(
  trackArtists: $ReadOnlyArray<ArtistCreditNameT>,
  oldArtists: $ReadOnlyArray<ArtistCreditNameT>,
  newArtists: $ReadOnlyArray<ArtistCreditNameT>,
): $ReadOnlyArray<ArtistCreditNameT> {
  /**
   * If all or a prefix of the track's credits are rendered the same way as
   * the old release's, update the matching portion to use the new release's
   * credits.
   *
   * Don't do anything if the track credits already start with the same
   * artists as the new release credits to avoid duplicating artists in the
   * case where the track is credited to "A & B feat. C" and the release is
   * updated from "A" to "A & B" or "A feat. B".
   */
  if (
    oldArtists.length > 0 &&
    newArtists.length > 0 &&
    !sameEntities(trackArtists, newArtists, newArtists.length)
  ) {
    const oldReduced = reduceArtistCreditNames(oldArtists);
    for (let i = trackArtists.length; i >= 1; i--) {
      const prefixReduced = reduceArtistCreditNames(
        trackArtists.slice(0, i),
        i < trackArtists.length,
      );
      if (prefixReduced === oldReduced) {
        return replacePrefix(trackArtists, i, newArtists);
      }
      if (prefixReduced.length <= oldReduced.length) {
        break;
      }
    }
  }

  /**
   * If the track starts with the same underlying artists as the new release,
   * update it so the artists will be rendered the same way.
   */
  if (sameEntities(trackArtists, newArtists, newArtists.length)) {
    return replacePrefix(trackArtists, newArtists.length, newArtists);
  }

  return trackArtists;
}
