/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */


export type ReportArtistAnnotationT = {
  +artist: ?ArtistT,
  +artist_id: number,
  +created: string,
  +row_number: number,
  +text: string,
};

export type ReportArtistRelationshipT = {
  +artist: ?ArtistT,
  +artist_id: number,
  +link_gid: string,
  +link_name: string,
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
  +$c: CatalystContextT,
  +canBeFiltered: boolean,
  +filtered: boolean,
  +generated: string,
  +items: $ReadOnlyArray<T>,
  +pager: PagerT,
};

export type ReportEditorT = {
  +editor: UnsanitizedEditorT,
  +id: number,
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
  +recording: ?RecordingT,
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
  +created: string,
  +label: ?LabelT,
  +label_id: number,
  +row_number: number,
  +text: string,
};

export type ReportLabelRelationshipT = {
  +label: ?LabelT,
  +label_id: number,
  +link_gid: string,
  +link_name: string,
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
  +created: string,
  +place: ?PlaceT,
  +place_id: number,
  +row_number: number,
  +text: string,
};

export type ReportPlaceRelationshipT = {
  +link_gid: string,
  +link_name: string,
  +place: ?PlaceT,
  +place_id: number,
  +row_number: number,
};

export type ReportRecordingAnnotationT = {
  +created: string,
  +recording: ?RecordingT,
  +recording_id: number,
  +row_number: number,
  +text: string,
};

export type ReportRecordingRelationshipT = {
  +begin?: number,
  +end?: number,
  +link_gid: string,
  +link_name: string,
  +recording: ?RecordingT,
  +recording_id: number,
  +row_number: number,
};

export type ReportRecordingT = {
  +recording: ?RecordingT,
  +recording_id: number,
  +row_number: number,
};

export type ReportRecordingTrackT = {
  +recording: ?RecordingT,
  +recording_id: number,
  +row_number: number,
  +track_name: string,
};

export type ReportReleaseAnnotationT = {
  +created: string,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
  +text: string,
};

export type ReportReleaseCatNoT = {
  +catalog_number: string,
  +release: ?ReleaseT,
  +release_id: number,
  +row_number: number,
};

export type ReportReleaseGroupAnnotationT = {
  +created: string,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
  +text: string,
};

export type ReportReleaseGroupRelationshipT = {
  +link_gid: string,
  +link_name: string,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +row_number: number,
};

export type ReportReleaseGroupT = {
  +key?: string,
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
  +link_gid: string,
  +link_name: string,
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
  +created: string,
  +row_number: number,
  +series: ?SeriesT,
  +series_id: number,
  +text: string,
};

export type ReportUrlRelationshipT = {
  +link_gid: string,
  +link_name: string,
  +row_number: number,
  +url: ?UrlT,
  +url_id: number,
};

export type ReportWorkAnnotationT = {
  +created: string,
  +row_number: number,
  +text: string,
  +work: ?WorkT,
  +work_id: number,
};

export type ReportWorkRelationshipT = {
  +link_gid: string,
  +link_name: string,
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
};

export type ReportWorkT = {
  +row_number: number,
  +work: ?WorkT,
  +work_id: number,
};
