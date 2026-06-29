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
  readonly display_data: {
    readonly cdtoc: CDTocT,
    readonly full_toc: string,
    readonly releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_DISCID_T,
}>;

declare type AddRelationshipHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly relationships: ReadonlyArray<RelationshipT>,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_LINK_T,
}>;

declare type AddReleaseHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist: ArtistT,
    readonly language: LanguageT | null,
    readonly name: string,
    readonly release_events: ReadonlyArray<{
      readonly barcode: number,
      readonly catalog_number: string | null,
      readonly country: AreaT | null,
      readonly date: PartialDateT | null,
      readonly format: MediumFormatT | null,
      readonly label: LabelT | null,
    }>,
    readonly releases: ReadonlyArray<ReleaseT | null>,
    readonly script: ScriptT | null,
    readonly status: ReleaseStatusT | null,
    readonly tracks: ReadonlyArray<{
      readonly artist: ArtistT,
      readonly length: number | null,
      readonly name: string,
      readonly position: number,
      readonly recording: RecordingT,
    }>,
    readonly type: ReleaseGroupTypeT | null,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_RELEASE_T,
}>;

declare type AddReleaseAnnotationHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly changelog: string,
    readonly html: string,
    readonly releases: ReadonlyArray<ReleaseT>,
    readonly text: string,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_RELEASE_ANNOTATION_T,
}>;

declare type AddTrackKVHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist?: ArtistT,
    readonly length: number,
    readonly name: string,
    readonly position: number,
    readonly recording: RecordingT,
    readonly releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_TRACK_KV_T,
}>;

declare type AddTrackOldHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_name?: string,
    readonly name: string,
    readonly position: number,
    readonly releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_TRACK_T,
}>;

declare type ChangeArtistQualityHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist: ArtistT,
    readonly quality: CompT<QualityT>,
  },
  readonly edit_type: EDIT_HISTORIC_CHANGE_ARTIST_QUALITY_T,
}>;

declare type ChangeReleaseArtistHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist: CompT<ArtistT>,
    readonly releases: ReadonlyArray<ReleaseT>,
  },
}>;

declare type ChangeReleaseArtistHistoricEditMACToSACT = Readonly<{
  ...ChangeReleaseArtistHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_MAC_TO_SAC_T,
}>;

declare type ChangeReleaseArtistHistoricEditSACToMACT = Readonly<{
  ...ChangeReleaseArtistHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_SAC_TO_MAC_T,
}>;

declare type ChangeReleaseArtistHistoricEditT =
  | ChangeReleaseArtistHistoricEditMACToSACT
  | ChangeReleaseArtistHistoricEditSACToMACT;

declare type ChangeReleaseGroupHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly release_group: CompT<ReleaseGroupT>,
    readonly releases: ReadonlyArray<ReleaseT>,
  },
  readonly edit_type: EDIT_HISTORIC_CHANGE_RELEASE_GROUP_T,
}>;

declare type ChangeReleaseQualityHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly changes: ReadonlyArray<{
      readonly quality: CompT<QualityT>,
      readonly releases: ReadonlyArray<ReleaseT>,
    }>,
  },
  readonly edit_type: EDIT_HISTORIC_CHANGE_RELEASE_QUALITY_T,
}>;

declare type EditRelationshipHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly relationship: CompT<ReadonlyArray<RelationshipT>>,
  },
  readonly edit_type: EDIT_HISTORIC_EDIT_LINK_T,
}>;

declare type EditReleaseAttributesHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly changes: ReadonlyArray<{
      readonly releases: ReadonlyArray<ReleaseT | null>,
      readonly status: ReleaseStatusT | null,
      readonly type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
    }>,
    readonly status: ReleaseStatusT | null,
    readonly type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
  },
  readonly edit_type: EDIT_HISTORIC_EDIT_RELEASE_ATTRS_T,
}>;

declare type EditReleaseEventsHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly additions: ReadonlyArray<OldReleaseEventT>,
    readonly edits: ReadonlyArray<OldReleaseEventCompT>,
    readonly removals: ReadonlyArray<OldReleaseEventT>,
  },
  readonly edit_type: EDIT_HISTORIC_ADD_RELEASE_EVENTS_T |
              EDIT_HISTORIC_EDIT_RELEASE_EVENTS_T |
              EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD_T |
              EDIT_HISTORIC_REMOVE_RELEASE_EVENTS_T,
}>;

