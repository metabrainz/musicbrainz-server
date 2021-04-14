/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * Types are (mostly) in alphabetical order, though we may e.g. keep
 * types Foo and WritableFoo next to each other for clarity.
 *
 * The definitions in this file are intended to model the output of the
 * TO_JSON methods under lib/MusicBrainz/Server/Entity/, those are precisely
 * how data is serialized for us.
 */

declare type AggregatedTagT = {
  +count: number,
  +tag: TagT,
};

declare type AliasT = {
  ...DatePeriodRoleT,
  ...EditableRoleT,
  ...EntityRoleT<'alias'>,
  ...TypeRoleT<AliasTypeT>,
  +locale: string | null,
  +name: string,
  +primary_for_locale: boolean,
  +sort_name: string,
};

declare type AliasTypeT = OptionTreeT<'alias_type'>;

declare type AnchorProps = {
  +className?: string,
  +href: string,
  +key?: number | string,
  +target?: '_blank',
  +title?: string,
};

declare type AppearancesT<T> = {
  +hits: number,
  +results: $ReadOnlyArray<T>,
};

declare type ApplicationT = {
  ...EntityRoleT<'application'>,
  +is_server: boolean,
  +name: string,
  +oauth_id: string,
  +oauth_redirect_uri?: string,
  +oauth_secret: string,
  +oauth_type: string,
};

declare type AreaFieldT = CompoundFieldT<{
  +gid: FieldT<string | null>,
  +name: FieldT<string>,
}>;

declare type AreaT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'area'>,
  ...DatePeriodRoleT,
  ...TypeRoleT<AreaTypeT>,
  +containment: $ReadOnlyArray<AreaT> | null,
  +country_code: string,
  +iso_3166_1_codes: $ReadOnlyArray<string>,
  +iso_3166_2_codes: $ReadOnlyArray<string>,
  +iso_3166_3_codes: $ReadOnlyArray<string>,
  +primary_code: string,
  +primaryAlias?: string | null,
}>;

declare type AnnotatedEntityT =
  | AreaT
  | ArtistT
  | EventT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | WorkT;

declare type AnnotationRoleT = {
  +latest_annotation?: AnnotationT,
};

declare type AnnotationT = {
  +changelog: string,
  +creation_date: string,
  +editor: EditorT | null,
  +html: string,
  +id: number,
  +parent: CoreEntityT | null,
  +text: string,
};

declare type AreaTypeT = OptionTreeT<'area_type'>;

declare type ArtistCreditNameT = {
  +artist: ArtistT,
  +joinPhrase: string,
  +name: string,
};

declare type ArtistCreditRoleT = {
  +artist: string,
  +artistCredit: ArtistCreditT,
};

declare type ArtistCreditT = {
  +editsPending?: boolean,
  +entityType?: 'artist_credit',
  +id?: number,
  +names: $ReadOnlyArray<ArtistCreditNameT>,
};

declare type ArtistT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'artist'>,
  ...DatePeriodRoleT,
  ...IpiCodesRoleT,
  ...IsniCodesRoleT,
  ...RatableRoleT,
  ...TypeRoleT<ArtistTypeT>,
  +area: AreaT | null,
  +begin_area: AreaT | null,
  +end_area: AreaT | null,
  +gender: GenderT | null,
  +primaryAlias?: string | null,
  +sort_name: string,
}>;

declare type ArtistTypeT = OptionTreeT<'artist_type'>;

declare type ArtworkT = {
  ...EditableRoleT,
  +comment: string,
  +filename: string | null,
  +huge_ia_thumbnail: string,
  +huge_thumbnail: string,
  +id: number,
  +image: string,
  +large_ia_thumbnail: string,
  +large_thumbnail: string,
  +mime_type: string,
  +release?: ReleaseT,
  +small_ia_thumbnail: string,
  +small_thumbnail: string,
  +suffix: string,
  +types: $ReadOnlyArray<string>,
};

declare type AutoEditorElectionT = {
  ...EntityRoleT<empty>,
  +candidate: EditorT,
  +close_time?: string,
  +current_expiration_time: string,
  +is_closed: boolean,
  +is_open: boolean,
  +is_pending: boolean,
  +no_votes: number,
  +open_time?: string,
  +propose_time: string,
  +proposer: EditorT,
  +seconder_1?: EditorT,
  +seconder_2?: EditorT,
  +status_name: string,
  +status_name_short: string,
  +votes: $ReadOnlyArray<AutoEditorElectionVoteT>,
  +yes_votes: number,
};

