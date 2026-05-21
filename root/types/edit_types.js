/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type AddAnnotationEditGenericT = Readonly<{
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

declare type AddAreaAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_AREA_ADD_ANNOTATION_T,
}>;

declare type AddArtistAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_ARTIST_ADD_ANNOTATION_T,
}>;

declare type AddEventAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_EVENT_ADD_ANNOTATION_T,
}>;

declare type AddGenreAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_GENRE_ADD_ANNOTATION_T,
}>;

declare type AddInstrumentAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_INSTRUMENT_ADD_ANNOTATION_T,
}>;

declare type AddLabelAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_LABEL_ADD_ANNOTATION_T,
}>;

declare type AddPlaceAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_PLACE_ADD_ANNOTATION_T,
}>;

declare type AddRecordingAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_RECORDING_ADD_ANNOTATION_T,
}>;

declare type AddReleaseGroupAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_RELEASEGROUP_ADD_ANNOTATION_T,
}>;

declare type AddReleaseAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_RELEASE_ADD_ANNOTATION_T,
}>;

declare type AddSeriesAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  +edit_type: EDIT_SERIES_ADD_ANNOTATION_T,
}>;

declare type AddWorkAnnotationEditT = Readonly<{
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
  | AddPlaceAnnotationEditT
  | AddRecordingAnnotationEditT
  | AddReleaseGroupAnnotationEditT
  | AddReleaseAnnotationEditT
  | AddSeriesAnnotationEditT
  | AddWorkAnnotationEditT;

declare type AddAreaEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    ...DatePeriodRoleT,
    +area: AreaT,
    +comment: string | null,
    +iso_3166_1: ReadonlyArray<string>,
    +iso_3166_2: ReadonlyArray<string>,
    +iso_3166_3: ReadonlyArray<string>,
    +name: string,
    +sort_name: string | null,
    +type: AreaTypeT | null,
  },
  +edit_type: EDIT_AREA_CREATE_T,
}>;

declare type AddArtistEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    ...CommentRoleT,
    ...DatePeriodRoleT,
    +area: AreaT | null,
    +artist: ArtistT,
    +begin_area: AreaT | null,
    +end_area: AreaT | null,
    +gender: GenderT | null,
    +ipi_codes: ReadonlyArray<string> | null,
    +isni_codes: ReadonlyArray<string> | null,
    +name: string,
    +sort_name: string,
    +type: ArtistTypeT | null,
  },
  +edit_type: EDIT_ARTIST_CREATE_T,
}>;

declare type AddCoverArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: ReleaseArtT,
    +position: number,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_ADD_COVER_ART_T,
}>;

declare type AddDiscIdEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +medium?: MediumT,
    +medium_cdtoc: MediumCDTocT,
  },
  +edit_type: EDIT_MEDIUM_ADD_DISCID_T,
}>;

declare type AddEventArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: EventArtT,
    +event: EventT,
    +position: number,
  },
  +edit_type: EDIT_EVENT_ADD_EVENT_ART_T,
}>;

declare type AddEventEditT = Readonly<{
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

declare type AddGenreEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    ...CommentRoleT,
    +genre: GenreT,
    +name: string,
  },
  +edit_type: EDIT_GENRE_CREATE_T,
}>;

declare type AddInstrumentEditT = Readonly<{
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

declare type AddIsrcsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +additions: ReadonlyArray<{
      +isrc: IsrcT,
      +recording: RecordingT,
    }>,
    +client_version?: string,
  },
  +edit_type: EDIT_RECORDING_ADD_ISRCS_T,
}>;

declare type AddIswcsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +additions: ReadonlyArray<{
      +iswc: IswcT,
      +work: WorkT,
    }>,
  },
  +edit_type: EDIT_WORK_ADD_ISWCS_T,
}>;

declare type AddLabelEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +area: AreaT,
    +begin_date: PartialDateT,
    +comment: string,
    +end_date: PartialDateT,
    +ended: boolean,
    +ipi_codes: ReadonlyArray<string> | null,
    +isni_codes: ReadonlyArray<string> | null,
    +label: LabelT,
    +label_code: number | null,
    +name: string,
    +sort_name: string,
    +type: LabelTypeT | null,
  },
  +edit_type: EDIT_LABEL_CREATE_T,
}>;

