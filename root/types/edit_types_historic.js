/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type AddDiscIdHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT,
    +full_toc: string,
    +releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_ADD_DISCID_T,
}>;

declare type AddRelationshipHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +relationships: ReadonlyArray<RelationshipT>,
  },
  +edit_type: EDIT_HISTORIC_ADD_LINK_T,
}>;

declare type AddReleaseHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist: ArtistT,
    +language: LanguageT | null,
    +name: string,
    +release_events: ReadonlyArray<{
      +barcode: number,
      +catalog_number: string | null,
      +country: AreaT | null,
      +date: PartialDateT | null,
      +format: MediumFormatT | null,
      +label: LabelT | null,
    }>,
    +releases: ReadonlyArray<ReleaseT | null>,
    +script: ScriptT | null,
    +status: ReleaseStatusT | null,
    +tracks: ReadonlyArray<{
      +artist: ArtistT,
      +length: number | null,
      +name: string,
      +position: number,
      +recording: RecordingT,
    }>,
    +type: ReleaseGroupTypeT | null,
  },
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_T,
}>;

declare type AddReleaseAnnotationHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +changelog: string,
    +html: string,
    +releases: ReadonlyArray<ReleaseT>,
    +text: string,
  },
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_ANNOTATION_T,
}>;

declare type AddTrackKVHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist?: ArtistT,
    +length: number,
    +name: string,
    +position: number,
    +recording: RecordingT,
    +releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_ADD_TRACK_KV_T,
}>;

declare type AddTrackOldHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_name?: string,
    +name: string,
    +position: number,
    +releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_ADD_TRACK_T,
}>;

declare type ChangeArtistQualityHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist: ArtistT,
    +quality: CompT<QualityT>,
  },
  +edit_type: EDIT_HISTORIC_CHANGE_ARTIST_QUALITY_T,
}>;

declare type ChangeReleaseArtistHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist: CompT<ArtistT>,
    +releases: ReadonlyArray<ReleaseT>,
  },
}>;

declare type ChangeReleaseArtistHistoricEditMACToSACT = Readonly<{
  ...ChangeReleaseArtistHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_MAC_TO_SAC_T,
}>;

declare type ChangeReleaseArtistHistoricEditSACToMACT = Readonly<{
  ...ChangeReleaseArtistHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_SAC_TO_MAC_T,
}>;

declare type ChangeReleaseArtistHistoricEditT =
  | ChangeReleaseArtistHistoricEditMACToSACT
  | ChangeReleaseArtistHistoricEditSACToMACT;

declare type ChangeReleaseGroupHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +release_group: CompT<ReleaseGroupT>,
    +releases: ReadonlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_CHANGE_RELEASE_GROUP_T,
}>;

declare type ChangeReleaseQualityHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +changes: ReadonlyArray<{
      +quality: CompT<QualityT>,
      +releases: ReadonlyArray<ReleaseT>,
    }>,
  },
  +edit_type: EDIT_HISTORIC_CHANGE_RELEASE_QUALITY_T,
}>;

declare type EditRelationshipHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +relationship: CompT<ReadonlyArray<RelationshipT>>,
  },
  +edit_type: EDIT_HISTORIC_EDIT_LINK_T,
}>;

declare type EditReleaseAttributesHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +changes: ReadonlyArray<{
      +releases: ReadonlyArray<ReleaseT | null>,
      +status: ReleaseStatusT | null,
      +type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
    }>,
    +status: ReleaseStatusT | null,
    +type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
  },
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_ATTRS_T,
}>;

declare type EditReleaseEventsHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +additions: ReadonlyArray<OldReleaseEventT>,
    +edits: ReadonlyArray<OldReleaseEventCompT>,
    +removals: ReadonlyArray<OldReleaseEventT>,
  },
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_EVENTS_T |
              EDIT_HISTORIC_EDIT_RELEASE_EVENTS_T |
              EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD_T |
              EDIT_HISTORIC_REMOVE_RELEASE_EVENTS_T,
}>;

declare type AddReleaseEventsHistoricEditT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditNewerT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditOlderT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD_T,
}>;

declare type RemoveReleaseEventsHistoricEditT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_REMOVE_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditT =
  | AddReleaseEventsHistoricEditT
  | EditReleaseEventsHistoricEditNewerT
  | EditReleaseEventsHistoricEditOlderT
  | RemoveReleaseEventsHistoricEditT;