declare type AutoEditorElectionVoteT = {
  ...EntityRoleT<empty>,
  +vote_name: string,
  +vote_time: string,
  +voter: EditorT,
};

declare type BlogEntryT = {
  +title: string,
  +url: string,
};

declare type CatalystActionT = {
  +name: string,
};

declare type CatalystContextT = {
  +action: CatalystActionT,
  +flash: {
    +message?: string,
  },
  +relative_uri: string,
  +req: CatalystRequestContextT,
  +session: CatalystSessionT | null,
  +sessionid: string | null,
  +stash: CatalystStashT,
  +user?: UnsanitizedEditorT,
};

declare type CatalystRequestContextT = {
  +body_params: {+[param: string]: string},
  +headers: {+[header: string]: string},
  +query_params: {+[param: string]: string},
  +secure: boolean,
  +uri: string,
};

declare type CatalystSessionT = {
  +merger?: MergeQueueT,
  +tport?: number,
};

declare type CatalystStashT = {
  +alert?: string,
  +alert_mtime?: number | null,
  +can_delete?: boolean,
  +collaborative_collections?: $ReadOnlyArray<CollectionT>,
  +commons_image?: CommonsImageT | null,
  +containment?: {
    [collectionId: number]: ?1,
  },
  +current_action_requires_auth?: boolean,
  +current_language: string,
  +current_language_html: string,
  +entity?: CoreEntityT,
  +genre_map?: {+[genreName: string]: GenreT, ...},
  +globals_script_nonce?: string,
  +hide_merge_helper?: boolean,
  +jsonld_data?: {...},
  +last_replication_date?: string,
  +makes_no_changes?: boolean,
  +more_tags?: boolean,
  +new_edit_notes?: boolean,
  +new_edit_notes_mtime?: number | null,
  +number_of_collections?: number,
  +number_of_revisions?: number,
  +own_collections?: $ReadOnlyArray<CollectionT>,
  +release_artwork?: ArtworkT,
  +release_artwork_count?: number,
  +release_cdtoc_count?: number,
  +server_languages?: $ReadOnlyArray<ServerLanguageT>,
  +subscribed?: boolean,
  +to_merge?: $ReadOnlyArray<CoreEntityT>,
  +top_tags?: $ReadOnlyArray<AggregatedTagT>,
  +user_tags?: $ReadOnlyArray<UserTagT>,
};

declare type CDStubT = $ReadOnly<{
  ...EntityRoleT<'cdstub'>,
  +artist: string,
  +barcode: string,
  // null properties are not present in search indexes
  +date_added: string | null,
  +discid: string,
  +last_modified: string | null,
  +lookup_count: number | null,
  +modify_count: number | null,
  +title: string,
  +toc: string | null,
  +track_count: number,
}>;

declare type CDTocT = $ReadOnly<{
  ...EntityRoleT<'cdtoc'>,
  +discid: string,
}>;

declare type CollectionT = {
  ...EntityRoleT<'collection'>,
  ...TypeRoleT<CollectionTypeT>,
  +collaborators: $ReadOnlyArray<EditorT>,
  +description: string,
  +description_html: string,
  +editor: EditorT | null,
  +editor_is_limited: boolean,
  +entity_count: number,
  +gid: string,
  +name: string,
  +public: boolean,
  +subscribed?: boolean,
};

declare type CollectionTypeT = {
  ...OptionTreeT<'collection_type'>,
  item_entity_type: string,
};

declare type CommentRoleT = {
  +comment: string,
};

declare type CoordinatesT = {
  +latitude: number,
  +longitude: number,
};

declare type CommonsImageT = {
  +page_url: string,
  +thumb_url: string,
};

declare type CompT<T> = {
  +new: T,
  +old: T,
};

declare type CompoundFieldT<F> = {
  errors: Array<string>,
  field: F,
  has_errors: boolean,
  html_name: string,
  id: number,
  pendingErrors?: Array<string>,
  type: 'compound_field',
};

declare type ReadOnlyCompoundFieldT<+F> = {
  +errors: $ReadOnlyArray<string>,
  +field: F,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'compound_field',
};

