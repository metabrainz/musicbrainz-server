/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type AddDiscIdHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT,
    +full_toc: string,
    +releases: $ReadOnlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_ADD_DISCID_T,
}>;

declare type AddRelationshipHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +relationships: $ReadOnlyArray<RelationshipT>,
  },
  +edit_type: EDIT_HISTORIC_ADD_LINK_T,
}>;

declare type AddReleaseHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist: ArtistT,
    +language: LanguageT | null,
    +name: string,
    +release_events: $ReadOnlyArray<{
      +barcode: number,
      +catalog_number: string | null,
      +country: AreaT | null,
      +date: PartialDateT | null,
      +format: MediumFormatT | null,
      +label: LabelT | null,
    }>,
    +releases: $ReadOnlyArray<ReleaseT | null>,
    +script: ScriptT | null,
    +status: ReleaseStatusT | null,
    +tracks: $ReadOnlyArray<{
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

declare type AddReleaseAnnotationHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +changelog: string,
    +html: string,
    +releases: $ReadOnlyArray<ReleaseT>,
    +text: string,
  },
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_ANNOTATION_T,
}>;

declare type AddTrackKVHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist?: ArtistT,
    +length: number,
    +name: string,
    +position: number,
    +recording: RecordingT,
    +releases: $ReadOnlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_ADD_TRACK_KV_T,
}>;

declare type AddTrackOldHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_name?: string,
    +name: string,
    +position: number,
    +releases: $ReadOnlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_ADD_TRACK_T,
}>;

declare type ChangeArtistQualityHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist: ArtistT,
    +quality: CompT<QualityT>,
  },
  +edit_type: EDIT_HISTORIC_CHANGE_ARTIST_QUALITY_T,
}>;

declare type ChangeReleaseArtistHistoricEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist: CompT<ArtistT>,
    +releases: $ReadOnlyArray<ReleaseT>,
  },
}>;

declare type ChangeReleaseArtistHistoricEditMACToSACT = $ReadOnly<{
  ...ChangeReleaseArtistHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_MAC_TO_SAC_T,
}>;

declare type ChangeReleaseArtistHistoricEditSACToMACT = $ReadOnly<{
  ...ChangeReleaseArtistHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_SAC_TO_MAC_T,
}>;

declare type ChangeReleaseArtistHistoricEditT =
  | ChangeReleaseArtistHistoricEditMACToSACT
  | ChangeReleaseArtistHistoricEditSACToMACT;

declare type ChangeReleaseGroupHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +release_group: CompT<ReleaseGroupT>,
    +releases: $ReadOnlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_CHANGE_RELEASE_GROUP_T,
}>;

declare type ChangeReleaseQualityHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +changes: $ReadOnlyArray<{
      +quality: CompT<QualityT>,
      +releases: $ReadOnlyArray<ReleaseT>,
    }>,
  },
  +edit_type: EDIT_HISTORIC_CHANGE_RELEASE_QUALITY_T,
}>;

declare type EditRelationshipHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +relationship: CompT<$ReadOnlyArray<RelationshipT>>,
  },
  +edit_type: EDIT_HISTORIC_EDIT_LINK_T,
}>;

declare type EditReleaseAttributesHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +changes: $ReadOnlyArray<{
      +releases: $ReadOnlyArray<ReleaseT | null>,
      +status: ReleaseStatusT | null,
      +type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
    }>,
    +status: ReleaseStatusT | null,
    +type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
  },
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_ATTRS_T,
}>;

declare type EditReleaseEventsHistoricEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +additions: $ReadOnlyArray<OldReleaseEventT>,
    +edits: $ReadOnlyArray<OldReleaseEventCompT>,
    +removals: $ReadOnlyArray<OldReleaseEventT>,
  },
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_EVENTS_T |
              EDIT_HISTORIC_EDIT_RELEASE_EVENTS_T |
              EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD_T |
              EDIT_HISTORIC_REMOVE_RELEASE_EVENTS_T,
}>;

