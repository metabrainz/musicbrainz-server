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
  readonly display_data: {
    readonly changelog: string,
    readonly entity_type: AnnotatedEntityTypeT,
    [annotatedEntityType: AnnotatedEntityTypeT]: AnnotatedEntityT,
    readonly html: string,
    readonly old_annotation?: string,
    readonly text: string,
  },
  readonly edit_type: EDIT_AREA_ADD_ANNOTATION_T,
}>;

declare type AddAreaAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_AREA_ADD_ANNOTATION_T,
}>;

declare type AddArtistAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_ARTIST_ADD_ANNOTATION_T,
}>;

declare type AddEventAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_EVENT_ADD_ANNOTATION_T,
}>;

declare type AddGenreAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_GENRE_ADD_ANNOTATION_T,
}>;

declare type AddInstrumentAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_INSTRUMENT_ADD_ANNOTATION_T,
}>;

declare type AddLabelAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_LABEL_ADD_ANNOTATION_T,
}>;

declare type AddPlaceAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_PLACE_ADD_ANNOTATION_T,
}>;

declare type AddRecordingAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_RECORDING_ADD_ANNOTATION_T,
}>;

declare type AddReleaseGroupAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_RELEASEGROUP_ADD_ANNOTATION_T,
}>;

declare type AddReleaseAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_RELEASE_ADD_ANNOTATION_T,
}>;

declare type AddSeriesAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_SERIES_ADD_ANNOTATION_T,
}>;

declare type AddWorkAnnotationEditT = Readonly<{
  ...AddAnnotationEditGenericT,
  readonly edit_type: EDIT_WORK_ADD_ANNOTATION_T,
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
  readonly display_data: {
    ...DatePeriodRoleT,
    readonly area: AreaT,
    readonly comment: string | null,
    readonly iso_3166_1: ReadonlyArray<string>,
    readonly iso_3166_2: ReadonlyArray<string>,
    readonly iso_3166_3: ReadonlyArray<string>,
    readonly name: string,
    readonly sort_name: string | null,
    readonly type: AreaTypeT | null,
  },
  readonly edit_type: EDIT_AREA_CREATE_T,
}>;

declare type AddArtistEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    ...CommentRoleT,
    ...DatePeriodRoleT,
    readonly area: AreaT | null,
    readonly artist: ArtistT,
    readonly begin_area: AreaT | null,
    readonly end_area: AreaT | null,
    readonly gender: GenderT | null,
    readonly ipi_codes: ReadonlyArray<string> | null,
    readonly isni_codes: ReadonlyArray<string> | null,
    readonly name: string,
    readonly sort_name: string,
    readonly type: ArtistTypeT | null,
  },
  readonly edit_type: EDIT_ARTIST_CREATE_T,
}>;

declare type AddCoverArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: ReleaseArtT,
    readonly position: number,
    readonly release: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_ADD_COVER_ART_T,
}>;

declare type AddDiscIdEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly medium?: MediumT,
    readonly medium_cdtoc: MediumCDTocT,
  },
  readonly edit_type: EDIT_MEDIUM_ADD_DISCID_T,
}>;

declare type AddEventArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: EventArtT,
    readonly event: EventT,
    readonly position: number,
  },
  readonly edit_type: EDIT_EVENT_ADD_EVENT_ART_T,
}>;

declare type AddEventEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    ...CommentRoleT,
    ...DatePeriodRoleT,
    readonly cancelled: boolean,
    readonly ended: boolean,
    readonly event: EventT,
    readonly name: string,
    readonly setlist: string,
    readonly time: string | null,
    readonly type: EventTypeT | null,
  },
  readonly edit_type: EDIT_EVENT_CREATE_T,
}>;

declare type AddGenreEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    ...CommentRoleT,
    readonly genre: GenreT,
    readonly name: string,
  },
  readonly edit_type: EDIT_GENRE_CREATE_T,
}>;

declare type AddInstrumentEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    ...DatePeriodRoleT,
    readonly comment: string | null,
    readonly description: string | null,
    readonly instrument: InstrumentT,
    readonly name: string,
    readonly type: InstrumentTypeT | null,
  },
  readonly edit_type: EDIT_INSTRUMENT_CREATE_T,
}>;

declare type AddIsrcsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly additions: ReadonlyArray<{
      readonly isrc: IsrcT,
      readonly recording: RecordingT,
    }>,
    readonly client_version?: string,
  },
  readonly edit_type: EDIT_RECORDING_ADD_ISRCS_T,
}>;

declare type AddIswcsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly additions: ReadonlyArray<{
      readonly iswc: IswcT,
      readonly work: WorkT,
    }>,
  },
  readonly edit_type: EDIT_WORK_ADD_ISWCS_T,
}>;

declare type AddLabelEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly area: AreaT,
    readonly begin_date: PartialDateT,
    readonly comment: string,
    readonly end_date: PartialDateT,
    readonly ended: boolean,
    readonly ipi_codes: ReadonlyArray<string> | null,
    readonly isni_codes: ReadonlyArray<string> | null,
    readonly label: LabelT,
    readonly label_code: number | null,
    readonly name: string,
    readonly sort_name: string,
    readonly type: LabelTypeT | null,
  },
  readonly edit_type: EDIT_LABEL_CREATE_T,
}>;