declare type ConfirmFormT = FormT<{
  +cancel: ReadOnlyFieldT<string>,
  +edit_note: ReadOnlyFieldT<string>,
  +make_votable: ReadOnlyFieldT<boolean>,
  +submit: ReadOnlyFieldT<string>,
}>;

declare type SecureConfirmFormT = FormT<{
  +cancel: ReadOnlyFieldT<string>,
  +csrf_token: ReadOnlyFieldT<string>,
  +submit: ReadOnlyFieldT<string>,
}>;

declare type PagedLinkTypeGroupT = {
  +direction: 'backward' | 'forward',
  +is_loaded: boolean,
  +limit: number,
  +link_type_id: number,
  +offset: number,
  +relationships: $ReadOnlyArray<RelationshipT>,
  +total_relationships: number,
};

declare type PagedTargetTypeGroupT = {
  +[linkTypeIdAndSourceColumn: string]: PagedLinkTypeGroupT,
};

declare type CoreEntityRoleT<+T> = {
  ...EntityRoleT<T>,
  ...LastUpdateRoleT,
  +gid: string,
  +name: string,
  +paged_relationship_groups?: {
    +[targetType: CoreEntityTypeT]: PagedTargetTypeGroupT | void,
  },
  +relationships?: $ReadOnlyArray<RelationshipT>,
};

declare type CoreEntityT =
  | AreaT
  | ArtistT
  | EventT
  | GenreT
  | InstrumentT
  | LabelT
  | PlaceT
  | RecordingT
  | ReleaseGroupT
  | ReleaseT
  | SeriesT
  | UrlT
  | WorkT;

declare type CoreEntityTypeT =
  | 'area'
  | 'artist'
  | 'event'
  | 'genre'
  | 'instrument'
  | 'label'
  | 'place'
  | 'recording'
  | 'release_group'
  | 'release'
  | 'series'
  | 'url'
  | 'work';

declare type CoverArtTypeT = OptionTreeT<'cover_art_type'>;

declare type CritiqueBrainzReviewT = {
  +author: CritiqueBrainzUserT,
  +body: string,
  +created: string,
  +id: string,
};

declare type CritiqueBrainzUserT = {
  +id: string,
  +name: string,
};

declare type DatePeriodFieldT = ReadOnlyCompoundFieldT<{
  +begin_date: PartialDateFieldT,
  +end_date: PartialDateFieldT,
  +ended: ReadOnlyFieldT<boolean>,
}>;

declare type WritableDatePeriodFieldT = CompoundFieldT<{
  +begin_date: WritablePartialDateFieldT,
  +end_date: WritablePartialDateFieldT,
  +ended: FieldT<boolean>,
}>;

declare type DatePeriodRoleT = {
  +begin_date: PartialDateT | null,
  +end_date: PartialDateT | null,
  +ended: boolean,
};

// From Algorithm::Diff
declare type DiffChangeTypeT = '+' | '-' | 'c' | 'u';

declare type EditableRoleT = {
  +editsPending: boolean,
};

declare type EditExpireActionT = 1 | 2;

declare type UnsanitizedEditorPreferencesT = {
  +datetime_format: string,
  +email_on_no_vote: boolean,
  +email_on_notes: boolean,
  +email_on_vote: boolean,
  +public_ratings: boolean,
  +public_subscriptions: boolean,
  +public_tags: boolean,
  +show_gravatar: boolean,
  +subscribe_to_created_artists: boolean,
  +subscribe_to_created_labels: boolean,
  +subscribe_to_created_series: boolean,
  +subscriptions_email_period: string,
  +timezone: string,
};

declare type UnsanitizedEditorT = $ReadOnly<{
  ...EntityRoleT<'editor'>,
  +age: number | null,
  +area: AreaT | null,
  +biography: string | null,
  +birth_date: PartialDateT | null,
  +deleted: boolean,
  +email: string | null,
  +email_confirmation_date: string | null,
  +gender: GenderT | null,
  +gravatar: string,
  +has_confirmed_email_address: boolean,
  +has_email_address: boolean,
  +is_charter: boolean,
  +is_limited: boolean,
  +languages: $ReadOnlyArray<EditorLanguageT> | null,
  +last_login_date: string | null,
  +name: string,
  +preferences: UnsanitizedEditorPreferencesT,
  +privileges: number,
  +registration_date: string,
  +website: string | null,
}>;

