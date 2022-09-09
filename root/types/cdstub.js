/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// MusicBrainz::Server::Entity::CDStub::TO_JSON
declare type CDStubT = $ReadOnly<{
  ...EntityRoleT<'cdstub'>,
  +artist: string,
  +barcode: string,
  // null properties are not present in search indexes
  +date_added: string | null,
  +discid: string,
  +last_modified: string | null,
  +lookup_count: number | null,
  +modify_count: number | null,
  +title: string,
  +toc: string | null,
  +track_count: number,
  +tracks: $ReadOnlyArray<CDStubTrackT>,
}>;

declare type CDStubTrackT = $ReadOnly<{
  +artist: string,
  +length: number,
  +sequence: number,
  +title: string,
}>;