declare type AddMediumEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly format: MediumFormatT | null,
    readonly name?: string,
    readonly position: number | string,
    readonly release?: ReleaseT,
    readonly tracks?: ReadonlyArray<TrackT>,
  },
  readonly edit_type: EDIT_MEDIUM_CREATE_T,
}>;

declare type AddPlaceEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    ...DatePeriodRoleT,
    readonly address: string | null,
    readonly area: AreaT,
    readonly comment: string | null,
    readonly coordinates: CoordinatesT | null,
    readonly name?: string,
    readonly place: PlaceT,
    readonly type: PlaceTypeT | null,
  },
  readonly edit_type: EDIT_PLACE_CREATE_T,
}>;

declare type AddRelationshipEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entered_from?: NonUrlRelatableEntityT,
    readonly relationship: RelationshipT,
    readonly unknown_attributes: boolean,
  },
  readonly edit_type: EDIT_RELATIONSHIP_CREATE_T,
}>;

declare type AddRelationshipAttributeEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly child_order: number,
    readonly creditable: boolean,
    readonly description: string | null,
    readonly free_text: boolean,
    readonly name: string,
    readonly parent?: LinkAttrTypeT,
  },
  readonly edit_type: EDIT_RELATIONSHIP_ADD_ATTRIBUTE_T,
}>;

declare type AddRelationshipTypeEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly attributes: ReadonlyArray<{
      ...LinkTypeAttrTypeT,
      readonly typeName: string,
    }>,
    readonly child_order: number,
    readonly description: string | null,
    readonly documentation: string | null,
    readonly entity0_cardinality?: number,
    readonly entity0_type: RelatableEntityTypeT,
    readonly entity1_cardinality?: number,
    readonly entity1_type: RelatableEntityTypeT,
    readonly link_phrase: string,
    readonly long_link_phrase: string,
    readonly name: string,
    readonly orderable_direction?: OrderableDirectionT,
    readonly relationship_type?: LinkTypeT,
    readonly reverse_link_phrase: string,
  },
  readonly edit_type: EDIT_RELATIONSHIP_ADD_TYPE_T,
}>;

declare type AddReleaseEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit: ArtistCreditT,
    readonly barcode: string | null,
    readonly comment: string,
    readonly events?: ReadonlyArray<ReleaseEventT>,
    readonly language: LanguageT | null,
    readonly name: string,
    readonly packaging: ReleasePackagingT | null,
    readonly release: ReleaseT,
    readonly release_group: ReleaseGroupT,
    readonly script: ScriptT | null,
    readonly status: ReleaseStatusT | null,
  },
  readonly edit_type: EDIT_RELEASE_CREATE_T,
}>;

declare type AddReleaseGroupEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit: ArtistCreditT,
    readonly comment: string,
    readonly name: string,
    readonly release_group: ReleaseGroupT,
    readonly secondary_types: string,
    readonly type: ReleaseGroupTypeT | ReleaseGroupHistoricTypeT | null,
  },
  readonly edit_type: EDIT_RELEASEGROUP_CREATE_T,
}>;

declare type AddReleaseLabelEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly catalog_number: string,
    readonly label?: LabelT,
    readonly release?: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_ADDRELEASELABEL_T,
}>;

declare type AddRemoveAliasEditGenericT<out T> = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly [coreEntityType: EntityWithAliasesTypeT]: EntityWithAliasesT,
    readonly alias: string,
    readonly begin_date: PartialDateT,
    readonly end_date: PartialDateT,
    readonly ended?: boolean,
    readonly entity_type: EntityWithAliasesTypeT,
    readonly locale: string | null,
    readonly primary_for_locale: boolean,
    readonly sort_name: string | null,
    readonly type: T | null,
  },
}>;

declare type AddAreaAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<AreaAliasTypeT>,
  readonly edit_type: EDIT_AREA_ADD_ALIAS_T,
}>;

declare type AddArtistAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ArtistAliasTypeT>,
  readonly edit_type: EDIT_ARTIST_ADD_ALIAS_T,
}>;

declare type AddEventAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<EventAliasTypeT>,
  readonly edit_type: EDIT_EVENT_ADD_ALIAS_T,
}>;

declare type AddGenreAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<GenreAliasTypeT>,
  readonly edit_type: EDIT_GENRE_ADD_ALIAS_T,
}>;

declare type AddInstrumentAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<InstrumentAliasTypeT>,
  readonly edit_type: EDIT_INSTRUMENT_ADD_ALIAS_T,
}>;

declare type AddLabelAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<LabelAliasTypeT>,
  readonly edit_type: EDIT_LABEL_ADD_ALIAS_T,
}>;

declare type AddPlaceAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<PlaceAliasTypeT>,
  readonly edit_type: EDIT_PLACE_ADD_ALIAS_T,
}>;

declare type AddRecordingAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<RecordingAliasTypeT>,
  readonly edit_type: EDIT_RECORDING_ADD_ALIAS_T,
}>;

declare type AddReleaseGroupAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseGroupAliasTypeT>,
  readonly edit_type: EDIT_RELEASEGROUP_ADD_ALIAS_T,
}>;

declare type AddReleaseAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseAliasTypeT>,
  readonly edit_type: EDIT_RELEASE_ADD_ALIAS_T,
}>;