declare type EditorLanguageT = {
  +fluency: FluencyT,
  +language: LanguageT,
};

declare type EditorOAuthTokenT = {
  ...EntityRoleT<empty>,
  +application: ApplicationT,
  +editor: EditorT | null,
  +granted: string,
  +is_offline: boolean,
  +permissions: $ReadOnlyArray<string>,
  +scope: number,
};

declare type EditStatusT =
  | 1 // OPEN
  | 2 // APPLIED
  | 3 // FAILEDVOTE
  | 4 // FAILEDDEP
  | 5 // ERROR
  | 6 // FAILEDPREREQ
  | 7 // NOVOTES
  | 9; // DELETED

declare type EditT = {
  +close_time: string,
  +conditions: {
    +auto_edit: boolean,
    +duration: number,
    +expire_action: EditExpireActionT,
    +votes: number,
  },
  +created_time: string,
  +data: {+[dataProp: string]: any, ...},
  +edit_kind: 'add' | 'edit' | 'remove' | 'merge' | 'other',
  +edit_type: number,
  +editor_id: number,
  +expires_time: string,
  +historic_type: number | null,
  +id: number | null, // id is missing in previews
  +is_loaded: boolean,
  +is_open: boolean,
  +preview?: boolean,
  +quality: QualityT,
  +status: EditStatusT,
  +votes: $ReadOnlyArray<VoteT>,
};

declare type EntityRoleT<+T> = {
  +entityType: T,
  +id: number,
};

declare type EventT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'event'>,
  ...DatePeriodRoleT,
  ...RatableRoleT,
  ...TypeRoleT<EventTypeT>,
  +areas: $ReadOnlyArray<{
    +credit: string,
    +entity: AreaT,
  }>,
  +cancelled: boolean,
  +performers: $ReadOnlyArray<{
    +credit: string,
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  }>,
  +places: $ReadOnlyArray<{
    +credit: string,
    +entity: PlaceT,
  }>,
  +primaryAlias?: string | null,
  +related_entities?: {
    +areas: AppearancesT<string>,
    +performers: AppearancesT<string>,
    +places: AppearancesT<string>,
  },
  +related_series: $ReadOnlyArray<number>,
  +setlist?: string,
  +time: string,
}>;

declare type EventTypeT = OptionTreeT<'event_type'>;

declare type Expand2ReactInput = VarSubstArg | AnchorProps;

declare type Expand2ReactOutput = string | React$MixedElement;

declare type ExpandLFunc<-Input, Output> = (
  key: string,
  args: {+[arg: string]: Input | Output, ...},
) => Output;

declare type FieldT<V> = {
  errors: Array<string>,
  has_errors: boolean,
  html_name: string,
  /*
   * The field `id` is unique across all fields on the page. It's purpose
   * is for passing to `key` attributes on React elements.
   */
  id: number,
  pendingErrors?: Array<string>,
  type: 'field',
  value: V,
};

declare type ReadOnlyFieldT<+V> = {
  +errors: $ReadOnlyArray<string>,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'field',
  +value: V,
};

declare type FluencyT =
  | 'basic'
  | 'intermediate'
  | 'advanced'
  | 'native';

// See lib/MusicBrainz/Server/Form/Role/ToJSON.pm
declare type FormT<F> = {
  field: F,
  has_errors: boolean,
  name: string,
  +type: 'form',
};

declare type GenderT = OptionTreeT<'gender'>;

declare type GenreT = $ReadOnly<{
  ...CommentRoleT,
  ...CoreEntityRoleT<'genre'>,
  +primaryAlias?: string | null,
}>;

declare type GettextDomain =
  | 'attributes'
  | 'countries'
  | 'instrument_descriptions'
  | 'instruments'
  | 'languages'
  | 'mb_server'
  | 'relationships'
  | 'scripts'
  | 'statistics';

/*
 * See MusicBrainz::Server::Form::Utils::build_grouped_options
 * FIXME(michael): Figure out a way to consolidate GroupedOptionsT,
 * OptionListT, and OptionTreeT?
 */
declare type GroupedOptionsT = $ReadOnlyArray<{
  +optgroup: string,
  +options: SelectOptionsT,
}>;

