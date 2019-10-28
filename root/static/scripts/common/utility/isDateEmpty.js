/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function isDateEmpty(date: ?PartialDateT) {
  return (date == null) ||
    (date.year == null && date.month == null && date.day == null);
}