declare type AddMediumEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +format: MediumFormatT | null,
    +name?: string,
    +position: number | string,
    +release?: ReleaseT,
    +tracks?: ReadonlyArray<TrackT>,
  },
  +edit_type: EDIT_MEDIUM_CREATE_T,
}>;

declare type AddPlaceEditT = Readonly<{
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

declare type AddRelationshipEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entered_from?: NonUrlRelatableEntityT,
    +relationship: RelationshipT,
    +unknown_attributes: boolean,
  },
  +edit_type: EDIT_RELATIONSHIP_CREATE_T,
}>;

declare type AddRelationshipAttributeEditT = Readonly<{
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

declare type AddRelationshipTypeEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +attributes: ReadonlyArray<{
      ...LinkTypeAttrTypeT,
      +typeName: string,
    }>,
    +child_order: number,
    +description: string | null,
    +documentation: string | null,
    +entity0_cardinality?: number,
    +entity0_type: RelatableEntityTypeT,
    +entity1_cardinality?: number,
    +entity1_type: RelatableEntityTypeT,
    +link_phrase: string,
    +long_link_phrase: string,
    +name: string,
    +orderable_direction?: OrderableDirectionT,
    +relationship_type?: LinkTypeT,
    +reverse_link_phrase: string,
  },
  +edit_type: EDIT_RELATIONSHIP_ADD_TYPE_T,
}>;

declare type AddReleaseEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit: ArtistCreditT,
    +barcode: string | null,
    +comment: string,
    +events?: ReadonlyArray<ReleaseEventT>,
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

declare type AddReleaseGroupEditT = Readonly<{
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

declare type AddReleaseLabelEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +catalog_number: string,
    +label?: LabelT,
    +release?: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_ADDRELEASELABEL_T,
}>;

declare type AddRemoveAliasEditGenericT<+T> = Readonly<{
  ...GenericEditT,
  +display_data: {
    +[coreEntityType: EntityWithAliasesTypeT]: EntityWithAliasesT,
    +alias: string,
    +begin_date: PartialDateT,
    +end_date: PartialDateT,
    +ended?: boolean,
    +entity_type: EntityWithAliasesTypeT,
    +locale: string | null,
    +primary_for_locale: boolean,
    +sort_name: string | null,
    +type: T | null,
  },
}>;

declare type AddAreaAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<AreaAliasTypeT>,
  +edit_type: EDIT_AREA_ADD_ALIAS_T,
}>;

declare type AddArtistAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ArtistAliasTypeT>,
  +edit_type: EDIT_ARTIST_ADD_ALIAS_T,
}>;

declare type AddEventAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<EventAliasTypeT>,
  +edit_type: EDIT_EVENT_ADD_ALIAS_T,
}>;

declare type AddGenreAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<GenreAliasTypeT>,
  +edit_type: EDIT_GENRE_ADD_ALIAS_T,
}>;

declare type AddInstrumentAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<InstrumentAliasTypeT>,
  +edit_type: EDIT_INSTRUMENT_ADD_ALIAS_T,
}>;

declare type AddLabelAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<LabelAliasTypeT>,
  +edit_type: EDIT_LABEL_ADD_ALIAS_T,
}>;

declare type AddPlaceAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<PlaceAliasTypeT>,
  +edit_type: EDIT_PLACE_ADD_ALIAS_T,
}>;

declare type AddRecordingAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<RecordingAliasTypeT>,
  +edit_type: EDIT_RECORDING_ADD_ALIAS_T,
}>;

declare type AddReleaseGroupAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseGroupAliasTypeT>,
  +edit_type: EDIT_RELEASEGROUP_ADD_ALIAS_T,
}>;

declare type AddReleaseAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseAliasTypeT>,
  +edit_type: EDIT_RELEASE_ADD_ALIAS_T,
}>;

declare type AddSeriesAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<SeriesAliasTypeT>,
  +edit_type: EDIT_SERIES_ADD_ALIAS_T,
}>;

declare type AddWorkAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<WorkAliasTypeT>,
  +edit_type: EDIT_WORK_ADD_ALIAS_T,
}>;

declare type RemoveAreaAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<AreaAliasTypeT>,
  +edit_type: EDIT_AREA_DELETE_ALIAS_T,
}>;

declare type RemoveArtistAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ArtistAliasTypeT>,
  +edit_type: EDIT_ARTIST_DELETE_ALIAS_T,
}>;