declare type InstrumentCreditsAndRelTypesRoleT = {
  +instrumentCreditsAndRelTypes?: {
    +[entityGid: string]: $ReadOnlyArray<string>,
  },
};

declare type InstrumentT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'instrument'>,
  ...TypeRoleT<InstrumentTypeT>,
  +description: string,
  +primaryAlias?: string | null,
}>;

declare type InstrumentTypeT = OptionTreeT<'instrument_type'>;

declare type IpiCodesRoleT = {
  +ipi_codes: $ReadOnlyArray<IpiCodeT>,
};

declare type IpiCodeT = {
  ...EditableRoleT,
  +ipi: string,
};

declare type IsniCodesRoleT = {
  +isni_codes: $ReadOnlyArray<IsniCodeT>,
};

declare type IsniCodeT = {
  ...EditableRoleT,
  +isni: string,
};

declare type IsrcT = {
  ...EditableRoleT,
  ...EntityRoleT<'isrc'>,
  +isrc: string,
  +recording_id: number,
};

declare type IswcT = {
  ...EditableRoleT,
  ...EntityRoleT<'iswc'>,
  +iswc: string,
  +work_id: number,
};

declare type KnockoutObservable<T> = {
  // eslint-disable-next-line no-undef
  [[call]]: (() => T) & ((T) => empty),
  peek: () => T,
  subscribe: ((T) => void) => {dispose: () => empty},
};

declare type KnockoutObservableArray<T> =
  & KnockoutObservable<$ReadOnlyArray<T>>
  & {
      push: (T) => empty,
      remove: (T) => empty,
    };

declare type LabelT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'label'>,
  ...DatePeriodRoleT,
  ...IpiCodesRoleT,
  ...IsniCodesRoleT,
  ...RatableRoleT,
  ...TypeRoleT<LabelTypeT>,
  +area: AreaT | null,
  +label_code: number,
  +primaryAlias?: string | null,
}>;

declare type LabelTypeT = OptionTreeT<'label_type'>;

declare type LanguageT = {
  +entityType: 'language',
  +frequency: number,
  +id: number,
  +iso_code_1: string | null,
  +iso_code_2b: string | null,
  +iso_code_2t: string | null,
  +iso_code_3: string | null,
  +name: string,
};

declare type LastUpdateRoleT = {
  +last_updated: string | null,
};

declare type LinkAttrT = {
  +credited_as?: string,
  +text_value?: string,
  type: {
    +gid: string,
  },
  +typeID: number,
  +typeName: string,
};

declare type LinkAttrTypeT = {
  ...OptionTreeT<'link_attribute_type'>,
  +children?: $ReadOnlyArray<LinkAttrTypeT>,
  +creditable: boolean,
  +free_text: boolean,
  +instrument_comment?: string,
  +root_gid: string,
  +root_id: number,
};

declare type LinkTypeAttrTypeT = {
  +max: number | null,
  +min: number | null,
};

declare type LinkTypeT = {
  ...OptionTreeT<'link_type'>,
  +attributes: {+[typeId: number]: LinkTypeAttrTypeT},
  +cardinality0: number,
  +cardinality1: number,
  +children?: $ReadOnlyArray<LinkTypeT>,
  +deprecated: boolean,
  +documentation: string | null,
  +examples: $ReadOnlyArray<{
    +name: string,
    +relationship: RelationshipT,
  }>,
  +has_dates: boolean,
  +id: number,
  +link_phrase: string,
  +long_link_phrase: string,
  +orderable_direction: number,
  +reverse_link_phrase: string,
  +root_id: number | null,
  +type0: string,
  +type1: string,
};

declare type MaybeGroupedOptionsT =
  | {+grouped: true, +options: GroupedOptionsT}
  | {+grouped: false, +options: SelectOptionsT};

declare type MediumCDTocT = $ReadOnly<{
  ...EntityRoleT<'medium_cdtoc'>,
  +cdtoc: CDTocT,
  +editsPending: boolean,
}>;

declare type MediumFormatT = {
  ...OptionTreeT<'medium_format'>,
  +has_discids: boolean,
  +year: ?number,
};

