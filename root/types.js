/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * Types are in alphabetical order.
 *
 * The definitions in this file are intended to model the output of the
 * TO_JSON methods under lib/MusicBrainz/Server/Entity/, those are precisely
 * how data is serialized for us.
 */

declare type AggregatedTagT = {|
  +tag: string,
  +count: number,
|};

declare type AliasT = {|
  ...DatePeriodRoleT,
  ...EditableRoleT,
  ...EntityRoleT<'alias'>,
  ...TypeRoleT<empty>,
  +locale: string | null,
  +name: string,
  +primary_for_locale: boolean,
  +sort_name: string,
|};

declare type AnchorProps = {|
  +href: string,
  +key?: number | string,
  +target?: '_blank',
  +title?: string,
|};

declare type AnyFieldT<+F> =
  | FieldT<F>
  | StructFieldT<F>;

declare type AnyReactElem = React$Element<any>;

declare type ApplicationT = {|
  ...EntityRoleT<'application'>,
  +is_server: boolean,
  +name: string,
  +oauth_id: string,
  +oauth_redirect_uri?: string,
  +oauth_secret: string,
  +oauth_type: string,
|};

declare type AreaT = {|
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'area'>,
  ...DatePeriodRoleT,
  ...TypeRoleT<AreaTypeT>,
  +containment: $ReadOnlyArray<AreaT> | null,
  +iso_3166_1_codes: $ReadOnlyArray<string>,
  +iso_3166_2_codes: $ReadOnlyArray<string>,
  +iso_3166_3_codes: $ReadOnlyArray<string>,
  +primary_code: string,
|};

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

declare type AnnotationRoleT = {|
  +latest_annotation?: AnnotationT,
|};

declare type AnnotationT = {|
  +changelog: string,
  +creation_date: string,
  +editor: EditorT | null,
  +html: string,
  +id: number,
  +parent: CoreEntityT | null,
  +text: string,
|};

declare type AreaTypeT = OptionTreeT<'area_type'>;

declare type ArtistCreditNameT = {|
  +artist: ArtistT,
  +joinPhrase: string,
  +name: string,
|};

declare type ArtistCreditRoleT = {|
  +artistCredit: ArtistCreditT,
|};

declare type ArtistCreditT = $ReadOnlyArray<ArtistCreditNameT>;

declare type ArtistT = {|
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
  +sort_name: string,
|};

declare type ArtistTypeT = OptionTreeT<'artist_type'>;

declare type ArtworkT = {|
  +comment: string,
  +image: string,
  +large_thumbnail: string,
  +mime_type: string,
  +release?: ReleaseT,
  +small_thumbnail: string,
  +types: $ReadOnlyArray<string>,
|};

// See MusicBrainz::Server::Form::Utils::build_attr_info
declare type AttrInfoT = {|
  +children?: $ReadOnlyArray<AttrInfoT>,
  +creditable: boolean,
  +description?: string,
  +freeText: boolean,
  +gid: string,
  +id: number,
  +l_name: string,
  +name: string,
  root: AttrInfoT,
  +rootID: number,
  +unaccented?: string,
|};

declare type AutoEditorElectionT = {|
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
|};

declare type AutoEditorElectionVoteT = {|
  ...EntityRoleT<empty>,
  +vote_name: string,
  +vote_time: string,
  +voter: EditorT,
|};

declare type BlogEntryT = {|
  +title: string,
  +url: string,
|};

type CatalystActionT = {|
  +name: string,
|};

type CatalystContextT = {|
  +action: CatalystActionT,
  +relative_uri: string,
  +req: CatalystRequestContextT,
  +session: CatalystSessionT | null,
  +sessionid: string | null,
  +stash: CatalystStashT,
  +user?: CatalystUserT,
  +user_exists: boolean,
  +linked_entities: {
    +artist_type: {|
      +[number]: ArtistTypeT,
    |},
    +language: {|
      +[number]: LanguageT,
    |},
    +link_type: {|
      +[number]: LinkTypeT,
    |},
    +release_group_primary_type: {|
      [number]: ReleaseGroupTypeT,
    |},
    +release_group_secondary_type: {|
      [number]: ReleaseGroupSecondaryTypeT,
    |},
    +release_packaging: {|
      +[number]: ReleasePackagingT,
    |},
    +release_status: {|
      +[number]: ReleaseStatusT,
    |},
    +script: {|
      +[number]: ScriptT,
    |},
    +series_ordering_type: {|
      +[number]: SeriesOrderingTypeT,
    |},
    +series_type: {|
      +[number]: SeriesTypeT,
    |},
    +work_attribute_type: {|
      +[number]: WorkAttributeTypeT,
    |},
  },
|};

