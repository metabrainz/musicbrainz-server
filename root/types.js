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

declare type AreaT =
  & CommentRoleT
  & CoreEntityT
  & TypeRoleT<AreaTypeT>
  & {|
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

declare type ArtistT =
  & CommentRoleT
  & CoreEntityT
  & TypeRoleT<ArtistTypeT>
  & {|
      +entityType: 'artist',
      +sort_name: string,
    |};

export opaque type ArtistTypeT: OptionTreeT = OptionTreeT;

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
  +instruments_by_type?: {|
    +[number]: $ReadOnlyArray<InstrumentT>,
    +unknown: $ReadOnlyArray<InstrumentT>,
  |},
  +instrument_types?: $ReadOnlyArray<InstrumentTypeT>,
  +isrcs?: $ReadOnlyArray<IsrcT>,
  +recordings?: $ReadOnlyArray<RecordingT>,
  +tag?: string,
|};

type CommentRoleT = {|+comment: string|};

declare type CommonsImageT = {|
  +page_url: string,
  +thumb_url: string,
|};

declare type CoreEntityT = EntityT & {|
  +gid: string,
  +name: string,
|};

declare type EditableRoleT = {|
  +editsPending: boolean,
|};

declare type EntityT = {|
  +entityType: string,
  +id: number,
|};

// See MusicBrainz::Server::Form::Utils::build_grouped_options
// FIXME(michael): Figure out a way to consolidate GroupedOptionsT,
// OptionListT, and OptionTreeT?
declare type GroupedOptionsT = $ReadOnlyArray<{|
  +optgroup: string,
  +options: $ReadOnlyArray<{|
    +label: string,
    +value: number,
  |}>,
|}>;

declare type InstrumentT =
  & CommentRoleT
  & CoreEntityT
  & TypeRoleT<InstrumentTypeT>
  & {|
      +description: string,
      +entityType: 'instrument',
    |};

export opaque type InstrumentTypeT: OptionTreeT = OptionTreeT;

declare type EventT =
  & CommentRoleT
  & CoreEntityT
  & TypeRoleT<EventTypeT>
  & {|
      +entityType: 'event',
    |};

export opaque type EventTypeT: OptionTreeT = OptionTreeT;

declare type IsrcT =
  & EditableRoleT
  & EntityT
  & {|
      +entityType: 'isrc',
      +isrc: string,
      +recording_id: number,
    |};

declare type IswcT =
  & EditableRoleT
  & EntityT
  & {|
      +entityType: 'iswc',
      +iswc: string,
      +work_id: number,
    |};

declare type LabelT =
  & CommentRoleT
  & CoreEntityT
  & {|
      +entityType: 'label',
    |};

// See MB.forms.buildOptionsTree
declare type OptionListT = $ReadOnlyArray<{|
  +value: number,
  +text: string,
|}>;

declare type OptionTreeT =
  & EntityT
  & {|
      +gid: string,
      +name: string,
      +parentID: number | null,
      +childOrder: number,
      +description: string,
    |};

declare type PlaceT =
  & CommentRoleT
  & CoreEntityT
  & TypeRoleT<PlaceTypeT>
  & {|
      +entityType: 'place',
    |};

export opaque type PlaceTypeT: OptionTreeT = OptionTreeT;

declare type RatableT = CoreEntityT & {|
  +rating: number | null,
  +rating_count: number,
  +user_rating: number | null,
|};

declare type RecordingT =
  & CommentRoleT
  & ArtistCreditRoleT
  & CoreEntityT
  & {|
      +entityType: 'recording',
      +isrcs: $ReadOnlyArray<IsrcT>,
      +length: number,
      +video: boolean,
    |};

declare type ReleaseGroupT =
  & CommentRoleT
  & ArtistCreditRoleT
  & CoreEntityT
  & {|
      +entityType: 'release_group',
    |};

declare type ReleaseT =
  & CommentRoleT
  & CoreEntityT
  & {|
      +barcode: string | null,
      +entityType: 'release',
      +languageID: number | null,
      +packagingID: number | null,
      +scriptID: number | null,
      +statusID: number | null,
    |};

declare type SeriesT =
  & CommentRoleT
  & CoreEntityT
  & {|
      +entityType: 'series',
    |};

declare type TypeRoleT<T: OptionTreeT> = {|
  +typeID: number | null,
  +typeName?: string,
|};

declare type UrlT =
  & CoreEntityT
  & EditableRoleT
  & {|
      +decoded: string,
      +entityType: 'url',
    |};

declare type UserTagT = {|
  +count: number,
  +tag: string,
  +vote: 1 | -1,
|};

declare type WorkT =
  & CommentRoleT
  & CoreEntityT
  & TypeRoleT<WorkTypeT>
  & {|
      +entityType: 'work',
    |};

export opaque type WorkTypeT: OptionTreeT = OptionTreeT;

declare type WorkAttributeTypeAllowedValueT =
  & EntityT
  & OptionTreeT
  & {|+workAttributeTypeID: number, +value: string|};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeAllowedValueTreeT =
  & WorkAttributeTypeAllowedValueT
  & {|+children?: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>|};

declare type WorkAttributeTypeAllowedValueTreeRootT =
  {|+children: $ReadOnlyArray<WorkAttributeTypeAllowedValueTreeT>|};

declare type WorkAttributeTypeT =
  & CommentRoleT
  & EntityT
  & OptionTreeT
  & {|+freeText: boolean|};

// See MusicBrainz::Server::Controller::Work::stash_work_form_json
declare type WorkAttributeTypeTreeT =
  & WorkAttributeTypeT
  & {|+children?: $ReadOnlyArray<WorkAttributeTypeTreeT>|};

declare type WorkAttributeTypeTreeRootT =
  {|+children: $ReadOnlyArray<WorkAttributeTypeTreeT>|};

declare var $c: CatalystContextT;
