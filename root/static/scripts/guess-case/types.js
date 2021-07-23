/*
 * @flow
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type GuessCaseInputT = any;

declare type GuessCaseModeT = any;

declare type GuessCaseOutputT = any;

export type GuessCaseT = {
  CFG_UC_UPPERCASED: boolean,
  i: GuessCaseInputT,
  mode: GuessCaseModeT,
  o: GuessCaseOutputT,
};