type CatalystRequestContextT = {|
  +headers: {+[string]: string},
  +query_params: {+[string]: string},
  +secure: boolean,
  +uri: string,
|};

type CatalystSessionT = {|
  +tport?: number,
|};

type CatalystStashT = {|
  +all_collections?: $ReadOnlyArray<CollectionT>,
  +collections?: $ReadOnlyArray<CollectionT>,
  +commons_image?: CommonsImageT | null,
  +containment?: {|
    [number]: ?1,
  |},
  +current_language: string,
  +current_language_html: string,
  +more_tags?: boolean,
  +number_of_revisions?: number,
  +release_artwork?: ArtworkT,
  +server_languages?: $ReadOnlyArray<ServerLanguageT>,
  +subscribed?: boolean,
  +top_tags?: $ReadOnlyArray<AggregatedTagT>,
  +user_tags?: $ReadOnlyArray<UserTagT>,
|};

type CatalystUserT = EditorT;

declare type CDStubT = {|
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
|};

declare type CollectionT = {|
  ...EntityRoleT<'collection'>,
  ...TypeRoleT<CollectionTypeT>,
  +description: string,
  +entity_count: number,
  +editor: EditorT | null,
  +gid: string,
  +name: string,
  +public: boolean,
|};

declare type CollectionTypeT = {|
  ...OptionTreeT<'collection_type'>,
  item_entity_type: string,
|};

type CommentRoleT = {|+comment: string|};

declare type CoordinatesT = {|
  +latitude: number,
  +longitude: number,
|};

declare type CommonsImageT = {|
  +page_url: string,
  +thumb_url: string,
|};

declare type CompoundFieldT<+F> = {|
  ...FieldRoleT,
  +field: F,
|};

declare type CoreEntityRoleT<+T> = {|
  ...EntityRoleT<T>,
  ...LastUpdateRoleT,
  +gid: string,
  +name: string,
  +relationships?: $ReadOnlyArray<RelationshipT>,
|};

declare type CoreEntityT =
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
  | UrlT
  | WorkT;

declare type CoverArtTypeT = OptionTreeT<'cover_art_type'>;

declare type CritiqueBrainzReviewT = {|
  +author: CritiqueBrainzUserT,
  +body: string,
  +created: string,
  +id: string,
|};

declare type CritiqueBrainzUserT = {|
  +id: string,
  +name: string,
|};

declare type DatePeriodRoleT = {|
  +begin_date: PartialDateT | null,
  +end_date: PartialDateT | null,
  +ended: boolean,
|};

declare type EditableRoleT = {|
  +editsPending: boolean,
|};

declare type EditExpireActionT = 1 | 2;

declare type EditorPreferencesT = {|
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
|};

declare type EditorT = {|
  ...EntityRoleT<'editor'>,
  +biography: string | null,
  +birth_date: PartialDateT | null,
  +deleted: boolean,
  +email: string,
  +email_confirmation_date: string | null,
  +gravatar: string,
  +is_account_admin: boolean,
  +is_admin: boolean,
  +is_auto_editor: boolean,
  +is_banner_editor: boolean,
  +is_bot: boolean,
  +is_editing_disabled: boolean,
  +is_limited: boolean,
  +is_location_editor: boolean,
  +is_relationship_editor: boolean,
  +is_wiki_transcluder: boolean,
  +name: string,
  +preferences: EditorPreferencesT,
  +registration_date: string,
  +website: string | null,
|};

declare type EditorOAuthTokenT = {|
  ...EntityRoleT<empty>,
  +application: ApplicationT,
  +editor: EditorT,
  +granted: string,
  +is_offline: boolean,
  +permissions: $ReadOnlyArray<string>,
  +scope: number,
|};

declare type EditStatusT =
  | 1 // OPEN
  | 2 // APPLIED
  | 3 // FAILEDVOTE
  | 4 // FAILEDDEP
  | 5 // ERROR
  | 6 // FAILEDPREREQ
  | 7 // NOVOTES
  | 8 // TOBEDELETED
  | 9 // DELETED
  ;