declare type AddSeriesAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<SeriesAliasTypeT>,
  readonly edit_type: EDIT_SERIES_ADD_ALIAS_T,
}>;

declare type AddWorkAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<WorkAliasTypeT>,
  readonly edit_type: EDIT_WORK_ADD_ALIAS_T,
}>;

declare type RemoveAreaAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<AreaAliasTypeT>,
  readonly edit_type: EDIT_AREA_DELETE_ALIAS_T,
}>;

declare type RemoveArtistAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ArtistAliasTypeT>,
  readonly edit_type: EDIT_ARTIST_DELETE_ALIAS_T,
}>;

declare type RemoveEventAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<EventAliasTypeT>,
  readonly edit_type: EDIT_EVENT_DELETE_ALIAS_T,
}>;

declare type RemoveGenreAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<GenreAliasTypeT>,
  readonly edit_type: EDIT_GENRE_DELETE_ALIAS_T,
}>;

declare type RemoveInstrumentAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<InstrumentAliasTypeT>,
  readonly edit_type: EDIT_INSTRUMENT_DELETE_ALIAS_T,
}>;

declare type RemoveLabelAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<LabelAliasTypeT>,
  readonly edit_type: EDIT_LABEL_DELETE_ALIAS_T,
}>;

declare type RemovePlaceAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<PlaceAliasTypeT>,
  readonly edit_type: EDIT_PLACE_DELETE_ALIAS_T,
}>;

declare type RemoveRecordingAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<RecordingAliasTypeT>,
  readonly edit_type: EDIT_RECORDING_DELETE_ALIAS_T,
}>;

declare type RemoveReleaseGroupAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseGroupAliasTypeT>,
  readonly edit_type: EDIT_RELEASEGROUP_DELETE_ALIAS_T,
}>;

declare type RemoveReleaseAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<ReleaseAliasTypeT>,
  readonly edit_type: EDIT_RELEASE_DELETE_ALIAS_T,
}>;

declare type RemoveSeriesAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<SeriesAliasTypeT>,
  readonly edit_type: EDIT_SERIES_DELETE_ALIAS_T,
}>;

declare type RemoveWorkAliasEditT = Readonly<{
  ...AddRemoveAliasEditGenericT<WorkAliasTypeT>,
  readonly edit_type: EDIT_WORK_DELETE_ALIAS_T,
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
  readonly display_data: {
    readonly comment: string,
    readonly name: string,
    readonly ordering_type: SeriesOrderingTypeT | null,
    readonly series: SeriesT,
    readonly type: SeriesTypeT | null,
  },
  readonly edit_type: EDIT_SERIES_CREATE_T,
}>;

declare type AddStandaloneRecordingEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit: ArtistCreditT,
    readonly comment: string | null,
    readonly length: number | null,
    readonly name: string,
    readonly recording: RecordingT,
    readonly video: boolean,
  },
  readonly edit_type: EDIT_RECORDING_CREATE_T,
}>;

declare type AddWorkEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly attributes?: {
      [attributeName: string]: ReadonlyArray<WorkAttributeT>,
    },
    readonly comment: string,
    readonly iswc: string,
    readonly language?: LanguageT,
    readonly languages?: ReadonlyArray<LanguageT>,
    readonly name: string,
    readonly type: WorkTypeT | null,
    readonly work: WorkT,
  },
  edit_type: EDIT_WORK_CREATE_T,
}>;

declare type ChangeReleaseQualityEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly quality: CompT<QualityT>,
    readonly release: ReleaseT,
  },
  edit_type: EDIT_RELEASE_CHANGE_QUALITY_T,
}>;

declare type ChangeWikiDocEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new_version: number | null,
    readonly old_version: number | null,
    readonly page: string,
  },
  readonly edit_type: EDIT_WIKIDOC_CHANGE_T,
}>;

declare type EditAliasEditGenericT<out A, out T> = Readonly<{
  ...GenericEditT,
  readonly alias: A | null,
  readonly display_data: {
    readonly [coreEntityType: EntityWithAliasesTypeT]: EntityWithAliasesT,
    readonly alias: CompT<string>,
    readonly begin_date: CompT<PartialDateT>,
    readonly end_date: CompT<PartialDateT>,
    readonly ended: CompT<boolean>,
    readonly entity_type: EntityWithAliasesTypeT,
    readonly locale: CompT<string | null>,
    readonly primary_for_locale: CompT<boolean>,
    readonly sort_name: CompT<string>,
    readonly type: CompT<T | null>,
  },
}>;

declare type EditAreaAliasEditT = Readonly<{
  ...EditAliasEditGenericT<AreaAliasT, AreaAliasTypeT>,
  readonly edit_type: EDIT_AREA_EDIT_ALIAS_T,
}>;

declare type EditArtistAliasEditT = Readonly<{
  ...EditAliasEditGenericT<ArtistAliasT, ArtistAliasTypeT>,
  readonly edit_type: EDIT_ARTIST_EDIT_ALIAS_T,
}>;

declare type EditEventAliasEditT = Readonly<{
  ...EditAliasEditGenericT<EventAliasT, EventAliasTypeT>,
  readonly edit_type: EDIT_EVENT_EDIT_ALIAS_T,
}>;

