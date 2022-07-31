/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type AddAnnotationEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +changelog: string,
    +entity_type: AnnotatedEntityTypeT,
    [annotatedEntityType: AnnotatedEntityTypeT]: AnnotatedEntityT,
    +html: string,
    +old_annotation?: string,
    +text: string,
  },
  +edit_type: EDIT_AREA_ADD_ANNOTATION_T,
}>;

declare type AddAreaAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_AREA_ADD_ANNOTATION_T,
}>;

declare type AddArtistAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_ARTIST_ADD_ANNOTATION_T,
}>;

declare type AddEventAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_EVENT_ADD_ANNOTATION_T,
}>;

declare type AddGenreAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_GENRE_ADD_ANNOTATION_T,
}>;

declare type AddInstrumentAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_INSTRUMENT_ADD_ANNOTATION_T,
}>;

declare type AddLabelAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_LABEL_ADD_ANNOTATION_T,
}>;

declare type AddMoodAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_MOOD_ADD_ANNOTATION_T,
}>;

declare type AddPlaceAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_PLACE_ADD_ANNOTATION_T,
}>;

declare type AddRecordingAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_RECORDING_ADD_ANNOTATION_T,
}>;

declare type AddReleaseGroupAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_RELEASEGROUP_ADD_ANNOTATION_T,
}>;

declare type AddReleaseAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_RELEASE_ADD_ANNOTATION_T,
}>;

declare type AddSeriesAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_SERIES_ADD_ANNOTATION_T,
}>;

declare type AddWorkAnnotationEditT = $ReadOnly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_WORK_ADD_ANNOTATION_T,
}>;

declare type AddAnnotationEditT =
  | AddAreaAnnotationEditT
  | AddArtistAnnotationEditT
  | AddEventAnnotationEditT
  | AddGenreAnnotationEditT
  | AddInstrumentAnnotationEditT
  | AddLabelAnnotationEditT
  | AddMoodAnnotationEditT
  | AddPlaceAnnotationEditT
  | AddRecordingAnnotationEditT
  | AddReleaseGroupAnnotationEditT
  | AddReleaseAnnotationEditT
  | AddSeriesAnnotationEditT
  | AddWorkAnnotationEditT;

declare type AddAreaEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...DatePeriodRoleT,
    +area: AreaT,
    +comment: string | null,
    +iso_3166_1: $ReadOnlyArray<string>,
    +iso_3166_2: $ReadOnlyArray<string>,
    +iso_3166_3: $ReadOnlyArray<string>,
    +name: string,
    +sort_name: string | null,
    +type: AreaTypeT | null,
  },
  +edit_type: EDIT_AREA_CREATE_T,
}>;

declare type AddArtistEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...CommentRoleT,
    ...DatePeriodRoleT,
    +area: AreaT | null,
    +artist: ArtistT,
    +begin_area: AreaT | null,
    +end_area: AreaT | null,
    +gender: GenderT | null,
    +ipi_codes: $ReadOnlyArray<string> | null,
    +isni_codes: $ReadOnlyArray<string> | null,
    +name: string,
    +sort_name: string,
    +type: ArtistTypeT | null,
  },
  +edit_type: EDIT_ARTIST_CREATE_T,
}>;

declare type AddCoverArtEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artwork: ArtworkT,
    +position: number,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_ADD_COVER_ART_T,
}>;

declare type AddDiscIdEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +medium?: MediumT,
    +medium_cdtoc: MediumCDTocT,
  },
  +edit_type: EDIT_MEDIUM_ADD_DISCID_T,
}>;

declare type AddEventEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...CommentRoleT,
    ...DatePeriodRoleT,
    +cancelled: boolean,
    +ended: boolean,
    +event: EventT,
    +name: string,
    +setlist: string,
    +time: string | null,
    +type: EventTypeT | null,
  },
  +edit_type: EDIT_EVENT_CREATE_T,
}>;

declare type AddGenreEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...CommentRoleT,
    +genre: GenreT,
    +name: string,
  },
  +edit_type: EDIT_GENRE_CREATE_T,
}>;

declare type AddInstrumentEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...DatePeriodRoleT,
    +comment: string | null,
    +description: string | null,
    +instrument: InstrumentT,
    +name: string,
    +type: InstrumentTypeT | null,
  },
  +edit_type: EDIT_INSTRUMENT_CREATE_T,
}>;

declare type AddIsrcsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +additions: $ReadOnlyArray<{
      +isrc: IsrcT,
      +recording: RecordingT,
    }>,
    +client_version?: string,
  },
  +edit_type: EDIT_RECORDING_ADD_ISRCS_T,
}>;

declare type AddIswcsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +additions: $ReadOnlyArray<{
      +iswc: IswcT,
      +work: WorkT,
    }>,
  },
  +edit_type: EDIT_WORK_ADD_ISWCS_T,
}>;

