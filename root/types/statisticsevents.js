/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type StatisticsEventFormT = FormT<{
  readonly date: FieldT<string>,
  readonly description: FieldT<string>,
  readonly link: FieldT<string>,
  readonly title: FieldT<string>,
}>;

export type StatisticsEventT = {
  readonly date: string,
  readonly description: string,
  readonly link: string,
  readonly title: string,
};
