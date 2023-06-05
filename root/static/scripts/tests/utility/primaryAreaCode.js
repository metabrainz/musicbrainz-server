/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import primaryAreaCode from '../../common/utility/primaryAreaCode.js';

import {genericArea} from './constants.js';

const onlyCode3Area = {
  ...genericArea,
  iso_3166_3_codes: ['code3'],
};

const onlyCode2Area = {
  ...genericArea,
  iso_3166_2_codes: ['code2'],
};

const onlyCode1Area = {
  ...genericArea,
  iso_3166_1_codes: ['code1'],
};

const allCodesArea = {
  ...genericArea,
  iso_3166_1_codes: ['code1'],
  iso_3166_2_codes: ['code2'],
  iso_3166_3_codes: ['code3'],
};

const allCodesAreaWithMultipleCode1 = {
  ...genericArea,
  iso_3166_1_codes: ['code1_1', 'code1_2'],
  iso_3166_2_codes: ['code2'],
  iso_3166_3_codes: ['code3'],
};

test('primaryAreaCode', function (t) {
  t.plan(6);

  t.equal(
    primaryAreaCode(genericArea),
    null,
    'null is returned if the area has no codes at all',
  );

  t.equal(
    primaryAreaCode(onlyCode3Area),
    'code3',
    'The ISO 3166-3 code is returned if no ISO 3166-1 nor -2 code is present',
  );

  t.equal(
    primaryAreaCode(onlyCode2Area),
    'code2',
    'The ISO 3166-2 code is returned if no ISO 3166-1 code is present',
  );

  t.equal(
    primaryAreaCode(onlyCode1Area),
    'code1',
    'The ISO 3166-1 code is returned if it exists and no other code is present',
  );

  t.equal(
    primaryAreaCode(allCodesArea),
    'code1',
    'The ISO 3166-1 code is still returned if ISO 3166-2 and -3 codes are present',
  );

  t.equal(
    primaryAreaCode(allCodesAreaWithMultipleCode1),
    'code2',
    'The ISO 3166-2 code is returned if more than one ISO 3166-1 code is present',
  );
});