declare type AddLabelEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +area: AreaT,
    +begin_date: PartialDateT,
    +comment: string,
    +end_date: PartialDateT,
    +ended: boolean,
    +ipi_codes: $ReadOnlyArray<string> | null,
    +isni_codes: $ReadOnlyArray<string> | null,
    +label: LabelT,
    +label_code: number | null,
    +name: string,
    +sort_name: string,
    +type: LabelTypeT | null,
  },
  +edit_type: EDIT_LABEL_CREATE_T,
}>;

declare type AddMediumEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +format: MediumFormatT | null,
    +name?: string,
    +position: number | string,
    +release?: ReleaseT,
    +tracks?: $ReadOnlyArray<TrackT>,
  },
  +edit_type: EDIT_MEDIUM_CREATE_T,
}>;

declare type AddMoodEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...CommentRoleT,
    +mood: MoodT,
    +name: string,
  },
  +edit_type: EDIT_MOOD_CREATE_T,
}>;

declare type AddPlaceEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    ...DatePeriodRoleT,
    +address: string | null,
    +area: AreaT,
    +comment: string | null,
    +coordinates: CoordinatesT | null,
    +name?: string,
    +place: PlaceT,
    +type: PlaceTypeT | null,
  },
  +edit_type: EDIT_PLACE_CREATE_T,
}>;

declare type AddRelationshipEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity0?: CoreEntityT,
    +entity1?: CoreEntityT,
    +relationship: RelationshipT,
    +unknown_attributes: boolean,
  },
  +edit_type: EDIT_RELATIONSHIP_CREATE_T,
}>;

declare type AddRelationshipAttributeEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +child_order: number,
    +creditable: boolean,
    +description: string | null,
    +free_text: boolean,
    +name: string,
    +parent?: LinkAttrTypeT,
  },
  +edit_type: EDIT_RELATIONSHIP_ADD_ATTRIBUTE_T,
}>;

declare type AddRelationshipTypeEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +attributes: $ReadOnlyArray<{
      ...LinkTypeAttrTypeT,
      +typeName: string,
    }>,
    +child_order: number,
    +description: string | null,
    +documentation: string | null,
    +entity0_cardinality?: number,
    +entity0_type: CoreEntityTypeT,
    +entity1_cardinality?: number,
    +entity1_type: CoreEntityTypeT,
    +link_phrase: string,
    +long_link_phrase: string,
    +name: string,
    +orderable_direction?: number,
    +relationship_type?: LinkTypeT,
    +reverse_link_phrase: string,
  },
  +edit_type: EDIT_RELATIONSHIP_ADD_TYPE_T,
}>;

declare type AddReleaseEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit: ArtistCreditT,
    +barcode: string | null,
    +comment: string,
    +events?: $ReadOnlyArray<ReleaseEventT>,
    +language: LanguageT | null,
    +name: string,
    +packaging: ReleasePackagingT | null,
    +release: ReleaseT,
    +release_group: ReleaseGroupT,
    +script: ScriptT | null,
    +status: ReleaseStatusT | null,
  },
  +edit_type: EDIT_RELEASE_CREATE_T,
}>;

declare type AddReleaseGroupEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit: ArtistCreditT,
    +comment: string,
    +name: string,
    +release_group: ReleaseGroupT,
    +secondary_types: string,
    +type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
  },
  +edit_type: EDIT_RELEASEGROUP_CREATE_T,
}>;

declare type AddReleaseLabelEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +catalog_number: string,
    +label?: LabelT,
    +release?: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_ADDRELEASELABEL_T,
}>;

declare type AddRemoveAliasEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +[coreEntityType: CoreEntityTypeT]: CoreEntityT,
    +alias: string,
    +begin_date: PartialDateT,
    +end_date: PartialDateT,
    +ended?: boolean,
    +entity_type: CoreEntityTypeT,
    +locale: string | null,
    +primary_for_locale: boolean,
    +sort_name: string | null,
    +type: AliasTypeT | null,
  },
}>;

declare type AddAreaAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_AREA_ADD_ALIAS_T,
}>;

declare type AddArtistAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_ARTIST_ADD_ALIAS_T,
}>;

declare type AddEventAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_EVENT_ADD_ALIAS_T,
}>;

declare type AddGenreAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_GENRE_ADD_ALIAS_T,
}>;

declare type AddInstrumentAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_INSTRUMENT_ADD_ALIAS_T,
}>;

declare type AddLabelAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_LABEL_ADD_ALIAS_T,
}>;

declare type AddMoodAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_MOOD_ADD_ALIAS_T,
}>;

declare type AddPlaceAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_PLACE_ADD_ALIAS_T,
}>;

declare type AddRecordingAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_RECORDING_ADD_ALIAS_T,
}>;

declare type AddReleaseGroupAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_RELEASEGROUP_ADD_ALIAS_T,
}>;

declare type AddReleaseAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_RELEASE_ADD_ALIAS_T,
}>;

declare type AddSeriesAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_SERIES_ADD_ALIAS_T,
}>;

