// @flow
// Copyright (C) 2017 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt


// Types are in alphabetical order.
//
// The definitions in this file are intended to model the output of the
// TO_JSON methods under lib/MusicBrainz/Server/Entity/; those are precisely
// how data is serialized for us.

declare type ArtistT =
  & CoreEntityT
  & {|
      +entityType: 'artist',
      +sort_name: string,
    |};

type CatalystContextT = {|
  +session: CatalystSessionT | null,
  +sessionid: string | null,
  +stash: CatalystStashT,
  +user_exists: bool,
|};

type CatalystSessionT = {|
  +tport?: number,
|};

type CatalystStashT = {|
  instruments_by_type?: {|
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
|};

declare type EntityT = {|
  +entityType: string,
  +id: number,
  +name: string,
|};

declare type InstrumentT =
  & EntityT
  & {|
    +description: string,
  |};

declare type InstrumentTypeT =
  & EntityT
  & OptionTreeT;

declare type OptionTreeT = {|
  +gid: string,
  +parentID: number | null,
  +childOrder: number,
  +description: string,
|};

declare type RatableT = EntityT & {|
  +rating: number | null,
  +rating_count: number,
  +user_rating: number | null,
|};

declare type RecordingT = CoreEntityT & {|
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

declare type UserTagT = {|
  +count: number,
  +tag: string,
  +vote: 1 | -1,
|};

declare var $c: CatalystContextT;
