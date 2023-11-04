/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {isValidElement} from 'react';
import test from 'tape';

import isolateText from '../../common/utility/isolateText.js';
import renderToStaticMarkup from '../renderToStaticMarkup.js';

test('isolateText', function (t) {
  t.plan(5);

  t.equal(
    isolateText(null),
    '',
    'The empty string is returned if null is passed',
  );

  t.equal(
    isolateText(undefined),
    '',
    'The empty string is returned if undefined is passed',
  );

  t.equal(
    isolateText(''),
    '',
    'The empty string is returned if an empty string is passed',
  );

  const isolatedText = isolateText('texty text');
  t.ok(
    isValidElement(isolatedText),
    'Passing a non-empty string returns a React element',
  );

  t.equal(
    renderToStaticMarkup(isolatedText),
    '<bdi>texty text</bdi>',
    'The string we passed is enclosed in bdi tags',
  );
});