declare type AddWorkAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_WORK_ADD_ALIAS_T,
}>;

declare type RemoveAreaAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_AREA_DELETE_ALIAS_T,
}>;

declare type RemoveArtistAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_ARTIST_DELETE_ALIAS_T,
}>;

declare type RemoveEventAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_EVENT_DELETE_ALIAS_T,
}>;

declare type RemoveGenreAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_GENRE_DELETE_ALIAS_T,
}>;

declare type RemoveInstrumentAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_INSTRUMENT_DELETE_ALIAS_T,
}>;

declare type RemoveLabelAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_LABEL_DELETE_ALIAS_T,
}>;

declare type RemoveMoodAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_MOOD_DELETE_ALIAS_T,
}>;

declare type RemovePlaceAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_PLACE_DELETE_ALIAS_T,
}>;

declare type RemoveRecordingAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_RECORDING_DELETE_ALIAS_T,
}>;

declare type RemoveReleaseGroupAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_RELEASEGROUP_DELETE_ALIAS_T,
}>;

declare type RemoveReleaseAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_RELEASE_DELETE_ALIAS_T,
}>;

declare type RemoveSeriesAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_SERIES_DELETE_ALIAS_T,
}>;

declare type RemoveWorkAliasEditT = $ReadOnly<{
  ...AddRemoveAliasEditGenericT,
  +edit_type: EDIT_WORK_DELETE_ALIAS_T,
}>;

declare type AddRemoveAliasEditT =
  | AddAreaAliasEditT
  | AddArtistAliasEditT
  | AddEventAliasEditT
  | AddInstrumentAliasEditT
  | AddLabelAliasEditT
  | AddPlaceAliasEditT
  | AddRecordingAliasEditT
  | AddReleaseGroupAliasEditT
  | AddReleaseAliasEditT
  | AddSeriesAliasEditT
  | AddWorkAliasEditT
  | RemoveAreaAliasEditT
  | RemoveArtistAliasEditT
  | RemoveEventAliasEditT
  | RemoveInstrumentAliasEditT
  | RemoveLabelAliasEditT
  | RemovePlaceAliasEditT
  | RemoveRecordingAliasEditT
  | RemoveReleaseGroupAliasEditT
  | RemoveReleaseAliasEditT
  | RemoveSeriesAliasEditT
  | RemoveWorkAliasEditT;

declare type AddSeriesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +comment: string,
    +name: string,
    +ordering_type: SeriesOrderingTypeT | null,
    +series: SeriesT,
    +type: SeriesTypeT | null,
  },
  +edit_type: EDIT_SERIES_CREATE_T,
}>;

declare type AddStandaloneRecordingEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit: ArtistCreditT,
    +comment: string | null,
    +length: number | null,
    +name: string,
    +recording: RecordingT,
    +video: boolean,
  },
  +edit_type: EDIT_RECORDING_CREATE_T,
}>;

declare type AddWorkEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +attributes?: {
      [attributeName: string]: $ReadOnlyArray<WorkAttributeT>,
    },
    +comment: string,
    +iswc: string,
    +language?: LanguageT,
    +languages?: $ReadOnlyArray<LanguageT>,
    +name: string,
    +type: WorkTypeT | null,
    +work: WorkT,
  },
  edit_type: EDIT_WORK_CREATE_T,
}>;

declare type ChangeReleaseQualityEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +quality: CompT<QualityT>,
    +release: ReleaseT,
  },
  edit_type: EDIT_RELEASE_CHANGE_QUALITY_T,
}>;

declare type ChangeWikiDocEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new_version: number | null,
    +old_version: number | null,
    +page: string,
  },
  +edit_type: EDIT_WIKIDOC_CHANGE_T,
}>;

declare type EditAliasEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +alias: AliasT | null,
  +display_data: {
    +[coreEntityType: CoreEntityTypeT]: CoreEntityT,
    +alias: CompT<string>,
    +begin_date: CompT<PartialDateT>,
    +end_date: CompT<PartialDateT>,
    +ended: CompT<boolean>,
    +entity_type: CoreEntityTypeT,
    +locale: CompT<string | null>,
    +primary_for_locale: CompT<boolean>,
    +sort_name: CompT<string>,
    +type: CompT<AliasTypeT | null>,
  },
}>;

declare type EditAreaAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_AREA_EDIT_ALIAS_T,
}>;

declare type EditArtistAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_ARTIST_EDIT_ALIAS_T,
}>;

declare type EditEventAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_EVENT_EDIT_ALIAS_T,
}>;

declare type EditGenreAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_GENRE_EDIT_ALIAS_T,
}>;

declare type EditInstrumentAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_INSTRUMENT_EDIT_ALIAS_T,
}>;

declare type EditLabelAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_LABEL_EDIT_ALIAS_T,
}>;

declare type EditMoodAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_MOOD_EDIT_ALIAS_T,
}>;

declare type EditPlaceAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_PLACE_EDIT_ALIAS_T,
}>;