declare type EditT = {|
  +close_time: string,
  +conditions: {|
    +duration: number,
    +votes: number,
    +expire_action: EditExpireActionT,
    +auto_edit: boolean,
  |},
  +created_time: string,
  +data: Object,
  +edit_type: number,
  +editor_id: number,
  +expires_time: string,
  +id: number,
  +preview?: boolean,
  +quality: QualityT,
  +status: EditStatusT,
  +votes: $ReadOnlyArray<VoteT>,
|};

declare type EntityRoleT<+T> = {|
  +entityType: T,
  +id: number,
|};

declare type EventT = {|
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'event'>,
  ...DatePeriodRoleT,
  ...RatableRoleT,
  ...TypeRoleT<EventTypeT>,
  +areas: $ReadOnlyArray<{|+entity: AreaT|}>,
  +cancelled: boolean,
  +performers: $ReadOnlyArray<{|
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  |}>,
  +places: $ReadOnlyArray<{|+entity: PlaceT|}>,
  +time: string,
|};

declare type EventTypeT = OptionTreeT<'event_type'>;

declare type Expand2ReactInput = VarSubstArg | AnchorProps;

declare type Expand2ReactOutput = string | AnyReactElem;

declare type FieldRoleT = {|
  +errors: $ReadOnlyArray<string>,
  +has_errors: boolean,
  +html_name: string,
  /*
   * The field `id` is unique across all fields on the page. It's purpose
   * is for passing to `key` attributes on React elements.
   */
  +id: number,
|};

declare type FieldT<+V> = {|
  ...FieldRoleT,
  +value: V,
|};

// See lib/MusicBrainz/Server/Form/Role/ToJSON.pm
declare type FormT<F> = {|
  +field: F,
  +has_errors: boolean,
  +last_field_id: number,
  +name: string,
|};

declare type GenderT = OptionTreeT<'gender'>;

/*
 * See MusicBrainz::Server::Form::Utils::build_grouped_options
 * FIXME(michael): Figure out a way to consolidate GroupedOptionsT,
 * OptionListT, and OptionTreeT?
 */
declare type GroupedOptionsT = $ReadOnlyArray<{|
  +optgroup: string,
  +options: SelectOptionsT,
|}>;

declare type InstrumentT = {|
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'instrument'>,
  ...TypeRoleT<InstrumentTypeT>,
  +description: string,
|};

declare type InstrumentTypeT = OptionTreeT<'instrument_type'>;

type IpiCodesRoleT = {|
  +ipi_codes: $ReadOnlyArray<IpiCodeT>,
|};

declare type IpiCodeT = {|
  ...EditableRoleT,
  +ipi: string,
|};

type IsniCodesRoleT = {|
  +isni_codes: $ReadOnlyArray<IsniCodeT>,
|};

declare type IsniCodeT = {|
  ...EditableRoleT,
  +isni: string,
|};

declare type IsrcT = {|
  ...EditableRoleT,
  ...EntityRoleT<'isrc'>,
  +isrc: string,
  +recording_id: number,
|};

declare type IswcT = {|
  ...EditableRoleT,
  ...EntityRoleT<'iswc'>,
  +iswc: string,
  +work_id: number,
|};

declare type LabelT = {|
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
|};

declare type LabelTypeT = OptionTreeT<'label_type'>;

declare type LanguageT = {|
  +entityType: 'language',
  +frequency: number,
  +id: number,
  +iso_code_1: string | null,
  +iso_code_2b: string | null,
  +iso_code_2t: string | null,
  +iso_code_3: string | null,
  +name: string,
|};

type LastUpdateRoleT = {|
  +last_updated: string | null,
|};

declare type LinkAttrT = {|
  type: {|
    +gid: string,
  |},
  +credited_as?: string,
  +text_value?: string,
|};

declare type LinkTypeAttrTypeT = {|
  attribute: AttrInfoT,
  +max: number | null,
  +min: number | null,
|};

declare type LinkTypeT = {|
  ...OptionTreeT<'link_type'>,
  +attributes: {+[number]: LinkTypeAttrTypeT},
  +cardinality0: number,
  +cardinality1: number,
  +children?: $ReadOnlyArray<LinkTypeT>,
  +deprecated: boolean,
  +has_dates: boolean,
  +id: number,
  +link_phrase: string,
  +long_link_phrase: string,
  +orderable_direction: number,
  +reverse_link_phrase: string,
  +type0: string,
  +type1: string,
|};