declare type RemoveEventAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<EventAliasTypeT>,
  +edit_type: EDIT_EVENT_DELETE_ALIAS_T,
}>;

declare type RemoveGenreAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<GenreAliasTypeT>,
  +edit_type: EDIT_GENRE_DELETE_ALIAS_T,
}>;

declare type RemoveInstrumentAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<InstrumentAliasTypeT>,
  +edit_type: EDIT_INSTRUMENT_DELETE_ALIAS_T,
}>;

declare type RemoveLabelAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<LabelAliasTypeT>,
  +edit_type: EDIT_LABEL_DELETE_ALIAS_T,
}>;

declare type RemovePlaceAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<PlaceAliasTypeT>,
  +edit_type: EDIT_PLACE_DELETE_ALIAS_T,
}>;

declare type RemoveRecordingAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<RecordingAliasTypeT>,
  +edit_type: EDIT_RECORDING_DELETE_ALIAS_T,
}>;

declare type RemoveReleaseGroupAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseGroupAliasTypeT>,
  +edit_type: EDIT_RELEASEGROUP_DELETE_ALIAS_T,
}>;

declare type RemoveReleaseAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseAliasTypeT>,
  +edit_type: EDIT_RELEASE_DELETE_ALIAS_T,
}>;

declare type RemoveSeriesAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<SeriesAliasTypeT>,
  +edit_type: EDIT_SERIES_DELETE_ALIAS_T,
}>;

declare type RemoveWorkAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<WorkAliasTypeT>,
  +edit_type: EDIT_WORK_DELETE_ALIAS_T,
}>;

declare type AddRemoveAliasEditT =
  | AddAreaAliasEditT
  | AddArtistAliasEditT
  | AddEventAliasEditT
  | AddGenreAliasEditT
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
  | RemoveGenreAliasEditT
  | RemoveInstrumentAliasEditT
  | RemoveLabelAliasEditT
  | RemovePlaceAliasEditT
  | RemoveRecordingAliasEditT
  | RemoveReleaseGroupAliasEditT
  | RemoveReleaseAliasEditT
  | RemoveSeriesAliasEditT
  | RemoveWorkAliasEditT;

declare type AddSeriesEditT = Readonly<{
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

declare type AddStandaloneRecordingEditT = Readonly<{
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

declare type AddWorkEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +attributes?: {
      [attributeName: string]: ReadonlyArray<WorkAttributeT>,
    },
    +comment: string,
    +iswc: string,
    +language?: LanguageT,
    +languages?: ReadonlyArray<LanguageT>,
    +name: string,
    +type: WorkTypeT | null,
    +work: WorkT,
  },
  edit_type: EDIT_WORK_CREATE_T,
}>;

declare type ChangeReleaseQualityEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +quality: CompT<QualityT>,
    +release: ReleaseT,
  },
  edit_type: EDIT_RELEASE_CHANGE_QUALITY_T,
}>;

declare type ChangeWikiDocEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new_version: number | null,
    +old_version: number | null,
    +page: string,
  },
  +edit_type: EDIT_WIKIDOC_CHANGE_T,
}>;

declare type EditAliasEditGenericT<+A, +T> = Readonly<{
  ...GenericEditT,
  +alias: A | null,
  +display_data: {
    +[coreEntityType: EntityWithAliasesTypeT]: EntityWithAliasesT,
    +alias: CompT<string>,
    +begin_date: CompT<PartialDateT>,
    +end_date: CompT<PartialDateT>,
    +ended: CompT<boolean>,
    +entity_type: EntityWithAliasesTypeT,
    +locale: CompT<string | null>,
    +primary_for_locale: CompT<boolean>,
    +sort_name: CompT<string>,
    +type: CompT<T | null>,
  },
}>;

declare type EditAreaAliasEditT = Readonly<{
  ...EditAliasEditGenericT<AreaAliasT, AreaAliasTypeT>,
  +edit_type: EDIT_AREA_EDIT_ALIAS_T,
}>;

declare type EditArtistAliasEditT = Readonly<{
  ...EditAliasEditGenericT<ArtistAliasT, ArtistAliasTypeT>,
  +edit_type: EDIT_ARTIST_EDIT_ALIAS_T,
}>;

declare type EditEventAliasEditT = Readonly<{
  ...EditAliasEditGenericT<EventAliasT, EventAliasTypeT>,
  +edit_type: EDIT_EVENT_EDIT_ALIAS_T,
}>;