declare type EditRecordingAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_RECORDING_EDIT_ALIAS_T,
}>;

declare type EditReleaseGroupAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_RELEASEGROUP_EDIT_ALIAS_T,
}>;

declare type EditReleaseAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_RELEASE_EDIT_ALIAS_T,
}>;

declare type EditSeriesAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_SERIES_EDIT_ALIAS_T,
}>;

declare type EditWorkAliasEditT = $ReadOnly<{
  ...EditAliasEditGenericT,
  +edit_type: EDIT_WORK_EDIT_ALIAS_T,
}>;

declare type EditAliasEditT =
  | EditAreaAliasEditT
  | EditArtistAliasEditT
  | EditEventAliasEditT
  | EditInstrumentAliasEditT
  | EditLabelAliasEditT
  | EditPlaceAliasEditT
  | EditRecordingAliasEditT
  | EditReleaseGroupAliasEditT
  | EditReleaseAliasEditT
  | EditSeriesAliasEditT
  | EditWorkAliasEditT;

declare type EditAreaEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +area: AreaT,
    +begin_date?: CompT<PartialDateT>,
    +comment?: CompT<string | null>,
    +end_date?: CompT<PartialDateT>,
    +ended?: CompT<boolean>,
    +iso_3166_1?: CompT<$ReadOnlyArray<string> | null>,
    +iso_3166_2?: CompT<$ReadOnlyArray<string> | null>,
    +iso_3166_3?: CompT<$ReadOnlyArray<string> | null>,
    +name?: CompT<string>,
    +sort_name?: CompT<string>,
    +type?: CompT<AreaTypeT | null>,
  },
  +edit_type: EDIT_AREA_EDIT_T,
}>;

declare type EditArtistEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +area?: CompT<AreaT | null>,
    +artist: ArtistT,
    +begin_area?: CompT<AreaT | null>,
    +begin_date?: CompT<PartialDateT>,
    +comment?: CompT<string | null>,
    +end_area?: CompT<AreaT | null>,
    +end_date?: CompT<PartialDateT>,
    +ended?: CompT<boolean>,
    +gender?: CompT<GenderT | null>,
    +ipi_codes?: CompT<$ReadOnlyArray<string> | null>,
    +isni_codes?: CompT<$ReadOnlyArray<string> | null>,
    +name?: CompT<string>,
    +sort_name?: CompT<string>,
    +type?: CompT<ArtistTypeT | null>,
  },
  +edit_type: EDIT_ARTIST_EDIT_T,
}>;

declare type EditArtistCreditEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit: CompT<ArtistCreditT>,
  },
  +edit_type: EDIT_ARTIST_EDITCREDIT_T,
}>;

declare type EditBarcodesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +client_version: string | null,
    +submissions: $ReadOnlyArray<{
      +new_barcode: string | null,
      +old_barcode?: string | null,
      +release: ReleaseT,
    }>,
  },
  +edit_type: EDIT_RELEASE_EDIT_BARCODES_T,
}>;

declare type EditCoverArtEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artwork: ArtworkT,
    +comment: CompT<string | null>,
    +release: ReleaseT,
    +types: CompT<$ReadOnlyArray<CoverArtTypeT>>,
  },
  +edit_type: EDIT_RELEASE_EDIT_COVER_ART_T,
}>;

declare type EditEventEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +begin_date?: CompT<PartialDateT | null>,
    +cancelled?: CompT<boolean>,
    +comment?: CompT<string | null>,
    +end_date?: CompT<PartialDateT | null>,
    +event: EventT,
    +name?: CompT<string>,
    +setlist?: CompT<string | null>,
    +time?: CompT<string | null>,
    +type?: CompT<EventTypeT | null>,
  },
  +edit_type: EDIT_EVENT_EDIT_T,
}>;

declare type EditGenreEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +comment?: CompT<string | null>,
    +genre: GenreT,
    +name?: CompT<string>,
  },
  +edit_type: EDIT_GENRE_EDIT_T,
}>;

declare type EditInstrumentEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +comment?: CompT<string | null>,
    +description?: CompT<string | null>,
    +instrument: InstrumentT,
    +name?: CompT<string>,
    +type?: CompT<InstrumentTypeT | null>,
  },
  +edit_type: EDIT_INSTRUMENT_EDIT_T,
}>;

declare type EditLabelEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +area?: CompT<AreaT | null>,
    +begin_date?: CompT<PartialDateT>,
    +comment?: CompT<string | null>,
    +end_date?: CompT<PartialDateT>,
    +ended?: CompT<boolean>,
    +ipi_codes?: CompT<$ReadOnlyArray<string> | null>,
    +isni_codes?: CompT<$ReadOnlyArray<string> | null>,
    +label: LabelT,
    +label_code?: CompT<number>,
    +name?: CompT<string>,
    +sort_name?: CompT<string>,
    +type?: CompT<LabelTypeT | null>,
  },
  +edit_type: EDIT_LABEL_EDIT_T,
}>;