declare type MaybeGroupedOptionsT =
  | {|+grouped: true, +options: GroupedOptionsT|}
  | {|+grouped: false, +options: SelectOptionsT|};

declare type MediumFormatT = {|
  ...OptionTreeT<'medium_format'>,
  +has_discids: boolean,
  +year: ?number,
|};

// See MB.forms.buildOptionsTree
declare type OptionListT = $ReadOnlyArray<{|
  +text: string,
  +value: number,
|}>;

declare type OptionTreeT<+T> = {|
  ...EntityRoleT<T>,
  +childOrder: number,
  +description: string,
  +gid: string,
  +name: string,
  +parentID: number | null,
|};

/*
 * See http://search.cpan.org/~lbrocard/Data-Page-2.02/lib/Data/Page.pm
 * Serialized in MusicBrainz::Server::TO_JSON.
 */
declare type PagerT = {|
  +current_page: number,
  +first_page: 1,
  +last_page: number,
  +next_page: number | null,
  +previous_page: number | null,
  +total_entries: number,
|};

declare type PartialDateT = {|
  +day: number | null,
  +month: number | null,
  +year: number | null,
|};

declare type PlaceT = {|
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'place'>,
  ...DatePeriodRoleT,
  ...TypeRoleT<PlaceTypeT>,
  +address: string,
  +area: AreaT | null,
  +coordinates: CoordinatesT | null,
|};

declare type PlaceTypeT = OptionTreeT<'place_type'>;

declare type QualityT = -1 | 0 | 1 | 2;

declare type RatableRoleT = {|
  +rating: number | null,
  +rating_count: number,
  +user_rating: number | null,
|};

declare type RatableT =
  | ArtistT
  | EventT
  | LabelT
  | RecordingT
  | ReleaseGroupT
  | WorkT;

declare type RecordingT = {|
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'recording'>,
  ...RatableRoleT,
  +isrcs: $ReadOnlyArray<IsrcT>,
  +length: number,
  +video: boolean,
|};

declare type RelationshipAttributeTypeT = {|
  +gid: string,
|};

declare type RelationshipAttributeT = {|
  +type: RelationshipAttributeTypeT,
|};

declare type RelationshipT = {|
  // `attributes` may not exist when seeding.
  +attributes?: $ReadOnlyArray<RelationshipAttributeT>,
  +id: number,
  +linkTypeID: number,
  +target: CoreEntityT,
|};

declare type ReleaseGroupSecondaryTypeT =
  OptionTreeT<'release_group_secondary_type'>;

declare type ReleaseGroupT = {|
  ...AnnotationRoleT,
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'release_group'>,
  ...RatableRoleT,
  ...TypeRoleT<ReleaseGroupTypeT>,
  +cover_art?: ArtworkT,
  +firstReleaseDate: string | null,
  +l_type_name: string | null,
  +release_count: number,
  +release_group?: ReleaseGroupT,
  +review_count: ?number,
  +secondaryTypeIDs: $ReadOnlyArray<number>,
  +typeID: number | null,
  +typeName: string | null,
|};

declare type ReleaseGroupTypeT = OptionTreeT<'release_group_type'>;

declare type ReleasePackagingT = OptionTreeT<'release_packaging'>;

declare type ReleaseT = {|
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
  +packagingID: number | null,
  +quality: QualityT,
  +releaseGroup?: ReleaseGroupT,
  +script: ScriptT | null,
  +scriptID: number | null,
  +status: ReleaseStatusT | null,
  +statusID: number | null,
|};

declare type ReleaseEventT = {|
  +country: AreaT | null,
  +date: PartialDateT | null,
|};

declare type ReleaseLabelT = {|
  +catalogNumber: string | null,
  +label: LabelT | null,
|};

declare type ReleaseStatusT = OptionTreeT<'release_status'>;

declare type RepeatableFieldT<+F> = {|
  ...FieldRoleT,
  +field: $ReadOnlyArray<F>,
|};

declare type SanitizedCatalystContextT = {|
  +user: SanitizedEditorT | null,
  +user_exists: boolean,
|};

declare type SanitizedEditorPreferencesT = {|
  datetime_format: string,
  timezone: string,
|};

declare type SanitizedEditorT = {|
  ...EntityRoleT<'editor'>,
  +gravatar: string,
  +name: string,
  +preferences: SanitizedEditorPreferencesT,
|};

