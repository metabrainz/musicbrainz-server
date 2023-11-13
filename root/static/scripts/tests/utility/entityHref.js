/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import entityHref from '../../common/utility/entityHref.js';

import {
  genericArea,
  genericCDToc,
  genericEditor,
  genericIswc,
} from './constants.js';

test('entityHref', function (t) {
  t.plan(8);

  t.equal(
    entityHref(genericArea),
    '/area/b8aa865e-ffec-4562-b3f3-00c9a603d693',
    'The right path is generated for an area without extra parameters',
  );

  t.equal(
    entityHref(genericArea, 'aliases'),
    '/area/b8aa865e-ffec-4562-b3f3-00c9a603d693/aliases',
    'The right path is generated for an area with a subpath parameter',
  );

  t.equal(
    entityHref(genericArea, '/aliases'),
    '/area/b8aa865e-ffec-4562-b3f3-00c9a603d693/aliases',
    'The right path is still generated if the subpath has a leading slash',
  );

  t.equal(
    entityHref(genericEditor),
    '/user/editor1',
    'The right path is generated for an editor without extra parameters',
  );

  t.equal(
    entityHref(genericEditor, 'tags'),
    '/user/editor1/tags',
    'The right path is generated for an editor with a subpath parameter',
  );

  t.equal(
    entityHref(genericCDToc),
    '/cdtoc/Wt.1HiYD17SbduR39yKqxoZ2o9k-',
    'The right path is generated for a CD TOC without extra parameters',
  );

  t.equal(
    entityHref(genericCDToc, '', 'd2331196-d766-49d5-8896-55abf33251af'),
    '/cdtoc/Wt.1HiYD17SbduR39yKqxoZ2o9k-#d2331196-d766-49d5-8896-55abf33251af',
    'The right path is generated for a CD TOC with an anchor parameter',
  );

  t.equal(
    entityHref(genericIswc),
    '/iswc/T-345246800-1',
    'The right path is generated for an ISWC without extra parameters',
  );
});