declare type EditMediumEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit_changes?: $ReadOnlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT>,
    +changed_mbids: boolean,
    +data_track_changes: boolean,
    +format?: CompT<MediumFormatT | null>,
    +medium: MediumT,
    +name?: CompT<string>,
    +position?: CompT<number | string>,
    +recording_changes?: $ReadOnlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT>,
    +tracklist_changes?: $ReadOnlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT
      | TracklistChangesRemoveT>,
  },
  +edit_type: EDIT_MEDIUM_EDIT_T,
}>;

declare type EditMoodEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +comment?: CompT<string | null>,
    +mood: MoodT,
    +name?: CompT<string>,
  },
  +edit_type: EDIT_MOOD_EDIT_T,
}>;

declare type EditPlaceEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +address?: CompT<string>,
    +area?: CompT<AreaT | null>,
    +begin_date?: CompT<PartialDateT>,
    +comment?: CompT<string>,
    +coordinates?: CompT<CoordinatesT | null>,
    +end_date?: CompT<PartialDateT>,
    +ended?: CompT<boolean>,
    +name: CompT<string>,
    +place: PlaceT,
    +type?: CompT<PlaceTypeT | null>,
  },
  +edit_type: EDIT_PLACE_EDIT_T,
}>;

declare type EditRecordingEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +comment?: CompT<string | null>,
    +length?: CompT<number | null>,
    +name?: CompT<string>,
    +recording: RecordingT,
    +video?: CompT<boolean>,
  },
}>;

declare type EditRecordingEditHistoricLengthT = $ReadOnly<{
  ...EditRecordingEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_TRACK_LENGTH_T,
}>;

declare type EditRecordingEditHistoricNameT = $ReadOnly<{
  ...EditRecordingEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_TRACKNAME_T,
}>;

declare type EditRecordingEditCurrentT = $ReadOnly<{
  ...EditRecordingEditGenericT,
  +edit_type: EDIT_RECORDING_EDIT_T,
}>;

declare type EditRecordingEditT =
  | EditRecordingEditHistoricLengthT
  | EditRecordingEditHistoricNameT
  | EditRecordingEditCurrentT;

declare type EditRelationshipEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: RelationshipT,
    +old: RelationshipT,
    +unknown_attributes: boolean,
  },
  +edit_type: EDIT_RELATIONSHIP_EDIT_T,
}>;

declare type EditRelationshipAttributeEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +child_order?: CompT<number>,
    +creditable?: CompT<boolean>,
    +description: CompT<string | null>,
    +free_text?: CompT<boolean>,
    +name: CompT<string>,
    +original_description: string | null,
    +original_name: string,
    +parent?: CompT<LinkAttrTypeT | null>,
  },
  + edit_type: EDIT_RELATIONSHIP_ATTRIBUTE_T,
}>;

declare type EditRelationshipTypeEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +attributes: CompT<$ReadOnlyArray<{
      ...LinkTypeAttrTypeT,
      +typeName: string,
    }>>,
    +child_order: CompT<number>,
    +description?: CompT<string | null>,
    +documentation: CompT<string | null>,
    +entity0_cardinality?: CompT<number>,
    +entity1_cardinality?: CompT<number>,
    +examples: CompT<$ReadOnlyArray<{
      +name: string,
      +relationship: RelationshipT,
    }>>,
    +has_dates: CompT<boolean>,
    +is_deprecated: CompT<boolean>,
    +link_phrase?: CompT<string>,
    +long_link_phrase?: CompT<string>,
    +name: CompT<string>,
    +orderable_direction?: CompT<number>,
    +parent?: CompT<LinkTypeT | null>,
    +relationship_type: LinkTypeT,
    +reverse_link_phrase: CompT<string>,
  },
  +edit_type: EDIT_RELATIONSHIP_EDIT_LINK_TYPE_T,
}>;

declare type EditReleaseEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +barcode?: CompT<string | null>,
    +comment?: CompT<string | null>,
    +events?: CompT<$ReadOnlyArray<ReleaseEventT>>,
    +language?: CompT<LanguageT | null>,
    +name?: CompT<string>,
    +packaging?: CompT<ReleasePackagingT | null>,
    +release: ReleaseT,
    +release_group?: CompT<ReleaseGroupT>,
    +script?: CompT<ScriptT | null>,
    +status?: CompT<ReleaseStatusT | null>,
    +update_tracklists?: boolean,
  },
}>;

declare type EditReleaseEditHistoricArtistT = $ReadOnly<{
  ...EditReleaseEditGenericT,
  +edit_type: EDIT_RELEASE_ARTIST_T,
}>;

declare type EditReleaseEditCurrentT = $ReadOnly<{
  ...EditReleaseEditGenericT,
  +edit_type: EDIT_RELEASE_EDIT_T,
}>;

declare type EditReleaseEditT =
  | EditReleaseEditHistoricArtistT
  | EditReleaseEditCurrentT;

