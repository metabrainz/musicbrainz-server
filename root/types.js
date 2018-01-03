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

type CatalystContextT = {
  user_exists: bool;
};

declare type CommonsImageT = {
  page_url: string;
  thumb_url: string;
};

declare type CoreEntityT = EntityT & {
  gid: string;
};

declare type EntityT = {
  entityType: string;
  id: number;
  name: string;
};

declare type RatableT = EntityT & {
  rating: number | null;
  rating_count: number;
  user_rating: number | null;
};

declare type UserTagT = {
  count: number;
  tag: string;
  vote: 1 | -1;
};

declare var $c: CatalystContextT;
