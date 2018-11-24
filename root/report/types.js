/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */


export type ReportArtistAnnotationT = {|
  +artist: ArtistT,
  +artist_id: number,
  +created: string,
  +row_number: number,
  +text: string,
|};

export type ReportArtistRelationshipT = {|
  +artist: ArtistT,
  +artist_id: number,
  +link_gid: string,
  +link_name: string,
  +row_number: number,
|};

export type ReportArtistT = {|
  +alias?: string,
  +artist: ArtistT,
  +artist_id: number,
  +key?: string,
  +row_number: number,
|};

export type ReportArtistURLT = {|
  +artist: ArtistT,
  +artist_id: number,
  +row_number: number,
  +url: UrlT,
|};

export type ReportCollaborationT = {|
  +artist0: ArtistT,
  +artist1: ArtistT,
  +id0: number,
  +id1: number,
  +name0: string,
  +name1: string,
  +row_number: number,
|};

export type ReportDataT<T> = {|
  +$c: CatalystContextT,
  +canBeFiltered: boolean,
  +filtered: boolean | null,
  +generated: string,
  +items: $ReadOnlyArray<T>,
  +pager: PagerT,
|};

export type ReportEditorT = {|
  +bio: string | null,
  +deleted: boolean,
  +email: string,
  +email_confirm_date: string | null,
  +entityType?: string,
  +id: number,
  +last_updated: string,
  +member_since: string,
  +name: string,
  +row_number: number,
  +website: string | null,
|};