declare type EditGenreAliasEditT = Readonly<{
  ...EditAliasEditGenericT<GenreAliasT, GenreAliasTypeT>,
  readonly edit_type: EDIT_GENRE_EDIT_ALIAS_T,
}>;

declare type EditInstrumentAliasEditT = Readonly<{
  ...EditAliasEditGenericT<InstrumentAliasT, InstrumentAliasTypeT>,
  readonly edit_type: EDIT_INSTRUMENT_EDIT_ALIAS_T,
}>;

declare type EditLabelAliasEditT = Readonly<{
  ...EditAliasEditGenericT<LabelAliasT, LabelAliasTypeT>,
  readonly edit_type: EDIT_LABEL_EDIT_ALIAS_T,
}>;

declare type EditPlaceAliasEditT = Readonly<{
  ...EditAliasEditGenericT<PlaceAliasT, PlaceAliasTypeT>,
  readonly edit_type: EDIT_PLACE_EDIT_ALIAS_T,
}>;

declare type EditRecordingAliasEditT = Readonly<{
  ...EditAliasEditGenericT<RecordingAliasT, RecordingAliasTypeT>,
  readonly edit_type: EDIT_RECORDING_EDIT_ALIAS_T,
}>;

declare type EditReleaseGroupAliasEditT = Readonly<{
  ...EditAliasEditGenericT<ReleaseGroupAliasT, ReleaseGroupAliasTypeT>,
  readonly edit_type: EDIT_RELEASEGROUP_EDIT_ALIAS_T,
}>;

declare type EditReleaseAliasEditT = Readonly<{
  ...EditAliasEditGenericT<ReleaseAliasT, ReleaseAliasTypeT>,
  readonly edit_type: EDIT_RELEASE_EDIT_ALIAS_T,
}>;

declare type EditSeriesAliasEditT = Readonly<{
  ...EditAliasEditGenericT<SeriesAliasT, SeriesAliasTypeT>,
  readonly edit_type: EDIT_SERIES_EDIT_ALIAS_T,
}>;

declare type EditWorkAliasEditT = Readonly<{
  ...EditAliasEditGenericT<WorkAliasT, WorkAliasTypeT>,
  readonly edit_type: EDIT_WORK_EDIT_ALIAS_T,
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
  readonly display_data: {
    readonly area: AreaT,
    readonly begin_date?: CompT<PartialDateT>,
    readonly comment?: CompT<string | null>,
    readonly end_date?: CompT<PartialDateT>,
    readonly ended?: CompT<boolean>,
    readonly iso_3166_1?: CompT<ReadonlyArray<string> | null>,
    readonly iso_3166_2?: CompT<ReadonlyArray<string> | null>,
    readonly iso_3166_3?: CompT<ReadonlyArray<string> | null>,
    readonly name?: CompT<string>,
    readonly sort_name?: CompT<string>,
    readonly type?: CompT<AreaTypeT | null>,
  },
  readonly edit_type: EDIT_AREA_EDIT_T,
}>;

declare type EditArtistEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly area?: CompT<AreaT | null>,
    readonly artist: ArtistT,
    readonly begin_area?: CompT<AreaT | null>,
    readonly begin_date?: CompT<PartialDateT>,
    readonly comment?: CompT<string | null>,
    readonly end_area?: CompT<AreaT | null>,
    readonly end_date?: CompT<PartialDateT>,
    readonly ended?: CompT<boolean>,
    readonly gender?: CompT<GenderT | null>,
    readonly ipi_codes?: CompT<ReadonlyArray<string> | null>,
    readonly isni_codes?: CompT<ReadonlyArray<string> | null>,
    readonly name?: CompT<string>,
    readonly sort_name?: CompT<string>,
    readonly type?: CompT<ArtistTypeT | null>,
  },
  readonly edit_type: EDIT_ARTIST_EDIT_T,
}>;

declare type EditArtistCreditEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit: CompT<ArtistCreditT>,
  },
  readonly edit_type: EDIT_ARTIST_EDITCREDIT_T,
}>;

declare type EditBarcodesEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly client_version: string | null,
    readonly submissions: ReadonlyArray<{
      readonly new_barcode: string | null,
      readonly old_barcode?: string | null,
      readonly release: ReleaseT,
    }>,
  },
  readonly edit_type: EDIT_RELEASE_EDIT_BARCODES_T,
}>;

declare type EditCoverArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: ReleaseArtT,
    readonly comment: CompT<string | null>,
    readonly release: ReleaseT,
    readonly types: CompT<ReadonlyArray<CoverArtTypeT>>,
  },
  readonly edit_type: EDIT_RELEASE_EDIT_COVER_ART_T,
}>;

declare type EditEventArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: EventArtT,
    readonly comment: CompT<string | null>,
    readonly event: EventT,
    readonly types: CompT<ReadonlyArray<EventArtTypeT>>,
  },
  readonly edit_type: EDIT_EVENT_EDIT_EVENT_ART_T,
}>;

