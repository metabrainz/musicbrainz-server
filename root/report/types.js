/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type ReportAnnotationRoleT = {
  +created: string,
  +text: string,
};

export type ReportRelationshipRoleT = {
  +link_gid: string,
  +link_name: string,
};

export type ReportArtistAnnotationT = {
  ...ReportAnnotationRoleT,
  +artist: ?ArtistT,
  +artist_id: number,
  +row_number: number,
};

export type ReportArtistCreditT = {
  +artist_credit: ?ArtistCreditT,
  +artist_credit_id: number,
  +key?: string,
  +row_number: number,
};

export type ReportArtistRelationshipT = {
  ...ReportRelationshipRoleT,
  +artist: ?ArtistT,
  +artist_id: number,
  +row_number: number,
};

export type ReportArtistT = {
  +alias?: string,
  +artist: ?ArtistT,
  +artist_id: number,
  +key?: string,
  +row_number: number,
};

export type ReportArtistUrlT = {
  +artist: ?ArtistT,
  +artist_id: number,
  +row_number: number,
  +url: UrlT,
};

export type ReportCDTocT = {
  +cdtoc: ?CDTocT,
  +cdtoc_id: number,
  +format: string,
  +length: number,
  +row_number: number,
};

export type ReportCDTocReleaseT = {
  +cdtoc: ?CDTocT,
  +cdtoc_id: number,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportCollaborationT = {
  +artist0: ?ArtistT,
  +artist1: ?ArtistT,
  +id0: number,
  +id1: number,
  +name0: string,
  +name1: string,
  +row_number: number,
};

export type ReportDataT<T> = {
  +canBeFiltered: boolean,
  +filtered: boolean,
  +generated: string,
  +items: $ReadOnlyArray<T>,
  +pager: PagerT,
};

export type ReportEditorT = {
  +editor: ?UnsanitizedEditorT,
  +id: number,
  +row_number: number,
};

export type ReportEventAnnotationT = {
  ...ReportAnnotationRoleT,
  +event: ?EventT,
  +event_id: number,
  +row_number: number,
};

export type ReportEventT = {
  +event: ?EventT,
  +event_id: number,
  +row_number: number,
};

export type ReportInstrumentT = {
  +instrument: ?InstrumentT,
  +instrument_id: number,
  +row_number: number,
};

export type ReportIsrcT = {
  +isrc: string,
  +length: number,
  +name: string,
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: string,
  +recordingcount: number,
  +row_number: number,
  +text: string,
};

export type ReportIswcT = {
  +iswc: string,
  +row_number: number,
  +text: string,
  +work: ?WorkT,
  +work_id: string,
  +workcount: number,
};

export type ReportLabelAnnotationT = {
  ...ReportAnnotationRoleT,
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
};

export type ReportLabelRelationshipT = {
  ...ReportRelationshipRoleT,
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
};

export type ReportLabelT = {
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
};

export type ReportLabelUrlT = {
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
  +url: UrlT,
};

export type ReportPlaceAnnotationT = {
  ...ReportAnnotationRoleT,
  +place: ?PlaceT,
  +place_id: number,
  +row_number: number,
};

export type ReportPlaceRelationshipT = {
  ...ReportRelationshipRoleT,
  +place: ?PlaceT,
  +place_id: number,
  +row_number: number,
};

export type ReportRecordingAnnotationT = {
  ...ReportAnnotationRoleT,
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: number,
  +row_number: number,
};

export type ReportRecordingRelationshipT = {
  ...ReportRelationshipRoleT,
  +begin?: number,
  +end?: number,
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: number,
  +row_number: number,
};

export type ReportRecordingT = {
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: number,
  +row_number: number,
};

export type ReportReleaseAnnotationT = {
  ...ReportAnnotationRoleT,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseCatNoT = {
  +catalog_number: string,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseGroupAnnotationT = {
  ...ReportAnnotationRoleT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
};

export type ReportReleaseGroupRelationshipT = {
  ...ReportRelationshipRoleT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
};

export type ReportReleaseGroupT = {
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
};

export type ReportReleaseGroupUrlT = {
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
  +url: UrlT,
};

export type ReportReleaseLabelT = {
  +label_gid: string,
  +label_name: string,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseRelationshipT = {
  ...ReportRelationshipRoleT,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseReleaseGroupT = {
  +release: ?ReleaseT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseT = {
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseUrlT = {
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
  +url: UrlT,
};

export type ReportSeriesAnnotationT = {
  ...ReportAnnotationRoleT,
  +row_number: number,
  +series: ?SeriesT,
  +series_id: number,
};

export type ReportUrlRelationshipT = {
  ...ReportRelationshipRoleT,
  +row_number: number,
  +url: ?UrlT,
  +url_id: number,
};

export type ReportWorkAnnotationT = {
  ...ReportAnnotationRoleT,
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
};

export type ReportWorkRelationshipT = {
  ...ReportRelationshipRoleT,
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
};

export type ReportWorkT = {
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
};