declare type EditReleaseLanguageHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +language: LanguageT | null,
    +old: ReadonlyArray<{
      +language: LanguageT | null,
      +releases: ReadonlyArray<ReleaseT | null>,
      +script: ScriptT | null,
    }>,
    +script: ScriptT | null,
  },
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE_T,
}>;

declare type EditReleaseNameHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +name: CompT<string>,
    +releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_NAME_T,
}>;

declare type EditTrackHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist?: CompT<ArtistT>,
    +position?: CompT<number>,
    +recording: RecordingT,
  },
}>;

declare type EditTrackHistoricEditArtistT = Readonly<{
  ...EditTrackHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_CHANGE_TRACK_ARTIST_T,
}>;

declare type EditTrackHistoricEditNumberT = Readonly<{
  ...EditTrackHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_TRACKNUM_T,
}>;

declare type EditTrackHistoricEditT =
  | EditTrackHistoricEditArtistT
  | EditTrackHistoricEditNumberT;

declare type MergeReleasesHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    merge_attributes: boolean,
    merge_language: boolean,
    releases: {
      new: ReadonlyArray<ReleaseT>,
      old: ReadonlyArray<ReleaseT>,
    },
  },
}>;

declare type MergeReleasesHistoricEditReleaseT = Readonly<{
  ...MergeReleasesHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_MERGE_RELEASE_T,
}>;

declare type MergeReleasesHistoricEditMACT = Readonly<{
  ...MergeReleasesHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_MERGE_RELEASE_MAC_T,
}>;

declare type MergeReleasesHistoricEditT =
  | MergeReleasesHistoricEditReleaseT
  | MergeReleasesHistoricEditMACT;

declare type MoveDiscIdHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT,
    +new_releases: ReadonlyArray<ReleaseT | null>,
    +old_releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_MOVE_DISCID_T,
}>;

declare type MoveReleaseHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist: CompT<ArtistT>,
    +move_tracks: boolean,
    +releases: ReadonlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_MOVE_RELEASE_T,
}>;

declare type MoveReleaseToReleaseGroupHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +release: ReleaseT,
    +release_group: CompT<ReleaseGroupT>,
  },
  +edit_type: EDIT_RELEASE_MOVE_T,
}>;

declare type RemoveDiscIdHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: {
      +discid: string,
      +entityType: 'cdtoc',
    },
    +releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_DISCID_T,
}>;

declare type RemoveLabelAliasHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +alias: string,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_LABEL_ALIAS_T,
}>;

declare type RemoveRelationshipHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +relationships: ReadonlyArray<RelationshipT>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_LINK_T,
}>;

declare type RemoveReleaseHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: ArtistCreditT,
    +name: string,
    +releases: ReadonlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_RELEASE_T,
}>;

declare type RemoveReleasesHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +releases: ReadonlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_RELEASES_T,
}>;

declare type RemoveTrackHistoricEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +name: string,
    +recording: RecordingT,
    +releases: ReadonlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_TRACK_T,
}>;

// For ease of use elsewhere
declare type HistoricEditT =
  | AddDiscIdHistoricEditT
  | AddRelationshipHistoricEditT
  | AddReleaseHistoricEditT
  | AddReleaseAnnotationHistoricEditT
  | AddTrackKVHistoricEditT
  | AddTrackOldHistoricEditT
  | ChangeArtistQualityHistoricEditT
  | ChangeReleaseArtistHistoricEditT
  | ChangeReleaseGroupHistoricEditT
  | ChangeReleaseQualityHistoricEditT
  | EditRelationshipHistoricEditT
  | EditReleaseAttributesHistoricEditT
  | EditReleaseEventsHistoricEditT
  | EditReleaseLanguageHistoricEditT
  | EditReleaseNameHistoricEditT
  | EditTrackHistoricEditT
  | MergeReleasesHistoricEditT
  | MoveDiscIdHistoricEditT
  | MoveReleaseHistoricEditT
  | MoveReleaseToReleaseGroupHistoricEditT
  | RemoveDiscIdHistoricEditT
  | RemoveLabelAliasHistoricEditT
  | RemoveRelationshipHistoricEditT
  | RemoveReleaseHistoricEditT
  | RemoveReleasesHistoricEditT
  | RemoveTrackHistoricEditT;