declare type EditEventEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly begin_date?: CompT<PartialDateT | null>,
    readonly cancelled?: CompT<boolean>,
    readonly comment?: CompT<string | null>,
    readonly end_date?: CompT<PartialDateT | null>,
    readonly event: EventT,
    readonly name?: CompT<string>,
    readonly setlist?: CompT<string | null>,
    readonly time?: CompT<string | null>,
    readonly type?: CompT<EventTypeT | null>,
  },
  readonly edit_type: EDIT_EVENT_EDIT_T,
}>;

declare type EditGenreEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly comment?: CompT<string | null>,
    readonly genre: GenreT,
    readonly name?: CompT<string>,
  },
  readonly edit_type: EDIT_GENRE_EDIT_T,
}>;

declare type EditInstrumentEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly comment?: CompT<string | null>,
    readonly description?: CompT<string | null>,
    readonly instrument: InstrumentT,
    readonly name?: CompT<string>,
    readonly type?: CompT<InstrumentTypeT | null>,
  },
  readonly edit_type: EDIT_INSTRUMENT_EDIT_T,
}>;

declare type EditLabelEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly area?: CompT<AreaT | null>,
    readonly begin_date?: CompT<PartialDateT>,
    readonly comment?: CompT<string | null>,
    readonly end_date?: CompT<PartialDateT>,
    readonly ended?: CompT<boolean>,
    readonly ipi_codes?: CompT<ReadonlyArray<string> | null>,
    readonly isni_codes?: CompT<ReadonlyArray<string> | null>,
    readonly label: LabelT,
    readonly label_code?: CompT<number>,
    readonly name?: CompT<string>,
    readonly sort_name?: CompT<string>,
    readonly type?: CompT<LabelTypeT | null>,
  },
  readonly edit_type: EDIT_LABEL_EDIT_T,
}>;

declare type EditMediumEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit_changes?: ReadonlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT>,
    readonly changed_mbids: boolean,
    readonly data_track_changes: boolean,
    readonly format?: CompT<MediumFormatT | null>,
    readonly medium: MediumT,
    readonly name?: CompT<string>,
    readonly position?: CompT<number | string>,
    readonly recording_changes?: ReadonlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT>,
    readonly tracklist_changes?: ReadonlyArray<
      | TracklistChangesAddT
      | TracklistChangesChangeT
      | TracklistChangesRemoveT>,
  },
  readonly edit_type: EDIT_MEDIUM_EDIT_T,
}>;

declare type EditPlaceEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly address?: CompT<string>,
    readonly area?: CompT<AreaT | null>,
    readonly begin_date?: CompT<PartialDateT>,
    readonly comment?: CompT<string>,
    readonly coordinates?: CompT<CoordinatesT | null>,
    readonly end_date?: CompT<PartialDateT>,
    readonly ended?: CompT<boolean>,
    readonly name: CompT<string>,
    readonly place: PlaceT,
    readonly type?: CompT<PlaceTypeT | null>,
  },
  readonly edit_type: EDIT_PLACE_EDIT_T,
}>;

declare type EditRecordingEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit?: CompT<ArtistCreditT>,
    readonly comment?: CompT<string | null>,
    readonly entered_from?: NonUrlRelatableEntityT,
    readonly length?: CompT<number | null>,
    readonly name?: CompT<string>,
    readonly recording: RecordingT,
    readonly video?: CompT<boolean>,
  },
}>;

declare type EditRecordingEditHistoricLengthT = Readonly<{
  ...EditRecordingEditGenericT,
  readonly edit_type: EDIT_HISTORIC_EDIT_TRACK_LENGTH_T,
}>;

declare type EditRecordingEditHistoricNameT = Readonly<{
  ...EditRecordingEditGenericT,
  readonly edit_type: EDIT_HISTORIC_EDIT_TRACKNAME_T,
}>;

declare type EditRecordingEditCurrentT = Readonly<{
  ...EditRecordingEditGenericT,
  readonly edit_type: EDIT_RECORDING_EDIT_T,
}>;

declare type EditRecordingEditT =
  | EditRecordingEditHistoricLengthT
  | EditRecordingEditHistoricNameT
  | EditRecordingEditCurrentT;

declare type EditRelationshipEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entered_from?: NonUrlRelatableEntityT,
    readonly new: RelationshipT,
    readonly old: RelationshipT,
    readonly unknown_attributes: boolean,
  },
  readonly edit_type: EDIT_RELATIONSHIP_EDIT_T,
}>;

declare type EditRelationshipAttributeEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly attribute_type: LinkAttrTypeT | null,
    readonly child_order?: CompT<number>,
    readonly creditable?: CompT<boolean>,
    readonly description?: CompT<string | null>,
    readonly free_text?: CompT<boolean>,
    readonly name?: CompT<string>,
    readonly original_description: string | null,
    readonly original_name: string,
    readonly parent?: CompT<LinkAttrTypeT | null>,
  },
  + edit_type: EDIT_RELATIONSHIP_ATTRIBUTE_T,
}>;

declare type EditRelationshipTypeEditDisplayAttributeT = {
  ...LinkTypeAttrTypeT,
  readonly typeName: string,
};

declare type EditRelationshipTypeEditDisplayExampleT = {
  readonly name: string,
  readonly relationship: RelationshipT,
};

