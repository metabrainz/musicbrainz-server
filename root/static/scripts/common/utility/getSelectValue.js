/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function getSelectValue(
  field: ReadOnlyFieldT<?StrOrNum>,
  options: MaybeGroupedOptionsT,
  allowEmpty: boolean = false,
): string {
  if (field.value !== undefined && field.value !== null) {
    return String(field.value);
  }
  if (allowEmpty) {
    return '';
  }
  let value: StrOrNum;
  if (options.grouped) {
    value = options.options[0].options[0].value;
  } else {
    value = options.options[0].value;
  }
  return String(value);
}
