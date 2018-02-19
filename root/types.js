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
  +tag?: string,
|};

declare type CommonsImageT = {|
  +page_url: string,
  +thumb_url: string,
|};

declare type CoreEntityT = EntityT & {|
  +gid: string,
  +name: string,
|};

declare type EditsPendingT = {|
  +editsPending: boolean,
|};

declare type EntityT = {|
  +entityType: string,
  +id: number,
|};

declare type InstrumentT =
  & CoreEntityT
  & TypeRoleT<InstrumentTypeT>
  & {|
      +description: string,
      +entityType: 'instrument',
    |};

export opaque type InstrumentTypeT: OptionTreeT = OptionTreeT;

declare type EventT =
  & CoreEntityT
  & TypeRoleT<EventTypeT>
  & {|
      +entityType: 'event',
    |};

export opaque type EventTypeT: OptionTreeT = OptionTreeT;

declare type IsrcT =
  & EditsPendingT
  & EntityT
  & {|
      +entityType: 'isrc',
      +isrc: string,
      +recording_id: number,
    |};

declare type IswcT =
  & EditsPendingT
  & EntityT
  & {|
      +entityType: 'iswc',
      +iswc: string,
      +work_id: number,
    |};

declare type LabelT =
  & CoreEntityT
  & {|
      +entityType: 'label',
    |};

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

declare type ReleaseGroupT =
  & ArtistCreditRoleT
  & CoreEntityT
  & {|
      +entityType: 'release_group',
    |};

declare type RecordingT =
  & ArtistCreditRoleT
  & CoreEntityT
  & {|
      +entityType: 'recording',
      +length: number,
      +video: boolean,
    |};

declare type ReleaseT = CoreEntityT & {|
  +barcode: string | null,
  +entityType: 'release',
  +languageID: number | null,
  +packagingID: number | null,
  +scriptID: number | null,
  +statusID: number | null,
|};

declare type SeriesT =
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
  & EditsPendingT
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
  & CoreEntityT
  & TypeRoleT<WorkTypeT>
  & {|
      +entityType: 'work',
    |};

export opaque type WorkTypeT: OptionTreeT = OptionTreeT;

declare var $c: CatalystContextT;