declare type EditRelationshipTypeEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly attributes: CompT<
      ReadonlyArray<EditRelationshipTypeEditDisplayAttributeT>>,
    readonly child_order: CompT<number>,
    readonly description?: CompT<string | null>,
    readonly documentation: CompT<string | null>,
    readonly entity0_cardinality?: CompT<number>,
    readonly entity1_cardinality?: CompT<number>,
    readonly examples: CompT<
      ReadonlyArray<EditRelationshipTypeEditDisplayExampleT>>,
    readonly has_dates: CompT<boolean>,
    readonly is_deprecated: CompT<boolean>,
    readonly link_phrase?: CompT<string>,
    readonly long_link_phrase?: CompT<string>,
    readonly name: CompT<string>,
    readonly orderable_direction?: CompT<OrderableDirectionT>,
    readonly parent?: CompT<LinkTypeT | null>,
    readonly relationship_type: LinkTypeT,
    readonly reverse_link_phrase: CompT<string>,
  },
  readonly edit_type: EDIT_RELATIONSHIP_EDIT_LINK_TYPE_T,
}>;

declare type EditReleaseEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit?: CompT<ArtistCreditT>,
    readonly barcode?: CompT<string | null>,
    readonly comment?: CompT<string | null>,
    readonly events?: CompT<ReadonlyArray<ReleaseEventT>>,
    readonly language?: CompT<LanguageT | null>,
    readonly name?: CompT<string>,
    readonly packaging?: CompT<ReleasePackagingT | null>,
    readonly release: ReleaseT,
    readonly release_group?: CompT<ReleaseGroupT>,
    readonly script?: CompT<ScriptT | null>,
    readonly status?: CompT<ReleaseStatusT | null>,
    readonly update_tracklists?: boolean,
  },
}>;

declare type EditReleaseEditHistoricArtistT = Readonly<{
  ...EditReleaseEditGenericT,
  readonly edit_type: EDIT_RELEASE_ARTIST_T,
}>;

declare type EditReleaseEditCurrentT = Readonly<{
  ...EditReleaseEditGenericT,
  readonly edit_type: EDIT_RELEASE_EDIT_T,
}>;

declare type EditReleaseEditT =
  | EditReleaseEditHistoricArtistT
  | EditReleaseEditCurrentT;

declare type EditReleaseGroupEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artist_credit?: CompT<ArtistCreditT>,
    readonly comment?: CompT<string | null>,
    readonly entered_from?: NonUrlRelatableEntityT,
    readonly name?: CompT<string>,
    readonly release_group: ReleaseGroupT,
    readonly secondary_types: CompT<string>,
    readonly type?: CompT<
      | ReleaseGroupTypeT
      | ReleaseGroupHistoricTypeT
      | null
    >,
  },
  readonly edit_type: EDIT_RELEASEGROUP_EDIT_T,
}>;

declare type EditReleaseLabelEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly barcode: string | null,
    readonly catalog_number: {
      readonly new?: string | null,
      readonly old: string | null,
    },
    readonly combined_format?: string,
    readonly events: ReadonlyArray<ReleaseEventT>,
    readonly label: {
      readonly new?: LabelT | null,
      readonly old: LabelT | null,
    },
    readonly release: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_EDITRELEASELABEL_T,
}>;

declare type EditSeriesEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly comment?: CompT<string>,
    readonly name?: CompT<string>,
    readonly ordering_type?: CompT<SeriesOrderingTypeT>,
    readonly series: SeriesT,
    readonly type?: CompT<SeriesTypeT>,
  },
  readonly edit_type: EDIT_SERIES_EDIT_T,
}>;

declare type EditUrlEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly affects: number,
    readonly description?: CompT<string | null>,
    readonly isMerge: boolean,
    readonly uri?: CompT<string>,
    readonly url: UrlT,
  },
  readonly edit_type: EDIT_URL_EDIT_T,
}>;

declare type EditWorkEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly attributes?: {
      readonly [attributeName: string]: CompT<ReadonlyArray<string>>,
    },
    readonly comment?: CompT<string | null>,
    readonly iswc?: CompT<string | null>,
    readonly languages?: CompT<ReadonlyArray<LanguageT>>,
    readonly name?: CompT<string>,
    readonly type?: CompT<WorkTypeT | null>,
    readonly work: WorkT,
  },
  readonly edit_type: EDIT_WORK_EDIT_T,
}>;

declare type MergeAreasEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: AreaT,
    readonly old: ReadonlyArray<AreaT>,
  },
  readonly edit_type: EDIT_AREA_MERGE_T,
}>;

declare type MergeArtistsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: ArtistT,
    readonly old: ReadonlyArray<ArtistT>,
    readonly rename: boolean,
  },
  readonly edit_type: EDIT_ARTIST_MERGE_T,
}>;

declare type MergeEventsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: EventT,
    readonly old: ReadonlyArray<EventT>,
  },
  readonly edit_type: EDIT_EVENT_MERGE_T,
}>;

declare type MergeInstrumentsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: InstrumentT,
    readonly old: ReadonlyArray<InstrumentT>,
  },
  readonly edit_type: EDIT_INSTRUMENT_MERGE_T,
}>;

declare type MergeLabelsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: LabelT,
    readonly old: ReadonlyArray<LabelT>,
  },
  readonly edit_type: EDIT_LABEL_MERGE_T,
}>;

