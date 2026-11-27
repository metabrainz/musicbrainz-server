/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import rememberHeaderSearchType, {
  HEADER_SEARCH_TYPE_KEY,
} from '../../common/utility/rememberHeaderSearchType.js';
import {localStorage} from '../../common/utility/storage.js';

function headerSelect(): HTMLSelectElement {
  const select = document.createElement('select');
  for (const value of ['artist', 'recording', 'release', 'tag']) {
    const option = document.createElement('option');
    option.value = value;
    select.appendChild(option);
  }
  return select;
}

function pick(select: HTMLSelectElement, value: string): void {
  select.value = value;
  select.dispatchEvent(new Event('change'));
}

test('rememberHeaderSearchType', function (t) {
  t.plan(5);

  localStorage(HEADER_SEARCH_TYPE_KEY, 'artist');
  const first = headerSelect();
  rememberHeaderSearchType(first);
  t.equal(first.value, 'artist', 'a saved artist stays selected');

  pick(first, 'recording');
  t.equal(
    localStorage(HEADER_SEARCH_TYPE_KEY),
    'recording',
    'picking a type saves it',
  );

  const next = headerSelect();
  rememberHeaderSearchType(next);
  t.equal(next.value, 'recording', 'the next page preselects the saved type');

  localStorage(HEADER_SEARCH_TYPE_KEY, 'doc');
  const withoutDoc = headerSelect();
  rememberHeaderSearchType(withoutDoc);
  t.equal(
    withoutDoc.value,
    'artist',
    'a saved type that is not an option is ignored',
  );

  pick(withoutDoc, 'tag');
  const last = headerSelect();
  rememberHeaderSearchType(last);
  t.equal(last.value, 'tag', 'the latest pick wins');
});