declare type MediumT = $ReadOnly<{
  ...EntityRoleT<'track'>,
  ...LastUpdateRoleT,
  +cdtocs: $ReadOnlyArray<MediumCDTocT>,
  +editsPending: boolean,
  +format: MediumFormatT | null,
  +format_id: number,
  +name: string,
  +position: number,
  +release_id: number,
  +tracks?: $ReadOnlyArray<TrackT>,
}>;

declare type MergeFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +merging: RepeatableFieldT<FieldT<number>>,
  +rename: FieldT<boolean>,
  +target: FieldT<number>,
}>;

declare type MergeQueueT = {
  +entities: $ReadOnlyArray<number>,
  +ready_to_merge: boolean,
  +type: CoreEntityTypeT,
};

declare type MinimalCoreEntityT = {
  +entityType: CoreEntityTypeT,
  +gid: string,
};

// See MB.forms.buildOptionsTree
declare type OptionListT = $ReadOnlyArray<{
  +text: string,
  +value: number,
}>;

declare type OptionTreeT<+T> = {
  ...EntityRoleT<T>,
  +child_order: number,
  +description: string,
  +gid: string,
  +name: string,
  +parent_id: number | null,
};

/*
 * See http://search.cpan.org/~lbrocard/Data-Page-2.02/lib/Data/Page.pm
 * Serialized in MusicBrainz::Server::TO_JSON.
 */
declare type PagerT = {
  +current_page: number,
  +first_page: 1,
  +last_page: number,
  +next_page: number | null,
  +previous_page: number | null,
  +total_entries: number,
};

declare type PartialDateFieldT = ReadOnlyCompoundFieldT<{
  +day: ReadOnlyFieldT<StrOrNum | null>,
  +month: ReadOnlyFieldT<StrOrNum | null>,
  +year: ReadOnlyFieldT<StrOrNum | null>,
}>;

declare type WritablePartialDateFieldT = CompoundFieldT<{
  +day: FieldT<StrOrNum | null>,
  +month: FieldT<StrOrNum | null>,
  +year: FieldT<StrOrNum | null>,
}>;

declare type PartialDateT = {
  +day: number | null,
  +month: number | null,
  +year: number | null,
};

declare type PlaceT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'place'>,
  ...DatePeriodRoleT,
  ...TypeRoleT<PlaceTypeT>,
  +address: string,
  +area: AreaT | null,
  +coordinates: CoordinatesT | null,
  +primaryAlias?: string | null,
}>;

declare type PlaceTypeT = OptionTreeT<'place_type'>;

declare type QualityT = -1 | 0 | 1 | 2;

declare type RatableRoleT = {
  +rating: number | null,
  +rating_count: number,
  +user_rating: number | null,
};

declare type RatableT =
  | ArtistT
  | EventT
  | LabelT
  | RecordingT
  | ReleaseGroupT
  | WorkT;

declare type RatingT = {
  +editor: EditorT,
  +rating: number,
};

declare type RecordingT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'recording'>,
  ...RatableRoleT,
  +appearsOn?: AppearancesT<{gid: string, name: string}>,
  +artist?: string,
  +artistCredit?: ArtistCreditT,
  +first_release_date?: PartialDateT,
  +isrcs: $ReadOnlyArray<IsrcT>,
  +length: number,
  +primaryAlias?: string | null,
  +related_works: $ReadOnlyArray<number>,
  +video: boolean,
}>;

declare type RecordingWithArtistCreditT =
  $ReadOnly<{...RecordingT, +artistCredit: ArtistCreditT}>;

declare type RelationshipT = {
  ...DatePeriodRoleT,
  ...EditableRoleT,
  // `attributes` may not exist when seeding.
  +attributes?: $ReadOnlyArray<LinkAttrT>,
  +direction?: 'backward',
  +entity0?: CoreEntityT,
  +entity0_credit: string,
  +entity0_id: number,
  +entity1?: CoreEntityT,
  +entity1_credit: string,
  +entity1_id: number,
  +id: number,
  +linkOrder: number,
  +linkTypeID: number,
  +source_type: string,
  +target: CoreEntityT,
  +target_type: string,
};

declare type ReleaseGroupSecondaryTypeT =
  OptionTreeT<'release_group_secondary_type'>;