declare type MergePlacesEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: PlaceT,
    readonly old: ReadonlyArray<PlaceT>,
  },
  readonly edit_type: EDIT_PLACE_MERGE_T,
}>;

declare type MergeRecordingsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly large_spread: boolean,
    readonly new: RecordingT,
    readonly old: ReadonlyArray<RecordingT>,
  },
  readonly edit_type: EDIT_RECORDING_MERGE_T,
}>;

declare type MergeReleaseGroupsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: ReleaseGroupT,
    readonly old: ReadonlyArray<ReleaseGroupT>,
  },
  readonly edit_type: EDIT_RELEASEGROUP_MERGE_T,
}>;

declare type MergeReleaseEditDisplayChangeT = {
  readonly mediums: ReadonlyArray<{
    readonly id: number,
    readonly new_name: string,
    readonly new_position: number,
    readonly old_name: string,
    readonly old_position: StrOrNum,
  }>,
  readonly release: ReleaseT,
};

declare type MergeReleaseEditDisplayRecordingMergeT = {
  readonly destination: RecordingT,
  readonly large_spread: boolean,
  readonly medium: string,
  readonly sources: ReadonlyArray<RecordingT>,
  readonly track: string,
};

declare type MergeReleasesEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly cannot_merge_recordings_reason?: {
      readonly message: string,
      readonly vars: {readonly [var: string]: string, ...},
    },
    readonly changes: ReadonlyArray<MergeReleaseEditDisplayChangeT>,
    readonly edit_version: 1 | 2 | 3,
    readonly empty_releases?: ReadonlyArray<ReleaseT>,
    readonly merge_strategy: 'append' | 'merge',
    readonly new: ReleaseT,
    readonly old: ReadonlyArray<ReleaseT>,
    readonly recording_merges?:
      ReadonlyArray<MergeReleaseEditDisplayRecordingMergeT>,
  },
  readonly edit_type: EDIT_RELEASE_MERGE_T,
}>;

declare type MergeSeriesEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: SeriesT,
    readonly old: ReadonlyArray<SeriesT>,
  },
  readonly edit_type: EDIT_SERIES_MERGE_T,
}>;

declare type MergeWorksEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: WorkT,
    readonly old: ReadonlyArray<WorkT>,
  },
  readonly edit_type: EDIT_WORK_MERGE_T,
}>;

declare type MoveDiscIdEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly medium_cdtoc: MediumCDTocT,
    readonly new_medium: MediumT,
    readonly old_medium: MediumT,
  },
  readonly edit_type: EDIT_MEDIUM_MOVE_DISCID_T,
}>;

declare type RemoveCoverArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: ReleaseArtT,
    readonly release: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_REMOVE_COVER_ART_T,
}>;

declare type RemoveDiscIdEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly cdtoc: CDTocT,
    readonly medium: MediumT,
  },
  readonly edit_type: EDIT_MEDIUM_REMOVE_DISCID_T,
}>;

declare type RemoveAreaEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: AreaT,
    readonly entity_type: 'area',
  },
  readonly edit_type: EDIT_AREA_DELETE_T,
}>;

declare type RemoveArtistEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: ArtistT,
    readonly entity_type: 'artist',
  },
  readonly edit_type: EDIT_ARTIST_DELETE_T,
}>;

declare type RemoveEventArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: EventArtT,
    readonly event: EventT,
  },
  readonly edit_type: EDIT_EVENT_REMOVE_EVENT_ART_T,
}>;

declare type RemoveEventEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: EventT,
    readonly entity_type: 'event',
  },
  readonly edit_type: EDIT_EVENT_DELETE_T,
}>;

declare type RemoveGenreEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: GenreT,
    readonly entity_type: 'genre',
  },
  readonly edit_type: EDIT_GENRE_DELETE_T,
}>;

declare type RemoveInstrumentEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: InstrumentT,
    readonly entity_type: 'instrument',
  },
  readonly edit_type: EDIT_INSTRUMENT_DELETE_T,
}>;

declare type RemoveLabelEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: LabelT,
    readonly entity_type: 'label',
  },
  readonly edit_type: EDIT_LABEL_DELETE_T,
}>;

declare type RemovePlaceEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: PlaceT,
    readonly entity_type: 'place',
  },
  readonly edit_type: EDIT_PLACE_DELETE_T,
}>;

declare type RemoveRecordingEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: RecordingT,
    readonly entity_type: 'recording',
  },
  readonly edit_type: EDIT_RECORDING_DELETE_T,
}>;

declare type RemoveReleaseGroupEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: ReleaseGroupT,
    readonly entity_type: 'release_group',
  },
  readonly edit_type: EDIT_RELEASEGROUP_DELETE_T,
}>;

declare type RemoveReleaseEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: ReleaseT,
    readonly entity_type: 'release',
  },
  readonly edit_type: EDIT_RELEASE_DELETE_T,
}>;

declare type RemoveSeriesEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: SeriesT,
    readonly entity_type: 'series',
  },
  readonly edit_type: EDIT_SERIES_DELETE_T,
}>;

declare type RemoveWorkEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entity: WorkT,
    readonly entity_type: 'work',
  },
  readonly edit_type: EDIT_WORK_DELETE_T,
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
  readonly display_data: {
    readonly isrc: IsrcT,
  },
  readonly edit_type: EDIT_RECORDING_REMOVE_ISRC_T,
}>;

