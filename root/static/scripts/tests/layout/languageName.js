/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {languageName} from '../../../../layout/components/BottomMenu.js';

test('languageName', function (t) {
  t.plan(7);

  t.equal(languageName(undefined, false), '', 'No language gives no text');
  t.equal(
    languageName({
      id: 0,
      name: 'xx',
      native_language: '',
      native_territory: '',
    }, false),
    '[0]',
    'A language without a native name shows its ID',
  );

  t.equal(
    languageName({
      id: 0,
      name: 'zh',
      native_language: '中文',
      native_script: null,
      native_territory: '',
    }, false),
    '中文',
    'A language without a script or territory has no details',
  );
  t.equal(
    languageName({
      id: 0,
      name: 'zh-Hant',
      native_language: '中文',
      native_script: '繁體',
      native_territory: '',
    }, false),
    '中文 (繁體)',
    'The script tells zh-Hant apart from zh',
  );
  t.equal(
    languageName({
      id: 0,
      name: 'zh-Hant-TW',
      native_language: '中文',
      native_script: '繁體',
      native_territory: '台灣',
    }, false),
    '中文 (繁體, 台灣)',
    'The script comes before the territory',
  );
  t.equal(
    languageName({
      id: 0,
      name: 'fr-CA',
      native_language: 'français',
      native_territory: 'Canada',
    }, false),
    'Français (Canada)',
    'A language with a territory only is unchanged',
  );
  t.equal(
    languageName({
      id: 0,
      name: 'en',
      native_language: 'English',
      native_territory: '',
    }, true),
    'English ▾',
    'The selected language has a marker',
  );
});
