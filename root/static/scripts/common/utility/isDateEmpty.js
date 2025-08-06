/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {type Observable as KnockoutObservable} from 'knockout';

declare type PartialDateObservablesT = {
  +day: KnockoutObservable<string | null>,
  +month: KnockoutObservable<string | null>,
  +year: KnockoutObservable<string | null>,
};

export function isDateObservableEmpty(
  date: PartialDateObservablesT,
): boolean {
  return !(
    nonEmpty(date.year()) ||
    nonEmpty(date.month()) ||
    nonEmpty(date.day())
  );
}

export function isDateNonEmpty(
  date: ?PartialDateT | ?PartialDateStringsT,
): implies date is PartialDateT | PartialDateStringsT {
  return /* flow-include (date != null) && */ !isDateEmpty(date);
}

export default function isDateEmpty(
  date: ?PartialDateT | ?PartialDateStringsT,
): boolean {
  return (date == null) ||
         (empty(date.year) && empty(date.month) && empty(date.day));
}
