/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::ArtistCreditName::TO_JSON
declare type ArtistCreditNameT = {
  +artist: ArtistT,
  +joinPhrase: string,
  +name: string,
};

// MusicBrainz::Server::Entity::Role::ArtistCredit::TO_JSON
declare type ArtistCreditRoleT = {
  +artist: string,
  +artistCredit: ArtistCreditT,
};

// MusicBrainz::Server::Entity::ArtistCredit::TO_JSON
declare type ArtistCreditT = {
  +editsPending?: boolean,
  +entityType?: 'artist_credit',
  +id?: number,
  +names: $ReadOnlyArray<ArtistCreditNameT>,
};