declare type AddReleaseEventsHistoricEditT = $ReadOnly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_ADD_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditNewerT = $ReadOnly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditOlderT = $ReadOnly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD_T,
}>;

declare type RemoveReleaseEventsHistoricEditT = $ReadOnly<{
  ...EditReleaseEventsHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_REMOVE_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditT =
  | AddReleaseEventsHistoricEditT
  | EditReleaseEventsHistoricEditNewerT
  | EditReleaseEventsHistoricEditOlderT
  | RemoveReleaseEventsHistoricEditT;

declare type EditReleaseLanguageHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +language: LanguageT | null,
    +old: $ReadOnlyArray<{
      +language: LanguageT | null,
      +releases: $ReadOnlyArray<ReleaseT | null>,
      +script: ScriptT | null,
    }>,
    +script: ScriptT | null,
  },
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE_T,
}>;

declare type EditReleaseNameHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +name: CompT<string>,
    +releases: $ReadOnlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_EDIT_RELEASE_NAME_T,
}>;

declare type EditTrackHistoricEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist?: CompT<ArtistT>,
    +position?: CompT<number>,
    +recording: RecordingT,
  },
}>;

declare type EditTrackHistoricEditArtistT = $ReadOnly<{
  ...EditTrackHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_CHANGE_TRACK_ARTIST_T,
}>;

declare type EditTrackHistoricEditNumberT = $ReadOnly<{
  ...EditTrackHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_TRACKNUM_T,
}>;

declare type EditTrackHistoricEditT =
  | EditTrackHistoricEditArtistT
  | EditTrackHistoricEditNumberT;

declare type MergeReleasesHistoricEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    merge_attributes: boolean,
    merge_language: boolean,
    releases: {
      new: $ReadOnlyArray<ReleaseT>,
      old: $ReadOnlyArray<ReleaseT>,
    },
  },
}>;

declare type MergeReleasesHistoricEditReleaseT = $ReadOnly<{
  ...MergeReleasesHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_MERGE_RELEASE_T,
}>;

declare type MergeReleasesHistoricEditMACT = $ReadOnly<{
  ...MergeReleasesHistoricEditGenericT,
  +edit_type: EDIT_HISTORIC_MERGE_RELEASE_MAC_T,
}>;

declare type MergeReleasesHistoricEditT =
  | MergeReleasesHistoricEditReleaseT
  | MergeReleasesHistoricEditMACT;

declare type MoveDiscIdHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT,
    +new_releases: $ReadOnlyArray<ReleaseT | null>,
    +old_releases: $ReadOnlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_MOVE_DISCID_T,
}>;

declare type MoveReleaseHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist: CompT<ArtistT>,
    +move_tracks: boolean,
    +releases: $ReadOnlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_MOVE_RELEASE_T,
}>;

declare type MoveReleaseToReleaseGroupHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +release: ReleaseT,
    +release_group: CompT<ReleaseGroupT>,
  },
  +edit_type: EDIT_RELEASE_MOVE_T,
}>;

declare type RemoveDiscIdHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: {
      +discid: string,
      +entityType: 'cdtoc',
    },
    +releases: $ReadOnlyArray<ReleaseT | null>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_DISCID_T,
}>;

declare type RemoveLabelAliasHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +alias: string,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_LABEL_ALIAS_T,
}>;

declare type RemoveRelationshipHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +relationships: $ReadOnlyArray<RelationshipT>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_LINK_T,
}>;

declare type RemoveReleaseHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: ArtistCreditT,
    +name: string,
    +releases: $ReadOnlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_RELEASE_T,
}>;

declare type RemoveReleasesHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +releases: $ReadOnlyArray<ReleaseT>,
  },
  +edit_type: EDIT_HISTORIC_REMOVE_RELEASES_T,
}>;

declare type RemoveTrackHistoricEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +name: string,
    +recording: RecordingT,
    +releases: $ReadOnlyArray<ReleaseT | null>,
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
