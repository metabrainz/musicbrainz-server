/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type PartialDateObservablesT = {
  +day: KnockoutObservable<string | null>,
  +month: KnockoutObservable<string | null>,
  +year: KnockoutObservable<string | null>,
};

declare type PartialDateStringsT = {
  +day?: string,
  +month?: string,
  +year?: string,
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

export default function isDateEmpty(
  date: ?PartialDateT | ?PartialDateStringsT,
): boolean {
  return (date == null) ||
    (date.year == null && date.month == null && date.day == null);
}