declare type AddReleaseEventsHistoricEditT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_ADD_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditNewerT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_EDIT_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditOlderT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD_T,
}>;

declare type RemoveReleaseEventsHistoricEditT = Readonly<{
  ...EditReleaseEventsHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_REMOVE_RELEASE_EVENTS_T,
}>;

declare type EditReleaseEventsHistoricEditT =
  | AddReleaseEventsHistoricEditT
  | EditReleaseEventsHistoricEditNewerT
  | EditReleaseEventsHistoricEditOlderT
  | RemoveReleaseEventsHistoricEditT;

declare type EditReleaseLanguageHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly language: LanguageT | null,
    readonly old: ReadonlyArray<{
      readonly language: LanguageT | null,
      readonly releases: ReadonlyArray<ReleaseT | null>,
      readonly script: ScriptT | null,
    }>,
    readonly script: ScriptT | null,
  },
  readonly edit_type: EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE_T,
}>;

declare type EditReleaseNameHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly name: CompT<string>,
    readonly releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_EDIT_RELEASE_NAME_T,
}>;

declare type EditTrackHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist?: CompT<ArtistT>,
    readonly position?: CompT<number>,
    readonly recording: RecordingT,
  },
}>;

declare type EditTrackHistoricEditArtistT = Readonly<{
  ...EditTrackHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_CHANGE_TRACK_ARTIST_T,
}>;

declare type EditTrackHistoricEditNumberT = Readonly<{
  ...EditTrackHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_EDIT_TRACKNUM_T,
}>;

declare type EditTrackHistoricEditT =
  | EditTrackHistoricEditArtistT
  | EditTrackHistoricEditNumberT;

declare type MergeReleasesHistoricEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
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
  readonly edit_type: EDIT_HISTORIC_MERGE_RELEASE_T,
}>;

declare type MergeReleasesHistoricEditMACT = Readonly<{
  ...MergeReleasesHistoricEditGenericT,
  readonly edit_type: EDIT_HISTORIC_MERGE_RELEASE_MAC_T,
}>;

declare type MergeReleasesHistoricEditT =
  | MergeReleasesHistoricEditReleaseT
  | MergeReleasesHistoricEditMACT;

declare type MoveDiscIdHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly cdtoc: CDTocT,
    readonly new_releases: ReadonlyArray<ReleaseT | null>,
    readonly old_releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_MOVE_DISCID_T,
}>;

declare type MoveReleaseHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist: CompT<ArtistT>,
    readonly move_tracks: boolean,
    readonly releases: ReadonlyArray<ReleaseT>,
  },
  readonly edit_type: EDIT_HISTORIC_MOVE_RELEASE_T,
}>;

declare type MoveReleaseToReleaseGroupHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly release: ReleaseT,
    readonly release_group: CompT<ReleaseGroupT>,
  },
  readonly edit_type: EDIT_RELEASE_MOVE_T,
}>;

declare type RemoveDiscIdHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly cdtoc: {
      readonly discid: string,
      readonly entityType: 'cdtoc',
    },
    readonly releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_REMOVE_DISCID_T,
}>;

declare type RemoveLabelAliasHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly alias: string,
  },
  readonly edit_type: EDIT_HISTORIC_REMOVE_LABEL_ALIAS_T,
}>;

declare type RemoveRelationshipHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly relationships: ReadonlyArray<RelationshipT>,
  },
  readonly edit_type: EDIT_HISTORIC_REMOVE_LINK_T,
}>;

declare type RemoveReleaseHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit?: ArtistCreditT,
    readonly name: string,
    readonly releases: ReadonlyArray<ReleaseT>,
  },
  readonly edit_type: EDIT_HISTORIC_REMOVE_RELEASE_T,
}>;

declare type RemoveReleasesHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly releases: ReadonlyArray<ReleaseT>,
  },
  readonly edit_type: EDIT_HISTORIC_REMOVE_RELEASES_T,
}>;

declare type RemoveTrackHistoricEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly name: string,
    readonly recording: RecordingT,
    readonly releases: ReadonlyArray<ReleaseT | null>,
  },
  readonly edit_type: EDIT_HISTORIC_REMOVE_TRACK_T,
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