declare type EditGenreAliasEditT = Readonly<{
  ...EditAliasEditGenericT<GenreAliasT, GenreAliasTypeT>,
  +edit_type: EDIT_GENRE_EDIT_ALIAS_T,
}>;

declare type EditInstrumentAliasEditT = Readonly<{
  ...EditAliasEditGenericT<InstrumentAliasT, InstrumentAliasTypeT>,
  +edit_type: EDIT_INSTRUMENT_EDIT_ALIAS_T,
}>;

declare type EditLabelAliasEditT = Readonly<{
  ...EditAliasEditGenericT<LabelAliasT, LabelAliasTypeT>,
  +edit_type: EDIT_LABEL_EDIT_ALIAS_T,
}>;

declare type EditPlaceAliasEditT = Readonly<{
  ...EditAliasEditGenericT<PlaceAliasT, PlaceAliasTypeT>,
  +edit_type: EDIT_PLACE_EDIT_ALIAS_T,
}>;

declare type EditRecordingAliasEditT = Readonly<{
  ...EditAliasEditGenericT<RecordingAliasT, RecordingAliasTypeT>,
  +edit_type: EDIT_RECORDING_EDIT_ALIAS_T,
}>;

declare type EditReleaseGroupAliasEditT = Readonly<{
  ...EditAliasEditGenericT<ReleaseGroupAliasT, ReleaseGroupAliasTypeT>,
  +edit_type: EDIT_RELEASEGROUP_EDIT_ALIAS_T,
}>;

declare type EditReleaseAliasEditT = Readonly<{
  ...EditAliasEditGenericT<ReleaseAliasT, ReleaseAliasTypeT>,
  +edit_type: EDIT_RELEASE_EDIT_ALIAS_T,
}>;

declare type EditSeriesAliasEditT = Readonly<{
  ...EditAliasEditGenericT<SeriesAliasT, SeriesAliasTypeT>,
  +edit_type: EDIT_SERIES_EDIT_ALIAS_T,
}>;

declare type EditWorkAliasEditT = Readonly<{
  ...EditAliasEditGenericT<WorkAliasT, WorkAliasTypeT>,
  +edit_type: EDIT_WORK_EDIT_ALIAS_T,
}>;

declare type EditAliasEditT =
  | EditAreaAliasEditT
  | EditArtistAliasEditT
  | EditEventAliasEditT
  | EditGenreAliasEditT
  | EditInstrumentAliasEditT
  | EditLabelAliasEditT
  | EditPlaceAliasEditT
  | EditRecordingAliasEditT
  | EditReleaseGroupAliasEditT
  | EditReleaseAliasEditT
  | EditSeriesAliasEditT
  | EditWorkAliasEditT;

declare type EditAreaEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +area: AreaT,
    +begin_date?: CompT<PartialDateT>,
    +comment?: CompT<string | null>,
    +end_date?: CompT<PartialDateT>,
    +ended?: CompT<boolean>,
    +iso_3166_1?: CompT<ReadonlyArray<string> | null>,
    +iso_3166_2?: CompT<ReadonlyArray<string> | null>,
    +iso_3166_3?: CompT<ReadonlyArray<string> | null>,
    +name?: CompT<string>,
    +sort_name?: CompT<string>,
    +type?: CompT<AreaTypeT | null>,
  },
  +edit_type: EDIT_AREA_EDIT_T,
}>;

declare type EditArtistEditT = Readonly<{
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
    +ipi_codes?: CompT<ReadonlyArray<string> | null>,
    +isni_codes?: CompT<ReadonlyArray<string> | null>,
    +name?: CompT<string>,
    +sort_name?: CompT<string>,
    +type?: CompT<ArtistTypeT | null>,
  },
  +edit_type: EDIT_ARTIST_EDIT_T,
}>;

declare type EditArtistCreditEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit: CompT<ArtistCreditT>,
  },
  +edit_type: EDIT_ARTIST_EDITCREDIT_T,
}>;

declare type EditBarcodesEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +client_version: string | null,
    +submissions: ReadonlyArray<{
      +new_barcode: string | null,
      +old_barcode?: string | null,
      +release: ReleaseT,
    }>,
  },
  +edit_type: EDIT_RELEASE_EDIT_BARCODES_T,
}>;