declare type ReleaseGroupT = $ReadOnly<{
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'release_group'>,
  ...RatableRoleT,
  ...TypeRoleT<ReleaseGroupTypeT>,
  +cover_art?: ArtworkT,
  +firstReleaseDate: string | null,
  +l_type_name: string | null,
  +primaryAlias?: string | null,
  +release_count: number,
  +release_group?: ReleaseGroupT,
  +review_count: ?number,
  +secondaryTypeIDs: $ReadOnlyArray<number>,
  +typeID: number | null,
  +typeName: string | null,
}>;

declare type ReleaseGroupTypeT = OptionTreeT<'release_group_type'>;

declare type ReleasePackagingT = OptionTreeT<'release_packaging'>;

declare type ReleaseT = $ReadOnly<{
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'release'>,
  +barcode: string | null,
  +combined_format_name?: string,
  +combined_track_count?: string,
  +cover_art_presence: 'absent' | 'present' | 'darkened' | null,
  +cover_art_url: string | null,
  +events?: $ReadOnlyArray<ReleaseEventT>,
  +labels?: $ReadOnlyArray<ReleaseLabelT>,
  +language: LanguageT | null,
  +languageID: number | null,
  +length?: number,
  +may_have_cover_art?: boolean,
  +may_have_discids?: boolean,
  +packagingID: number | null,
  +primaryAlias?: string | null,
  +quality: QualityT,
  +releaseGroup?: ReleaseGroupT,
  +script: ScriptT | null,
  +scriptID: number | null,
  +status: ReleaseStatusT | null,
  +statusID: number | null,
}>;

declare type ReleaseEventT = {
  +country: AreaT | null,
  +date: PartialDateT | null,
};

declare type ReleaseLabelT = {
  +catalogNumber: string | null,
  +label: LabelT | null,
  +label_id: number,
};

declare type ReleaseStatusT = OptionTreeT<'release_status'>;

declare type RepeatableFieldT<F> = {
  errors: Array<string>,
  field: Array<F>,
  has_errors: boolean,
  html_name: string,
  id: number,
  last_index: number,
  pendingErrors?: Array<string>,
  type: 'repeatable_field',
};

declare type ReadOnlyFormT<+F> = {
  +field: F,
  +has_errors: boolean,
  +name: string,
  +type: 'form',
};

declare type ReadOnlyRepeatableFieldT<+F> = {
  +errors: $ReadOnlyArray<string>,
  +field: $ReadOnlyArray<F>,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  last_index: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'repeatable_field',
};

declare type SanitizedCatalystContextT = {
  +action: {
    +name: string,
  },
  +req: {
    +uri: string,
  },
  +stash: {
    +current_language: string,
    +genre_map?: {+[genreName: string]: GenreT, ...},
  },
  +user: ActiveEditorT | null,
};

declare type ActiveEditorPreferencesT = {
  +datetime_format: string,
  +timezone: string,
};

/*
 * Only used in cases where the editor being sanitized is logged in;
 * exposes some preferences and misc. metadata.
 */
declare type ActiveEditorT = {
  ...EntityRoleT<'editor'>,
  +gravatar: string,
  +has_confirmed_email_address: boolean,
  +name: string,
  +preferences: ActiveEditorPreferencesT,
  +privileges: number,
};

declare type EditorT = {
  ...EntityRoleT<'editor'>,
  +deleted: boolean,
  +gravatar: string,
  +name: string,
  +privileges: number,
};

declare type ScriptT = {
  +entityType: 'script',
  +frequency: number,
  +id: number,
  +iso_code: string,
  +iso_number: string | null,
  +name: string,
};

declare type SearchFormT = FormT<{
  +limit: ReadOnlyFieldT<number>,
  +method: ReadOnlyFieldT<'advanced' | 'direct' | 'indexed'>,
  +query: ReadOnlyFieldT<string>,
  +type: ReadOnlyFieldT<string>,
}>;

declare type SearchResultT<T> = {
  +entity: T,
  +extra: $ReadOnlyArray<{
    +medium_position: number,
    +medium_track_count: number,
    +release: ReleaseT,
    +track_position: number,
  }>,
  +position: number,
  +score: number,
};

/*
 * See MusicBrainz::Server::Form::Utils::select_options.
 * FIXME(michael): Consolidate with OptionListT.
 */
declare type SelectOptionT = {
  +label: string | (() => string),
  +value: number | string,
};

declare type SelectOptionsT = $ReadOnlyArray<SelectOptionT>;

