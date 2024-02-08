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

/*
 * Returns true if the supplied credits include the same underlying artists.
 */
const sameArtists = (
  a: $ReadOnlyArray<ArtistCreditNameT>,
  b: $ReadOnlyArray<ArtistCreditNameT>,
) => arraysEqual(a, b,
  (a, b) => a.artist && b.artist && a.artist.gid === b.artist.gid);

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
  const oldArtistsReduced = reduceArtistCreditNames(oldArtists);

  /*
   * If the track credits exactly match the old release credits or the track
   * credits include the same artists as the new release credits, update
   * them to use the new release credits.
   */
  if (
    reduceArtistCreditNames(trackArtists) === oldArtistsReduced ||
    sameArtists(trackArtists, newArtists)
  ) {
    return newArtists;
  }

  /*
   * If the track credits contain more artists than the old release credits,
   * also check if the first N (where N is the length of the release
   * credits) track artists match the release artists. This handles renaming
   * primary artists on tracks that also include featured artists
   * (MBS-13273).
   *
   * Don't do anything if the track credits already start with the same
   * artists as the new release credits to avoid duplicating artists in the
   * case where the track is credited to "A & B feat. C" and the release is
   * updated from "A" to "A & B" or "A feat. B".
   */
  if (
    oldArtists.length > 0 &&
    newArtists.length > 0 &&
    trackArtists.length > oldArtists.length
  ) {
    const trackPrefix = reduceArtistCreditNames(
      trackArtists.slice(0, oldArtists.length), true,
    );
    if (
      trackPrefix === oldArtistsReduced &&
      !sameArtists(
        trackArtists.slice(0, newArtists.length),
        newArtists,
      )
    ) {
      /*
       * Replace the old release artist(s) with the new one(s) and restore
       * the old join phrase following the release artist.
       */
      const names = cloneArrayDeep(newArtists)
        .concat(trackArtists.slice(oldArtists.length));
      names[newArtists.length - 1] = {
        artist: names[newArtists.length - 1].artist,
        joinPhrase: trackArtists[oldArtists.length - 1].joinPhrase,
        name: names[newArtists.length - 1].name,
      };
      return names;
    }
  }

  return trackArtists;
}