declare type EditCoverArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: ReleaseArtT,
    +comment: CompT<string | null>,
    +release: ReleaseT,
    +types: CompT<ReadonlyArray<CoverArtTypeT>>,
  },
  +edit_type: EDIT_RELEASE_EDIT_COVER_ART_T,
}>;

declare type EditEventArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: EventArtT,
    +comment: CompT<string | null>,
    +event: EventT,
    +types: CompT<ReadonlyArray<EventArtTypeT>>,
  },
  +edit_type: EDIT_EVENT_EDIT_EVENT_ART_T,
}>;

declare type EditEventEditT = Readonly<{
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

declare type EditGenreEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +comment?: CompT<string | null>,
    +genre: GenreT,
    +name?: CompT<string>,
  },
  +edit_type: EDIT_GENRE_EDIT_T,
}>;

declare type EditInstrumentEditT = Readonly<{
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

declare type EditLabelEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +area?: CompT<AreaT | null>,
    +begin_date?: CompT<PartialDateT>,
    +comment?: CompT<string | null>,
    +end_date?: CompT<PartialDateT>,
    +ended?: CompT<boolean>,
    +ipi_codes?: CompT<ReadonlyArray<string> | null>,
    +isni_codes?: CompT<ReadonlyArray<string> | null>,
    +label: LabelT,
    +label_code?: CompT<number>,
    +name?: CompT<string>,
    +sort_name?: CompT<string>,
    +type?: CompT<LabelTypeT | null>,
  },
  +edit_type: EDIT_LABEL_EDIT_T,
}>;

declare type EditMediumEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit_changes?: ReadonlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT>,
    +changed_mbids: boolean,
    +data_track_changes: boolean,
    +format?: CompT<MediumFormatT | null>,
    +medium: MediumT,
    +name?: CompT<string>,
    +position?: CompT<number | string>,
    +recording_changes?: ReadonlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT>,
    +tracklist_changes?: ReadonlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT
      | TracklistChangesRemoveT>,
  },
  +edit_type: EDIT_MEDIUM_EDIT_T,
}>;

declare type EditPlaceEditT = Readonly<{
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

declare type EditRecordingEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +comment?: CompT<string | null>,
    +entered_from?: NonUrlRelatableEntityT,
    +length?: CompT<number | null>,
    +name?: CompT<string>,
    +recording: RecordingT,
    +video?: CompT<boolean>,
  },
}>;

declare type EditRecordingEditHistoricLengthT = Readonly<{
  ...EditRecordingEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_TRACK_LENGTH_T,
}>;

declare type EditRecordingEditHistoricNameT = Readonly<{
  ...EditRecordingEditGenericT,
  +edit_type: EDIT_HISTORIC_EDIT_TRACKNAME_T,
}>;

declare type EditRecordingEditCurrentT = Readonly<{
  ...EditRecordingEditGenericT,
  +edit_type: EDIT_RECORDING_EDIT_T,
}>;

declare type EditRecordingEditT =
  | EditRecordingEditHistoricLengthT
  | EditRecordingEditHistoricNameT
  | EditRecordingEditCurrentT;

declare type EditRelationshipEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entered_from?: NonUrlRelatableEntityT,
    +new: RelationshipT,
    +old: RelationshipT,
    +unknown_attributes: boolean,
  },
  +edit_type: EDIT_RELATIONSHIP_EDIT_T,
}>;

declare type EditRelationshipAttributeEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +attribute_type: LinkAttrTypeT | null,
    +child_order?: CompT<number>,
    +creditable?: CompT<boolean>,
    +description?: CompT<string | null>,
    +free_text?: CompT<boolean>,
    +name?: CompT<string>,
    +original_description: string | null,
    +original_name: string,
    +parent?: CompT<LinkAttrTypeT | null>,
  },
  + edit_type: EDIT_RELATIONSHIP_ATTRIBUTE_T,
}>;

declare type EditRelationshipTypeEditDisplayAttributeT = {
  ...LinkTypeAttrTypeT,
  +typeName: string,
};

declare type EditRelationshipTypeEditDisplayExampleT = {
  +name: string,
  +relationship: RelationshipT,
};

