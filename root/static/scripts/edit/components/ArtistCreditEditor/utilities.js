/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import {VARTIST_GID} from '../../../common/constants.js';

import type {
  ArtistCreditNameStateT,
  StateT,
} from './types.js';

export function getArtist(
  name: ArtistCreditNameStateT,
): ArtistT | null {
  return (name.artist.selectedItem?.entity) ?? null;
}

export function getArtistCreditNames(
  state: StateT,
): ReadonlyArray<ArtistCreditNameStateT> {
  return state.names;
}

export function getArtistCreditNamesCtx(
  stateCtx: CowContext<StateT>,
): CowContext<ReadonlyArray<ArtistCreditNameStateT>> {
  return stateCtx.get('names');
}

function getCreditedName(
  name: ArtistCreditNameStateT,
  artist?: ?ArtistT = getArtist(name),
): string {
  return name.name || (artist?.name ?? '');
}

export function getJoinPhrase(name: ArtistCreditNameStateT): string {
  return name.joinPhrase;
}

export function isNameRemoved(name: ArtistCreditNameStateT): boolean {
  return name.removed;
}

export function isNameNotRemoved(name: ArtistCreditNameStateT): boolean {
  return !name.removed;
}

function incompleteArtistCreditNamesFromState(
  names: ReadonlyArray<ArtistCreditNameStateT>,
): ReadonlyArray<IncompleteArtistCreditNameT> {
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
      joinPhrase: getJoinPhrase(x),
      name: getCreditedName(x, artist),
    });
    return accum;
  }, []);
}

export function incompleteArtistCreditFromState(
  names: ReadonlyArray<ArtistCreditNameStateT>,
): IncompleteArtistCreditT {
  return {names: incompleteArtistCreditNamesFromState(names)};
}

export function artistCreditFromState(
  names: ReadonlyArray<ArtistCreditNameStateT>,
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
    getJoinPhrase(name)
  ))
);

export const artistCreditStateToString = (
  names: ReadonlyArray<ArtistCreditNameStateT>,
): string => (
  names.reduce(_accumArtistCreditNameToString, '')
);

export function hasVariousArtists(
  names: ReadonlyArray<ArtistCreditNameStateT>,
): boolean {
  return names.some(
    name => (getArtist(name)?.gid) === VARTIST_GID,
  );
}

export function isArtistCreditStateComplete(
  names: ReadonlyArray<ArtistCreditNameStateT>,
): boolean {
  return names.length > 0 && names.every(
    name => (getArtist(name)?.id) != null,
  );
}

export function setCreditedName(
  nameCtx: CowContext<ArtistCreditNameStateT>,
  creditedName: string,
): void {
  nameCtx.set('name', creditedName);
}

export function setJoinPhrase(
  nameCtx: CowContext<ArtistCreditNameStateT>,
  joinPhrase: string,
): void {
  nameCtx.set('joinPhrase', joinPhrase);
}