declare type EditReleaseGroupEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +comment?: CompT<string | null>,
    +name?: CompT<string>,
    +release_group: ReleaseGroupT,
    +secondary_types: CompT<string>,
    +type?: CompT<ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null>,
  },
  +edit_type: EDIT_RELEASEGROUP_EDIT_T,
}>;

declare type EditReleaseLabelEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +barcode: string | null,
    +catalog_number: {
      +new?: string | null,
      +old: string | null,
    },
    +combined_format?: string,
    +events: $ReadOnlyArray<ReleaseEventT>,
    +label: {
      +new?: LabelT | null,
      +old: LabelT | null,
    },
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_EDITRELEASELABEL_T,
}>;

declare type EditSeriesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +comment?: CompT<string>,
    +name?: CompT<string>,
    +ordering_type?: CompT<SeriesOrderingTypeT>,
    +series: SeriesT,
    +type?: CompT<SeriesTypeT>,
  },
  +edit_type: EDIT_SERIES_EDIT_T,
}>;

declare type EditUrlEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +affects: number,
    +description?: CompT<string | null>,
    +isMerge: boolean,
    +uri?: CompT<string>,
    +url: UrlT,
  },
  +edit_type: EDIT_URL_EDIT_T,
}>;

declare type EditWorkEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +attributes?: {
      +[attributeName: string]: CompT<$ReadOnlyArray<string>>,
    },
    +comment?: CompT<string | null>,
    +iswc?: CompT<string | null>,
    +languages?: CompT<$ReadOnlyArray<LanguageT>>,
    +name?: CompT<string>,
    +type?: CompT<WorkTypeT | null>,
    +work: WorkT,
  },
  +edit_type: EDIT_WORK_EDIT_T,
}>;

declare type MergeAreasEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: AreaT,
    +old: $ReadOnlyArray<AreaT>,
  },
  +edit_type: EDIT_AREA_MERGE_T,
}>;

declare type MergeArtistsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: ArtistT,
    +old: $ReadOnlyArray<ArtistT>,
    +rename: boolean,
  },
  +edit_type: EDIT_ARTIST_MERGE_T,
}>;

declare type MergeEventsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: EventT,
    +old: $ReadOnlyArray<EventT>,
  },
  +edit_type: EDIT_EVENT_MERGE_T,
}>;

declare type MergeInstrumentsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: InstrumentT,
    +old: $ReadOnlyArray<InstrumentT>,
  },
  +edit_type: EDIT_INSTRUMENT_MERGE_T,
}>;

declare type MergeLabelsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: LabelT,
    +old: $ReadOnlyArray<LabelT>,
  },
  +edit_type: EDIT_LABEL_MERGE_T,
}>;

declare type MergePlacesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: PlaceT,
    +old: $ReadOnlyArray<PlaceT>,
  },
  +edit_type: EDIT_PLACE_MERGE_T,
}>;

declare type MergeRecordingsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +large_spread: boolean,
    +new: RecordingWithArtistCreditT,
    +old: $ReadOnlyArray<RecordingWithArtistCreditT>,
  },
  +edit_type: EDIT_RECORDING_MERGE_T,
}>;

declare type MergeReleaseGroupsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: ReleaseGroupT,
    +old: $ReadOnlyArray<ReleaseGroupT>,
  },
  +edit_type: EDIT_RELEASEGROUP_MERGE_T,
}>;

declare type MergeReleasesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +cannot_merge_recordings_reason?: {
      +message: string,
      +vars: {+[var: string]: string, ...},
    },
    +changes: $ReadOnlyArray<{
      +mediums: $ReadOnlyArray<{
        +id: number,
        +new_name: string,
        +new_position: number,
        +old_name: string,
        +old_position: StrOrNum,
      }>,
      +release: ReleaseT,
    }>,
    +edit_version: 1 | 2 | 3,
    +empty_releases?: $ReadOnlyArray<ReleaseT>,
    +merge_strategy: 'append' | 'merge',
    +new: ReleaseT,
    +old: $ReadOnlyArray<ReleaseT>,
    +recording_merges?: $ReadOnlyArray<{
      +destination: RecordingT,
      +large_spread: boolean,
      +medium: string,
      +sources: $ReadOnlyArray<RecordingT>,
      +track: string,
    }>,
  },
  +edit_type: EDIT_RELEASE_MERGE_T,
}>;

declare type MergeSeriesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: SeriesT,
    +old: $ReadOnlyArray<SeriesT>,
  },
  +edit_type: EDIT_SERIES_MERGE_T,
}>;

declare type MergeWorksEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: WorkT,
    +old: $ReadOnlyArray<WorkT>,
  },
  +edit_type: EDIT_WORK_MERGE_T,
}>;

declare type MoveDiscIdEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +medium_cdtoc: MediumCDTocT,
    +new_medium: MediumT,
    +old_medium: MediumT,
  },
  +edit_type: EDIT_MEDIUM_MOVE_DISCID_T,
}>;

declare type RemoveCoverArtEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artwork: ArtworkT,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_REMOVE_COVER_ART_T,
}>;