declare type EditRelationshipTypeEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +attributes: CompT<
      ReadonlyArray<EditRelationshipTypeEditDisplayAttributeT>>,
    +child_order: CompT<number>,
    +description?: CompT<string | null>,
    +documentation: CompT<string | null>,
    +entity0_cardinality?: CompT<number>,
    +entity1_cardinality?: CompT<number>,
    +examples: CompT<
      ReadonlyArray<EditRelationshipTypeEditDisplayExampleT>>,
    +has_dates: CompT<boolean>,
    +is_deprecated: CompT<boolean>,
    +link_phrase?: CompT<string>,
    +long_link_phrase?: CompT<string>,
    +name: CompT<string>,
    +orderable_direction?: CompT<OrderableDirectionT>,
    +parent?: CompT<LinkTypeT | null>,
    +relationship_type: LinkTypeT,
    +reverse_link_phrase: CompT<string>,
  },
  +edit_type: EDIT_RELATIONSHIP_EDIT_LINK_TYPE_T,
}>;

declare type EditReleaseEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +barcode?: CompT<string | null>,
    +comment?: CompT<string | null>,
    +events?: CompT<ReadonlyArray<ReleaseEventT>>,
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

declare type EditReleaseEditHistoricArtistT = Readonly<{
  ...EditReleaseEditGenericT,
  +edit_type: EDIT_RELEASE_ARTIST_T,
}>;

declare type EditReleaseEditCurrentT = Readonly<{
  ...EditReleaseEditGenericT,
  +edit_type: EDIT_RELEASE_EDIT_T,
}>;

declare type EditReleaseEditT =
  | EditReleaseEditHistoricArtistT
  | EditReleaseEditCurrentT;

declare type EditReleaseGroupEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artist_credit?: CompT<ArtistCreditT>,
    +comment?: CompT<string | null>,
    +entered_from?: NonUrlRelatableEntityT,
    +name?: CompT<string>,
    +release_group: ReleaseGroupT,
    +secondary_types: CompT<string>,
    +type?: CompT<ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null>,
  },
  +edit_type: EDIT_RELEASEGROUP_EDIT_T,
}>;

declare type EditReleaseLabelEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +barcode: string | null,
    +catalog_number: {
      +new?: string | null,
      +old: string | null,
    },
    +combined_format?: string,
    +events: ReadonlyArray<ReleaseEventT>,
    +label: {
      +new?: LabelT | null,
      +old: LabelT | null,
    },
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_EDITRELEASELABEL_T,
}>;

declare type EditSeriesEditT = Readonly<{
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

declare type EditUrlEditT = Readonly<{
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

declare type EditWorkEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +attributes?: {
      +[attributeName: string]: CompT<ReadonlyArray<string>>,
    },
    +comment?: CompT<string | null>,
    +iswc?: CompT<string | null>,
    +languages?: CompT<ReadonlyArray<LanguageT>>,
    +name?: CompT<string>,
    +type?: CompT<WorkTypeT | null>,
    +work: WorkT,
  },
  +edit_type: EDIT_WORK_EDIT_T,
}>;

declare type MergeAreasEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: AreaT,
    +old: ReadonlyArray<AreaT>,
  },
  +edit_type: EDIT_AREA_MERGE_T,
}>;

declare type MergeArtistsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: ArtistT,
    +old: ReadonlyArray<ArtistT>,
    +rename: boolean,
  },
  +edit_type: EDIT_ARTIST_MERGE_T,
}>;

declare type MergeEventsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: EventT,
    +old: ReadonlyArray<EventT>,
  },
  +edit_type: EDIT_EVENT_MERGE_T,
}>;

declare type MergeInstrumentsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: InstrumentT,
    +old: ReadonlyArray<InstrumentT>,
  },
  +edit_type: EDIT_INSTRUMENT_MERGE_T,
}>;

declare type MergeLabelsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: LabelT,
    +old: ReadonlyArray<LabelT>,
  },
  +edit_type: EDIT_LABEL_MERGE_T,
}>;

declare type MergePlacesEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: PlaceT,
    +old: ReadonlyArray<PlaceT>,
  },
  +edit_type: EDIT_PLACE_MERGE_T,
}>;

declare type MergeRecordingsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +large_spread: boolean,
    +new: RecordingT,
    +old: ReadonlyArray<RecordingT>,
  },
  +edit_type: EDIT_RECORDING_MERGE_T,
}>;

declare type MergeReleaseGroupsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: ReleaseGroupT,
    +old: ReadonlyArray<ReleaseGroupT>,
  },
  +edit_type: EDIT_RELEASEGROUP_MERGE_T,
}>;

