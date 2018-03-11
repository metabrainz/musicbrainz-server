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

declare type AliasT = {|
  ...DatePeriodRoleT,
  ...EditableRoleT,
  ...EntityRoleT,
  ...TypeRoleT<AliasTypeT>,
  +entityType: 'alias',
  +locale: string | null,
  +name: string,
  +primary_for_locale: boolean,
  +sort_name: string,
|};

export opaque type AliasTypeT: OptionTreeT = OptionTreeT;

declare type AreaT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...DatePeriodRoleT,
  ...TypeRoleT<AreaTypeT>,
  +containment: $ReadOnlyArray<AreaT>,
  +entityType: 'area',
|};

export opaque type AreaTypeT: OptionTreeT = OptionTreeT;

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
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...RatableRoleT,
  ...TypeRoleT<ArtistTypeT>,
  +entityType: 'artist',
  +sort_name: string,
|};

export opaque type ArtistTypeT: OptionTreeT = OptionTreeT;

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

type CatalystContextT = {|
  +session: CatalystSessionT | null,
  +sessionid: string | null,
  +stash: CatalystStashT,
  +user?: CatalystUserT,
  +user_exists: boolean,
|};

type CatalystSessionT = {|
  +tport?: number,
|};

type CatalystUserT = {|
  +is_location_editor: boolean,
  +is_relationship_editor: boolean,
|};

type CatalystStashT = {|
|};

type CommentRoleT = {|+comment: string|};

declare type CommonsImageT = {|
  +page_url: string,
  +thumb_url: string,
|};

declare type CompoundFieldT<F: {+[string]: mixed}> = {|
  +errors: $ReadOnlyArray<string>,
  +field: F,
  +has_errors: boolean,
  +id: number,
|};

declare type CoreEntityRoleT = {|
  ...EntityRoleT,
  +gid: string,
  +name: string,
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

declare type DatePeriodRoleT = {|
  +begin_date: PartialDateT | null,
  +end_date: PartialDateT | null,
  +ended: boolean,
|};

declare type EditableRoleT = {|
  +editsPending: boolean,
|};

declare type EntityRoleT = {|
  +entityType: string,
  +id: number,
|};

declare type FieldT<V> = {|
  +errors: $ReadOnlyArray<string>,
  +has_errors: boolean,
  +id: number,
  +value: V,
|};

// See lib/MusicBrainz/Server/Form/Role/ToJSON.pm
declare type FormT<F> = {|
  +field: F,
  +has_errors: boolean,
  +last_field_id: number,
  +name: string,
|};

/*
 * See MusicBrainz::Server::Form::Utils::build_grouped_options
 * FIXME(michael): Figure out a way to consolidate GroupedOptionsT,
 * OptionListT, and OptionTreeT?
 */
declare type GroupedOptionsT = $ReadOnlyArray<{|
  +optgroup: string,
  +options: $ReadOnlyArray<{|
    +label: string,
    +value: number,
  |}>,
|}>;

declare type InstrumentT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...TypeRoleT<InstrumentTypeT>,
  +description: string,
  +entityType: 'instrument',
|};

export opaque type InstrumentTypeT: OptionTreeT = OptionTreeT;

declare type EventT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...RatableRoleT,
  ...TypeRoleT<EventTypeT>,
  +entityType: 'event',
|};

export opaque type EventTypeT: OptionTreeT = OptionTreeT;

declare type IsrcT = {|
  ...EditableRoleT,
  ...EntityRoleT,
  +entityType: 'isrc',
  +isrc: string,
  +recording_id: number,
|};

declare type IswcT = {|
  ...EditableRoleT,
  ...EntityRoleT,
  +entityType: 'iswc',
  +iswc: string,
  +work_id: number,
|};

declare type LabelT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...RatableRoleT,
  +entityType: 'label',
|};

declare type LinkTypeAttrTypeT = {|
  attribute: AttrInfoT,
  +max: number | null,
  +min: number | null,
|};

declare type LinkTypeInfoT = {|
  +attributes?: {+[number]: LinkTypeAttrTypeT},
  +cardinality0: number,
  +cardinality1: number,
  +childOrder: number,
  +children?: $ReadOnlyArray<LinkTypeInfoT>,
  +deprecated: boolean,
  +description?: string;
  +gid: string,
  +hasDates: boolean,
  +id: number,
  +orderableDirection: number,
  +phrase: string,
  +reversePhrase: string,
  +type0: string,
  +type1: string,
|};

// See MB.forms.buildOptionsTree
declare type OptionListT = $ReadOnlyArray<{|
  +text: string,
  +value: number,
|}>;

declare type OptionTreeT = {|
  ...EntityRoleT,
  +childOrder: number,
  +description: string,
  +gid: string,
  +name: string,
  +parentID: number | null,
|};

declare type PartialDateT = {|
  +day: number | null,
  +month: number | null,
  +year: number | null,
|};

declare type PlaceT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...TypeRoleT<PlaceTypeT>,
  +entityType: 'place',
|};

export opaque type PlaceTypeT: OptionTreeT = OptionTreeT;

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
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...RatableRoleT,
  +entityType: 'recording',
  +isrcs: $ReadOnlyArray<IsrcT>,
  +length: number,
  +video: boolean,
|};

declare type ReleaseGroupT = {|
  ...ArtistCreditRoleT,
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...RatableRoleT,
  +entityType: 'release_group',
|};

declare type ReleaseT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  +barcode: string | null,
  +entityType: 'release',
  +languageID: number | null,
  +packagingID: number | null,
  +scriptID: number | null,
  +statusID: number | null,
|};

declare type RepeatableFieldT<F> = {|
  +errors: $ReadOnlyArray<string>,
  +field: $ReadOnlyArray<F>,
  +has_errors: boolean,
  +id: number,
|};

declare type SeriesT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  +entityType: 'series',
|};

declare type TypeRoleT<T: OptionTreeT> = {|
  +typeID: number | null,
  +typeName?: string,
|};

declare type UrlT = {|
  ...CoreEntityRoleT,
  ...EditableRoleT,
  +decoded: string,
  +entityType: 'url',
|};

declare type UserTagT = {|
  +count: number,
  +tag: string,
  +vote: 1 | -1,
|};

declare type WorkT = {|
  ...CommentRoleT,
  ...CoreEntityRoleT,
  ...RatableRoleT,
  ...TypeRoleT<WorkTypeT>,
  +entityType: 'work',
|};

export opaque type WorkTypeT: OptionTreeT = OptionTreeT;

declare type WorkAttributeTypeAllowedValueT = {|
  ...EntityRoleT,
  ...OptionTreeT,
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
  ...EntityRoleT,
  ...OptionTreeT,
  +freeText: boolean,
|};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeTreeT = {|
  ...WorkAttributeTypeT,
  +children?: $ReadOnlyArray<WorkAttributeTypeTreeT>,
|};

declare type WorkAttributeTypeTreeRootT =
  {|+children: $ReadOnlyArray<WorkAttributeTypeTreeT>|};

declare var $c: CatalystContextT;