declare type SeriesT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'series'>,
  ...TypeRoleT<SeriesTypeT>,
  +orderingTypeID: number,
  +primaryAlias?: string | null,
  +type?: SeriesTypeT,
}>;

declare type SeriesItemNumbersRoleT = {
  +seriesItemNumbers?: $ReadOnlyArray<string>,
};

declare type SeriesOrderingTypeT = OptionTreeT<'series_ordering_type'>;

declare type SeriesTypeT = $ReadOnly<{
  ...OptionTreeT<'series_type'>,
  item_entity_type: CoreEntityTypeT,
}>;

declare type ServerLanguageT = {
  +id: number,
  +name: string,
  +native_language: string,
  +native_territory: string,
};

declare type StrOrNum = string | number;

declare type TagT = {
  +entityType: 'tag',
  +genre?: GenreT,
  +id: number | null,
  +name: string,
};

declare type TrackT = $ReadOnly<{
  ...EntityRoleT<'track'>,
  ...LastUpdateRoleT,
  +artist: string,
  +artistCredit: ArtistCreditT,
  +editsPending: boolean,
  +gid: string,
  +isDataTrack: boolean,
  +length: number,
  +medium: MediumT | null,
  +name: string,
  +number: string,
  +position: number,
  +recording?: RecordingT,
  +unaccented_name: string | null,
}>;

declare type TypeRoleT<T> = {
  +typeID: number | null,
  +typeName?: string,
};

declare type UrlT = {
  ...CoreEntityRoleT<'url'>,
  ...EditableRoleT,
  +decoded: string,
  +href_url: string,
  +pretty_name: string,
  +show_in_external_links?: boolean,
  +show_license_in_sidebar?: boolean,
  +sidebar_name?: string,
};

declare type UserTagT = {
  +count: number,
  +tag: TagT,
  +vote: 1 | 0 | -1,
};

declare type VarSubstArg =
  | StrOrNum
  | React$MixedElement;

/* eslint-disable no-multi-spaces */
declare type VoteOptionT =
  | -2   // None
  | -1   // Abstain
  |  0   // No
  |  1   // Yes
  |  2;   // Approve
/* eslint-enable no-multi-spaces */

declare type VoteT = {
  +editor_id: number,
  +superseded: boolean,
  +vote: VoteOptionT,
};

declare type WorkAttributeT = {
  // Generally shouldn't be null, but the id isn't stored in edit data.
  +id: number | null,
  // N.B. TypeRoleT requires typeID to be nullable.
  +typeID: number,
  +typeName: string,
  +value: string,
  +value_id: number | null,
};

declare type WorkT = $ReadOnly<{
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'work'>,
  ...RatableRoleT,
  ...TypeRoleT<WorkTypeT>,
  +artists: $ReadOnlyArray<ArtistCreditT>,
  +attributes: $ReadOnlyArray<WorkAttributeT>,
  +iswcs: $ReadOnlyArray<IswcT>,
  +languages: $ReadOnlyArray<WorkLanguageT>,
  +primaryAlias?: string | null,
  +related_artists?: {
    +artists: AppearancesT<string>,
    +writers: AppearancesT<string>,
  },
  +writers: $ReadOnlyArray<{
    +credit: string,
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  }>,
}>;

declare type WorkTypeT = OptionTreeT<'work_type'>;

declare type WorkLanguageT = {
  +language: LanguageT,
};

declare type WorkAttributeTypeAllowedValueT = {
  ...OptionTreeT<'work_attribute_type_allowed_value'>,
  +value: string,
  +workAttributeTypeID: number,
};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeAllowedValueTreeT = {
  ...WorkAttributeTypeAllowedValueT,
  +children?: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>,
};

declare type WorkAttributeTypeAllowedValueTreeRootT =
  {+children: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>};

declare type WorkAttributeTypeT = {
  ...CommentRoleT,
  ...OptionTreeT<'work_attribute_type'>,
  +free_text: boolean,
};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeTreeT = {
  ...WorkAttributeTypeT,
  +children?: $ReadOnlyArray<WorkAttributeTypeTreeT>,
};

declare type WorkAttributeTypeTreeRootT =
  {+children: $ReadOnlyArray<WorkAttributeTypeTreeT>};

declare type WikipediaExtractT = {
  +content: string,
  +url: string,
};