declare type MergeReleaseEditDisplayChangeT = {
  +mediums: ReadonlyArray<{
    +id: number,
    +new_name: string,
    +new_position: number,
    +old_name: string,
    +old_position: StrOrNum,
  }>,
  +release: ReleaseT,
};

declare type MergeReleaseEditDisplayRecordingMergeT = {
  +destination: RecordingT,
  +large_spread: boolean,
  +medium: string,
  +sources: ReadonlyArray<RecordingT>,
  +track: string,
};

declare type MergeReleasesEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +cannot_merge_recordings_reason?: {
      +message: string,
      +vars: {+[var: string]: string, ...},
    },
    +changes: ReadonlyArray<MergeReleaseEditDisplayChangeT>,
    +edit_version: 1 | 2 | 3,
    +empty_releases?: ReadonlyArray<ReleaseT>,
    +merge_strategy: 'append' | 'merge',
    +new: ReleaseT,
    +old: ReadonlyArray<ReleaseT>,
    +recording_merges?:
      ReadonlyArray<MergeReleaseEditDisplayRecordingMergeT>,
  },
  +edit_type: EDIT_RELEASE_MERGE_T,
}>;

declare type MergeSeriesEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: SeriesT,
    +old: ReadonlyArray<SeriesT>,
  },
  +edit_type: EDIT_SERIES_MERGE_T,
}>;

declare type MergeWorksEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: WorkT,
    +old: ReadonlyArray<WorkT>,
  },
  +edit_type: EDIT_WORK_MERGE_T,
}>;

declare type MoveDiscIdEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +medium_cdtoc: MediumCDTocT,
    +new_medium: MediumT,
    +old_medium: MediumT,
  },
  +edit_type: EDIT_MEDIUM_MOVE_DISCID_T,
}>;

declare type RemoveCoverArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: ReleaseArtT,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_REMOVE_COVER_ART_T,
}>;

declare type RemoveDiscIdEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT,
    +medium: MediumT,
  },
  +edit_type: EDIT_MEDIUM_REMOVE_DISCID_T,
}>;

declare type RemoveAreaEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: AreaT,
    +entity_type: 'area',
  },
  +edit_type: EDIT_AREA_DELETE_T,
}>;

declare type RemoveArtistEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: ArtistT,
    +entity_type: 'artist',
  },
  +edit_type: EDIT_ARTIST_DELETE_T,
}>;

declare type RemoveEventArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: EventArtT,
    +event: EventT,
  },
  +edit_type: EDIT_EVENT_REMOVE_EVENT_ART_T,
}>;

declare type RemoveEventEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: EventT,
    +entity_type: 'event',
  },
  +edit_type: EDIT_EVENT_DELETE_T,
}>;

declare type RemoveGenreEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: GenreT,
    +entity_type: 'genre',
  },
  +edit_type: EDIT_GENRE_DELETE_T,
}>;

declare type RemoveInstrumentEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: InstrumentT,
    +entity_type: 'instrument',
  },
  +edit_type: EDIT_INSTRUMENT_DELETE_T,
}>;

declare type RemoveLabelEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: LabelT,
    +entity_type: 'label',
  },
  +edit_type: EDIT_LABEL_DELETE_T,
}>;

declare type RemovePlaceEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: PlaceT,
    +entity_type: 'place',
  },
  +edit_type: EDIT_PLACE_DELETE_T,
}>;

declare type RemoveRecordingEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: RecordingT,
    +entity_type: 'recording',
  },
  +edit_type: EDIT_RECORDING_DELETE_T,
}>;

declare type RemoveReleaseGroupEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: ReleaseGroupT,
    +entity_type: 'release_group',
  },
  +edit_type: EDIT_RELEASEGROUP_DELETE_T,
}>;

declare type RemoveReleaseEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: ReleaseT,
    +entity_type: 'release',
  },
  +edit_type: EDIT_RELEASE_DELETE_T,
}>;

declare type RemoveSeriesEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entity: SeriesT,
    +entity_type: 'series',
  },
  +edit_type: EDIT_SERIES_DELETE_T,
}>;

declare type RemoveWorkEditT = Readonly<{
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
  | RemovePlaceEditT
  | RemoveRecordingEditT
  | RemoveReleaseGroupEditT
  | RemoveReleaseEditT
  | RemoveSeriesEditT
  | RemoveWorkEditT;

declare type RemoveIsrcEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +isrc: IsrcT,
  },
  +edit_type: EDIT_RECORDING_REMOVE_ISRC_T,
}>;

