/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type ReportAnnotationRoleT = {
  readonly created: string,
  readonly text: string,
};

export type ReportRelationshipRoleT = {
  readonly link_gid: string,
  readonly link_name: string,
};

export type ReportArtistAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly artist: ?ArtistT,
  readonly artist_id: number,
  readonly row_number: number,
}>;

export type ReportArtistCreditT = {
  readonly artist_credit: ?ArtistCreditT,
  readonly artist_credit_id: number,
  readonly key?: string,
  readonly row_number: number,
};

export type ReportArtistRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly artist: ?ArtistT,
  readonly artist_id: number,
  readonly row_number: number,
}>;

export type ReportArtistT = {
  readonly alias?: string,
  readonly artist: ?ArtistT,
  readonly artist_id: number,
  readonly key?: string,
  readonly row_number: number,
};

export type ReportArtistUrlT = {
  readonly artist: ?ArtistT,
  readonly artist_id: number,
  readonly row_number: number,
  readonly url: UrlT,
};

export type ReportCDTocT = {
  readonly cdtoc: ?CDTocT,
  readonly cdtoc_id: number,
  readonly format: string,
  readonly length: number,
  readonly row_number: number,
};

export type ReportCDTocReleaseT = {
  readonly cdtoc: ?CDTocT,
  readonly cdtoc_id: number,
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
};

export type ReportCollaborationT = {
  readonly artist0: ?ArtistT,
  readonly artist1: ?ArtistT,
  readonly id0: number,
  readonly id1: number,
  readonly name0: string,
  readonly name1: string,
  readonly row_number: number,
};

export type ReportDataT<T> = {
  readonly canBeFiltered: boolean,
  readonly filtered: boolean,
  readonly generated: string,
  readonly items: ReadonlyArray<T>,
  readonly pager: PagerT,
};

export type ReportEditorT = {
  readonly editor: ?UnsanitizedEditorT,
  readonly id: number,
  readonly row_number: number,
};

export type ReportEventAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly event: ?EventT,
  readonly event_id: number,
  readonly row_number: number,
}>;

export type ReportEventT = {
  readonly event: ?EventT,
  readonly event_id: number,
  readonly row_number: number,
};

export type ReportInstrumentT = {
  readonly instrument: ?InstrumentT,
  readonly instrument_id: number,
  readonly row_number: number,
};

export type ReportIsrcT = {
  readonly isrc: string,
  readonly length: number,
  readonly name: string,
  readonly recording: ?RecordingT,
  readonly recording_id: string,
  readonly recordingcount: number,
  readonly row_number: number,
  readonly text: string,
};

export type ReportIswcT = {
  readonly iswc: string,
  readonly row_number: number,
  readonly text: string,
  readonly work: ?WorkT,
  readonly work_id: string,
  readonly workcount: number,
};

export type ReportLabelAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly label: ?LabelT,
  readonly label_id: number,
  readonly row_number: number,
}>;

export type ReportLabelRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly label: ?LabelT,
  readonly label_id: number,
  readonly row_number: number,
}>;

export type ReportLabelT = {
  readonly label: ?LabelT,
  readonly label_id: number,
  readonly row_number: number,
};

export type ReportLabelUrlT = {
  readonly label: ?LabelT,
  readonly label_id: number,
  readonly row_number: number,
  readonly url: UrlT,
};

export type ReportPlaceAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly place: ?PlaceT,
  readonly place_id: number,
  readonly row_number: number,
}>;

export type ReportPlaceRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly place: ?PlaceT,
  readonly place_id: number,
  readonly row_number: number,
}>;

export type ReportRecordingAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly recording: ?RecordingT,
  readonly recording_id: number,
  readonly row_number: number,
}>;

export type ReportRecordingRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly begin?: number,
  readonly end?: number,
  readonly recording: ?RecordingT,
  readonly recording_id: number,
  readonly row_number: number,
}>;

export type ReportRecordingT = {
  readonly recording: ?RecordingT,
  readonly recording_id: number,
  readonly row_number: number,
};

export type ReportReleaseAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
}>;

export type ReportReleaseCatNoT = {
  readonly catalog_number: string,
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
};

export type ReportReleaseGroupAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly release_group: ?ReleaseGroupT,
  readonly release_group_id: number,
  readonly row_number: number,
}>;

export type ReportReleaseGroupRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly release_group: ?ReleaseGroupT,
  readonly release_group_id: number,
  readonly row_number: number,
}>;

export type ReportReleaseGroupT = {
  readonly release_group: ?ReleaseGroupT,
  readonly release_group_id: number,
  readonly row_number: number,
};

export type ReportReleaseGroupUrlT = {
  readonly release_group: ?ReleaseGroupT,
  readonly release_group_id: number,
  readonly row_number: number,
  readonly url: UrlT,
};

export type ReportReleaseLabelT = {
  readonly label_gid: string,
  readonly label_name: string,
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
};

export type ReportReleaseRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
}>;

export type ReportReleaseReleaseGroupT = {
  readonly release: ?ReleaseT,
  readonly release_group: ?ReleaseGroupT,
  readonly release_group_id: number,
  readonly release_id: number,
  readonly row_number: number,
};

export type ReportReleaseT = {
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
};

export type ReportReleaseUrlT = {
  readonly release: ?ReleaseT,
  readonly release_id: number,
  readonly row_number: number,
  readonly url: UrlT,
};

export type ReportSeriesAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly row_number: number,
  readonly series: ?SeriesT,
  readonly series_id: number,
}>;

export type ReportSeriesDuplicatesT = {
  readonly entity: ?EntityWithSeriesT,
  readonly entity_gid: string,
  readonly order_number: string,
  readonly row_number: number,
  readonly series: ?SeriesT,
  readonly series_id: number,
};

export type ReportUrlRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly row_number: number,
  readonly url: ?UrlT,
  readonly url_id: number,
}>;

export type ReportWorkAnnotationT = Readonly<{
  ...ReportAnnotationRoleT,
  readonly row_number: number,
  readonly work: ?WorkT,
  readonly work_id: number,
}>;

export type ReportWorkRelationshipT = Readonly<{
  ...ReportRelationshipRoleT,
  readonly row_number: number,
  readonly work: ?WorkT,
  readonly work_id: number,
}>;

export type ReportWorkT = {
  readonly row_number: number,
  readonly work: ?WorkT,
  readonly work_id: number,
};