declare type ScriptT = {|
  +entityType: 'script',
  +frequency: number,
  +id: number,
  +iso_code: string,
  +iso_number: string | null,
  +name: string,
|};

declare type SearchFormT = FormT<{|
  +limit: FieldT<number>,
  +method: FieldT<'advanced' | 'direct' | 'indexed'>,
  +query: FieldT<string>,
  +type: FieldT<string>,
|}>;

declare type SearchResultT<T> = {|
  +entity: T,
  +extra: $ReadOnlyArray<{|
    +medium_position: number,
    +medium_track_count: number,
    +release: ReleaseT,
    +track_position: number,
  |}>,
  +position: number,
  +score: number,
|};

/*
 * See MusicBrainz::Server::Form::Utils::select_options.
 * FIXME(michael): Consolidate with OptionListT.
 */
declare type SelectOptionT = {|
  +label: string | (() => string),
  +value: number | string,
|};

declare type SelectOptionsT = $ReadOnlyArray<SelectOptionT>;

declare type SeriesT = {|
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'series'>,
  ...TypeRoleT<SeriesTypeT>,
  +orderingTypeID: number,
|};

declare type SeriesOrderingTypeT = OptionTreeT<'series_ordering_type'>;

declare type SeriesTypeT = OptionTreeT<'series_type'>;

declare type ServerLanguageT = {|
  +id: number,
  +name: string,
  +native_language: string,
  +native_territory: string,
|};

declare type StrOrNum = string | number;

type StructFieldT<+F> =
  | CompoundFieldT<F>
  | RepeatableFieldT<F>;

declare type TypeRoleT<T> = {|
  +typeID: number | null,
  +typeName?: string,
|};

declare type UrlT = {|
  ...CoreEntityRoleT<'url'>,
  ...EditableRoleT,
  +decoded: string,
  +href_url: string,
  +pretty_name: string,
  +show_license_in_sidebar?: boolean,
|};

declare type UserTagT = {|
  +count: number,
  +tag: string,
  +vote: 1 | 0 | -1,
|};

declare type VarSubstArg =
  | StrOrNum
  | AnyReactElem;

declare type VoteOptionT =
  | -2   // None
  | -1   // Abstain
  |  0   // No
  |  1   // Yes
  |  2   // Approve
  ;

declare type VoteT = {|
  +editor_id: number,
  +superseded: boolean,
  +vote: VoteOptionT,
|};

declare type WorkAttributeT = {|
  // Generally shouldn't be null, but the id isn't stored in edit data.
  +id: number | null,
  // N.B. TypeRoleT requires typeID to be nullable.
  +typeID: number,
  +typeName: string,
  +value: string,
  +value_id: number | null,
|};

declare type WorkT = {|
  ...AnnotationRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT<'work'>,
  ...RatableRoleT,
  ...TypeRoleT<WorkTypeT>,
  +artists: $ReadOnlyArray<ArtistCreditT>,
  +attributes: $ReadOnlyArray<WorkAttributeT>,
  +iswcs: $ReadOnlyArray<IswcT>,
  +languages: $ReadOnlyArray<WorkLanguageT>,
  +writers: $ReadOnlyArray<{|
    +entity: ArtistT,
    +roles: $ReadOnlyArray<string>,
  |}>,
|};

declare type WorkTypeT = OptionTreeT<'work_type'>;

declare type WorkLanguageT = {|
  +language: LanguageT,
|};

declare type WorkAttributeTypeAllowedValueT = {|
  ...OptionTreeT<'work_attribute_type_allowed_value'>,
  +value: string,
  +workAttributeTypeID: number,
|};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeAllowedValueTreeT = {|
  ...WorkAttributeTypeAllowedValueT,
  +children?: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>,
|};

declare type WorkAttributeTypeAllowedValueTreeRootT =
  {|+children: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>|};

declare type WorkAttributeTypeT = {|
  ...CommentRoleT,
  ...OptionTreeT<'work_attribute_type'>,
  +freeText: boolean,
|};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeTreeT = {|
  ...WorkAttributeTypeT,
  +children?: $ReadOnlyArray<WorkAttributeTypeTreeT>,
|};

declare type WorkAttributeTypeTreeRootT =
  {|+children: $ReadOnlyArray<WorkAttributeTypeTreeT>|};

declare type WikipediaExtractT = {|
  +content: string,
  +url: string,
|};