declare type RemoveIswcEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +iswc: IswcT,
  },
  +edit_type: EDIT_WORK_REMOVE_ISWC_T,
}>;

declare type RemoveMediumEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +medium: MediumT,
    +tracks?: ReadonlyArray<TrackT>,
  },
  +edit_type: EDIT_MEDIUM_DELETE_T,
}>;

declare type RemoveRelationshipEditT = Readonly<{
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
        +attributes?: ReadonlyArray<{
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
    +entered_from?: NonUrlRelatableEntityT,
    +relationship: RelationshipT,
  },
  +edit_type: EDIT_RELATIONSHIP_DELETE_T,
}>;

declare type RemoveRelationshipAttributeEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +description: string | null,
    +name: string,
  },
  +edit_type: EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE_T,
}>;

declare type RemoveRelationshipTypeEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +attributes: ReadonlyArray<{
      ...LinkTypeAttrTypeT,
      +typeName: string,
    }>,
    +description: string | null,
    +entity0_type: RelatableEntityTypeT,
    +entity1_type: RelatableEntityTypeT,
    +link_phrase: string,
    +long_link_phrase: string,
    +name: string,
    +reverse_link_phrase: string,
  },
  +edit_type: EDIT_RELATIONSHIP_REMOVE_LINK_TYPE_T,
}>;

declare type RemoveReleaseLabelEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +catalog_number: string,
    +label?: LabelT,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_DELETERELEASELABEL_T,
}>;

declare type ReorderCoverArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +new: ReadonlyArray<ReleaseArtT>,
    +old: ReadonlyArray<ReleaseArtT>,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_REORDER_COVER_ART_T,
}>;

declare type ReorderEventArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +event: EventT,
    +new: ReadonlyArray<EventArtT>,
    +old: ReadonlyArray<EventArtT>,
  },
  +edit_type: EDIT_EVENT_REORDER_EVENT_ART_T,
}>;

declare type ReorderMediumsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +mediums: ReadonlyArray<{
      +new: number,
      +old: 'new' | number,
      +title: string,
    }>,
    +release: ReleaseT,
  },
  +edit_type: EDIT_RELEASE_REORDER_MEDIUMS_T,
}>;

declare type ReorderRelationshipsEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +entered_from?: NonUrlRelatableEntityT,
    +relationships: ReadonlyArray<{
      +new_order: number,
      +old_order: number,
      +relationship: RelationshipT,
    }>,
  },
  +edit_type: EDIT_RELATIONSHIPS_REORDER_T,
}>;

declare type SetCoverArtEditT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +artwork: CompT<ReleaseArtT>,
    +isOldArtworkAutomatic: boolean,
    +release_group: ReleaseGroupT,
  },
  +edit_type: EDIT_RELEASEGROUP_SET_COVER_ART_T,
}>;

declare type SetTrackLengthsEditGenericT = Readonly<{
  ...GenericEditT,
  +display_data: {
    +cdtoc: CDTocT | null,
    +length: CompT<ReadonlyArray<number | null>>,
    +medium?: MediumT,
    +releases: ReadonlyArray<ReleaseT>,
  },
}>;

declare type SetTrackLengthsEditHistoricT = Readonly<{
  ...SetTrackLengthsEditGenericT,
  +edit_type: EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC_T,
}>;

declare type SetTrackLengthsEditStandardT = Readonly<{
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
  | AddEventArtEditT
  | AddEventEditT
  | AddGenreEditT
  | AddInstrumentEditT
  | AddIsrcsEditT
  | AddIswcsEditT
  | AddLabelEditT
  | AddMediumEditT
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
  | EditEventArtEditT
  | EditEventEditT
  | EditGenreEditT
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
  | RemoveEventArtEditT
  | RemoveEntityEditT
  | RemoveIsrcEditT
  | RemoveIswcEditT
  | RemoveMediumEditT
  | RemoveRelationshipEditT
  | RemoveRelationshipAttributeEditT
  | RemoveRelationshipTypeEditT
  | RemoveReleaseLabelEditT
  | ReorderCoverArtEditT
  | ReorderEventArtEditT
  | ReorderMediumsEditT
  | ReorderRelationshipsEditT
  | SetCoverArtEditT
  | SetTrackLengthsEditT;