declare type RemoveIswcEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly iswc: IswcT,
  },
  readonly edit_type: EDIT_WORK_REMOVE_ISWC_T,
}>;

declare type RemoveMediumEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly medium: MediumT,
    readonly tracks?: ReadonlyArray<TrackT>,
  },
  readonly edit_type: EDIT_MEDIUM_DELETE_T,
}>;

declare type RemoveRelationshipEditT = Readonly<{
  ...GenericEditT,
  readonly data: {
    readonly edit_version?: number,
    readonly relationship: {
      readonly entity0: {
        readonly gid?: string,
        readonly id: number,
        readonly name: string,
      },
      readonly entity0_credit?: string,
      readonly entity1: {
        readonly gid?: string,
        readonly id: number,
        readonly name: string,
      },
      readonly entity1_credit?: string,
      readonly extra_phrase_attributes?: string,
      readonly id: number,
      readonly link: {
        readonly attributes?: ReadonlyArray<{
          readonly credited_as?: string,
          readonly gid?: string,
          readonly id?: string | number,
          readonly name?: string,
          readonly root_gid?: string,
          readonly root_id?: string | number,
          readonly root_name?: string,
          readonly text_value?: string,
          readonly type?: {
            readonly gid: string,
            readonly id: string | number,
            readonly name: string,
            readonly root: {
              readonly gid: string,
              readonly id: string | number,
              readonly name: string,
            },
          },
        }>,
        readonly begin_date: {
          readonly day: number | null,
          readonly month: number | null,
          readonly year: string | number | null,
        },
        readonly end_date: {
          readonly day: number | null,
          readonly month: number | null,
          readonly year: string | number | null,
        },
        readonly ended?: string,
        readonly type: {
          readonly entity0_type: string,
          readonly entity1_type: string,
          readonly id?: string | number,
          readonly long_link_phrase?: string,
        },
      },
      readonly phrase?: string,
    },
  },
  readonly display_data: {
    readonly entered_from?: NonUrlRelatableEntityT,
    readonly relationship: RelationshipT,
  },
  readonly edit_type: EDIT_RELATIONSHIP_DELETE_T,
}>;

declare type RemoveRelationshipAttributeEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly description: string | null,
    readonly name: string,
  },
  readonly edit_type: EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE_T,
}>;

declare type RemoveRelationshipTypeEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly attributes: ReadonlyArray<{
      ...LinkTypeAttrTypeT,
      readonly typeName: string,
    }>,
    readonly description: string | null,
    readonly entity0_type: RelatableEntityTypeT,
    readonly entity1_type: RelatableEntityTypeT,
    readonly link_phrase: string,
    readonly long_link_phrase: string,
    readonly name: string,
    readonly reverse_link_phrase: string,
  },
  readonly edit_type: EDIT_RELATIONSHIP_REMOVE_LINK_TYPE_T,
}>;

declare type RemoveReleaseLabelEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly catalog_number: string,
    readonly label?: LabelT,
    readonly release: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_DELETERELEASELABEL_T,
}>;

declare type ReorderCoverArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly new: ReadonlyArray<ReleaseArtT>,
    readonly old: ReadonlyArray<ReleaseArtT>,
    readonly release: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_REORDER_COVER_ART_T,
}>;

declare type ReorderEventArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly event: EventT,
    readonly new: ReadonlyArray<EventArtT>,
    readonly old: ReadonlyArray<EventArtT>,
  },
  readonly edit_type: EDIT_EVENT_REORDER_EVENT_ART_T,
}>;

declare type ReorderMediumsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly mediums: ReadonlyArray<{
      readonly new: number,
      readonly old: 'new' | number,
      readonly title: string,
    }>,
    readonly release: ReleaseT,
  },
  readonly edit_type: EDIT_RELEASE_REORDER_MEDIUMS_T,
}>;

declare type ReorderRelationshipsEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly entered_from?: NonUrlRelatableEntityT,
    readonly relationships: ReadonlyArray<{
      readonly new_order: number,
      readonly old_order: number,
      readonly relationship: RelationshipT,
    }>,
  },
  readonly edit_type: EDIT_RELATIONSHIPS_REORDER_T,
}>;

declare type SetCoverArtEditT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly artwork: CompT<ReleaseArtT>,
    readonly isOldArtworkAutomatic: boolean,
    readonly release_group: ReleaseGroupT,
  },
  readonly edit_type: EDIT_RELEASEGROUP_SET_COVER_ART_T,
}>;

declare type SetTrackLengthsEditGenericT = Readonly<{
  ...GenericEditT,
  readonly display_data: {
    readonly cdtoc: CDTocT | null,
    readonly length: CompT<ReadonlyArray<number | null>>,
    readonly medium?: MediumT,
    readonly releases: ReadonlyArray<ReleaseT>,
  },
}>;

declare type SetTrackLengthsEditHistoricT = Readonly<{
  ...SetTrackLengthsEditGenericT,
  readonly edit_type: EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC_T,
}>;

declare type SetTrackLengthsEditStandardT = Readonly<{
  ...SetTrackLengthsEditGenericT,
  readonly edit_type: EDIT_SET_TRACK_LENGTHS_T,
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
