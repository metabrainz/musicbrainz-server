/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {VARTIST_GID} from '../../../common/constants.js';

import type {
  ArtistCreditNameStateT,
} from './types.js';

function getArtist(
  name: ArtistCreditNameStateT,
): ArtistT | null {
  return (name.artist.selectedItem?.entity) ?? null;
}

function getCreditedName(
  name: ArtistCreditNameStateT,
  artist?: ?ArtistT = getArtist(name),
): string {
  return name.name || (artist?.name ?? '');
}

function incompleteArtistCreditNamesFromState(
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): $ReadOnlyArray<IncompleteArtistCreditNameT> {
  return names.reduce((
    accum: Array<IncompleteArtistCreditNameT>,
    x: ArtistCreditNameStateT,
  ) => {
    if (x.removed) {
      return accum;
    }
    const artist = getArtist(x);
    accum.push({
      artist,
      joinPhrase: x.joinPhrase,
      name: getCreditedName(x, artist),
    });
    return accum;
  }, []);
}

export function incompleteArtistCreditFromState(
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): IncompleteArtistCreditT {
  return {names: incompleteArtistCreditNamesFromState(names)};
}

export function artistCreditFromState(
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): ArtistCreditT {
  return {
    // $FlowFixMe[incompatible-type]
    names: incompleteArtistCreditNamesFromState(names).filter((
      x: IncompleteArtistCreditNameT,
    ) => x.artist != null),
  };
}

const _accumArtistCreditNameToString = (
  accum: string,
  name: ArtistCreditNameStateT,
): string => (
  accum +
  (name.removed ? '' : (
    getCreditedName(name) +
    (name.joinPhrase ?? '')
  ))
);

export const artistCreditStateToString = (
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): string => (
  names.reduce(_accumArtistCreditNameToString, '')
);

export function hasVariousArtists(
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): boolean {
  return names.some(
    name => (getArtist(name)?.gid) === VARTIST_GID,
  );
}

export function isArtistCreditStateComplete(
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): boolean {
  return names.length > 0 && names.every(
    name => (getArtist(name)?.id) != null,
  );
}