declare type RemoveDiscIdEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT,
    +medium: MediumT,
  },
  +edit_type: EDIT_MEDIUM_REMOVE_DISCID_T,
}>;

declare type RemoveAreaEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: AreaT,
    +entity_type: 'area',
  },
  +edit_type: EDIT_AREA_DELETE_T,
}>;

declare type RemoveArtistEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: ArtistT,
    +entity_type: 'artist',
  },
  +edit_type: EDIT_ARTIST_DELETE_T,
}>;

declare type RemoveEventEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: EventT,
    +entity_type: 'event',
  },
  +edit_type: EDIT_EVENT_DELETE_T,
}>;

declare type RemoveGenreEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: GenreT,
    +entity_type: 'genre',
  },
  +edit_type: EDIT_GENRE_DELETE_T,
}>;

declare type RemoveInstrumentEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: InstrumentT,
    +entity_type: 'instrument',
  },
  +edit_type: EDIT_INSTRUMENT_DELETE_T,
}>;

declare type RemoveLabelEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: LabelT,
    +entity_type: 'label',
  },
  +edit_type: EDIT_LABEL_DELETE_T,
}>;

declare type RemoveMoodEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: MoodT,
    +entity_type: 'mood',
  },
  +edit_type: EDIT_MOOD_DELETE_T,
}>;

declare type RemovePlaceEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: PlaceT,
    +entity_type: 'place',
  },
  +edit_type: EDIT_PLACE_DELETE_T,
}>;

declare type RemoveRecordingEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: RecordingT,
    +entity_type: 'recording',
  },
  +edit_type: EDIT_RECORDING_DELETE_T,
}>;

declare type RemoveReleaseGroupEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: ReleaseGroupT,
    +entity_type: 'release_group',
  },
  +edit_type: EDIT_RELEASEGROUP_DELETE_T,
}>;

declare type RemoveReleaseEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: ReleaseT,
    +entity_type: 'release',
  },
  +edit_type: EDIT_RELEASE_DELETE_T,
}>;

declare type RemoveSeriesEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: SeriesT,
    +entity_type: 'series',
  },
  +edit_type: EDIT_SERIES_DELETE_T,
}>;

declare type RemoveWorkEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +entity: WorkT,
    +entity_type: 'work',
  },
  +edit_type: EDIT_WORK_DELETE_T,
}>;

declare type RemoveEntityEditT =
  | RemoveAreaEditT
  | RemoveArtistEditT
  | RemoveEventEditT
  | RemoveGenreEditT
  | RemoveInstrumentEditT
  | RemoveLabelEditT
  | RemoveMoodEditT
  | RemovePlaceEditT
  | RemoveRecordingEditT
  | RemoveReleaseGroupEditT
  | RemoveReleaseEditT
  | RemoveSeriesEditT
  | RemoveWorkEditT;

declare type RemoveIsrcEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +isrc: IsrcT,
  },
  +edit_type: EDIT_RECORDING_REMOVE_ISRC_T,
}>;

declare type RemoveIswcEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +iswc: IswcT,
  },
  +edit_type: EDIT_WORK_REMOVE_ISWC_T,
}>;

declare type RemoveMediumEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +medium: MediumT,
    +tracks?: $ReadOnlyArray<TrackT>,
  },
  +edit_type: EDIT_MEDIUM_DELETE_T,
}>;

declare type RemoveRelationshipEditT = $ReadOnly<{
  ...GenericEditT,
  +data: {
    +edit_version?: number,
    +relationship: {
      +entity0: {
        +gid?: string,
        +id: number,
        +name: string,
      },
      +entity0_credit?: string,
      +entity1: {
        +gid?: string,
        +id: number,
        +name: string,
      },
      +entity1_credit?: string,
      +extra_phrase_attributes?: string,
      +id: number,
      +link: {
        +attributes?: $ReadOnlyArray<{
          +credited_as?: string,
          +gid?: string,
          +id?: string | number,
          +name?: string,
          +root_gid?: string,
          +root_id?: string | number,
          +root_name?: string,
          +text_value?: string,
          +type?: {
            +gid: string,
            +id: string | number,
            +name: string,
            +root: {
              +gid: string,
              +id: string | number,
              +name: string,
            },
          },
        }>,
        +begin_date: {
          +day: number | null,
          +month: number | null,
          +year: string | number | null,
        },
        +end_date: {
          +day: number | null,
          +month: number | null,
          +year: string | number | null,
        },
        +ended?: string,
        +type: {
          +entity0_type: string,
          +entity1_type: string,
          +id?: string | number,
          +long_link_phrase?: string,
        },
      },
      +phrase?: string,
    },
  },
  +display_data: {
    +relationship: RelationshipT,
  },
  +edit_type: EDIT_RELATIONSHIP_DELETE_T,
}>;

declare type RemoveRelationshipAttributeEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +description: string | null,
    +name: string,
  },
  +edit_type: EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE_T,
}>;

declare type RemoveRelationshipTypeEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +attributes: $ReadOnlyArray<{
      ...LinkTypeAttrTypeT,
      +typeName: string,
    }>,
    +description: string | null,
    +entity0_type: CoreEntityTypeT,
    +entity1_type: CoreEntityTypeT,
    +link_phrase: string,
    +long_link_phrase: string,
    +name: string,
    +reverse_link_phrase: string,
  },
  +edit_type: EDIT_RELATIONSHIP_REMOVE_LINK_TYPE_T,
}>;

declare type RemoveReleaseLabelEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +catalog_number: string,
    +label?: LabelT,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_DELETERELEASELABEL_T,
}>;

declare type ReorderCoverArtEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +new: $ReadOnlyArray<ArtworkT>,
    +old: $ReadOnlyArray<ArtworkT>,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_REORDER_COVER_ART_T,
}>;

declare type ReorderMediumsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +mediums: $ReadOnlyArray<{
      +new: number,
      +old: 'new' | number,
      +title: string,
    }>,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_REORDER_MEDIUMS_T,
}>;

declare type ReorderRelationshipsEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +relationships: $ReadOnlyArray<{
      +new_order: number,
      +old_order: number,
      +relationship: RelationshipT,
    }>,
  },
  +edit_type: EDIT_RELATIONSHIPS_REORDER_T,
}>;

declare type SetCoverArtEditT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +artwork: CompT<ArtworkT>,
    +isOldArtworkAutomatic: boolean,
    +release_group: ReleaseGroupT,
  },
  +edit_type: EDIT_RELEASEGROUP_SET_COVER_ART_T,
}>;

declare type SetTrackLengthsEditGenericT = $ReadOnly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT | null,
    +length: CompT<$ReadOnlyArray<number | null>>,
    +medium?: MediumT,
    +releases: $ReadOnlyArray<ReleaseT>,
  },
}>;

declare type SetTrackLengthsEditHistoricT = $ReadOnly<{
  ...SetTrackLengthsEditGenericT,
  +edit_type: EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC_T,
}>;

declare type SetTrackLengthsEditStandardT = $ReadOnly<{
  ...SetTrackLengthsEditGenericT,
  +edit_type: EDIT_SET_TRACK_LENGTHS_T,
}>;

declare type SetTrackLengthsEditT =
  | SetTrackLengthsEditHistoricT
  | SetTrackLengthsEditStandardT;

// For ease of use elsewhere
declare type CurrentEditT =
  | AddAnnotationEditT
  | AddAreaEditT
  | AddArtistEditT
  | AddCoverArtEditT
  | AddDiscIdEditT
  | AddEventEditT
  | AddGenreEditT
  | AddInstrumentEditT
  | AddIsrcsEditT
  | AddIswcsEditT
  | AddLabelEditT
  | AddMediumEditT
  | AddMoodEditT
  | AddPlaceEditT
  | AddRelationshipEditT
  | AddRelationshipAttributeEditT
  | AddRelationshipTypeEditT
  | AddReleaseEditT
  | AddReleaseGroupEditT
  | AddReleaseLabelEditT
  | AddRemoveAliasEditT
  | AddSeriesEditT
  | AddStandaloneRecordingEditT
  | AddWorkEditT
  | ChangeReleaseQualityEditT
  | ChangeWikiDocEditT
  | EditAliasEditT
  | EditAreaEditT
  | EditArtistEditT
  | EditArtistCreditEditT
  | EditBarcodesEditT
  | EditCoverArtEditT
  | EditEventEditT
  | EditInstrumentEditT
  | EditLabelEditT
  | EditMediumEditT
  | EditPlaceEditT
  | EditRecordingEditT
  | EditRelationshipEditT
  | EditRelationshipAttributeEditT
  | EditRelationshipTypeEditT
  | EditReleaseEditT
  | EditReleaseGroupEditT
  | EditReleaseLabelEditT
  | EditSeriesEditT
  | EditUrlEditT
  | EditWorkEditT
  | MergeAreasEditT
  | MergeArtistsEditT
  | MergeEventsEditT
  | MergeInstrumentsEditT
  | MergeLabelsEditT
  | MergePlacesEditT
  | MergeRecordingsEditT
  | MergeReleaseGroupsEditT
  | MergeReleasesEditT
  | MergeSeriesEditT
  | MergeWorksEditT
  | MoveDiscIdEditT
  | RemoveCoverArtEditT
  | RemoveDiscIdEditT
  | RemoveEntityEditT
  | RemoveIsrcEditT
  | RemoveIswcEditT
  | RemoveMediumEditT
  | RemoveRelationshipEditT
  | RemoveRelationshipAttributeEditT
  | RemoveRelationshipTypeEditT
  | RemoveReleaseLabelEditT
  | ReorderCoverArtEditT
  | ReorderMediumsEditT
  | ReorderRelationshipsEditT
  | SetCoverArtEditT
  | SetTrackLengthsEditT;
