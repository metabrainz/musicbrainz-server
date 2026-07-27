/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

// MusicBrainz::Server::Entity::CDStub::TO_JSON
declare type CDStubT = Readonly<{
  ...EntityRoleT<'cdstub'>,
  readonly artist: string,
  readonly barcode: string,
  readonly comment?: string,
  // null properties are not present in search indexes
  readonly date_added: string | null,
  readonly discid: string,
  readonly last_modified: string | null,
  readonly leadout_offset: number | null,
  readonly lookup_count: number | null,
  readonly modify_count: number | null,
  readonly title: string,
  readonly toc: string | null,
  readonly track_count: number,
  readonly track_offset: ReadonlyArray<number> | null,
  readonly tracks: ReadonlyArray<CDStubTrackT>,
}>;

declare type CDStubTrackT = Readonly<{
  readonly artist: string,
  readonly length: number,
  readonly sequence: number,
  readonly title: string,
}>;
