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

export type ReportArtistAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +artist: ?ArtistT,
  +artist_id: number,
  +row_number: number,
}>;

export type ReportArtistCreditT = {
  +artist_credit: ?ArtistCreditT,
  +artist_credit_id: number,
  +key?: string,
  +row_number: number,
};

export type ReportArtistRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +artist: ?ArtistT,
  +artist_id: number,
  +row_number: number,
}>;

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

export type ReportEventAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +event: ?EventT,
  +event_id: number,
  +row_number: number,
}>;

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

export type ReportLabelAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
}>;

export type ReportLabelRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
}>;

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

export type ReportPlaceAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +place: ?PlaceT,
  +place_id: number,
  +row_number: number,
}>;

export type ReportPlaceRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +place: ?PlaceT,
  +place_id: number,
  +row_number: number,
}>;

export type ReportRecordingAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: number,
  +row_number: number,
}>;

export type ReportRecordingRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +begin?: number,
  +end?: number,
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: number,
  +row_number: number,
}>;

export type ReportRecordingT = {
  +recording: ?RecordingWithArtistCreditT,
  +recording_id: number,
  +row_number: number,
};

export type ReportReleaseAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
}>;

export type ReportReleaseCatNoT = {
  +catalog_number: string,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseGroupAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
}>;

export type ReportReleaseGroupRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
}>;

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

export type ReportReleaseRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
}>;

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

export type ReportSeriesAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +row_number: number,
  +series: ?SeriesT,
  +series_id: number,
}>;

export type ReportSeriesDuplicatesT = {
  +entity: ?EntityWithSeriesT,
  +entity_gid: string,
  +order_number: string,
  +row_number: number,
  +series: ?SeriesT,
  +series_id: number,
};

export type ReportUrlRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +row_number: number,
  +url: ?UrlT,
  +url_id: number,
}>;

export type ReportWorkAnnotationT = $ReadOnly<{
  ...ReportAnnotationRoleT,
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
}>;

export type ReportWorkRelationshipT = $ReadOnly<{
  ...ReportRelationshipRoleT,
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
}>;

export type ReportWorkT = {
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
};
