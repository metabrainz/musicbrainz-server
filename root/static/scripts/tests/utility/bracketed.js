/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {isValidElement} from 'react';
import test from 'tape';

import bracketed, {bracketedText} from '../../common/utility/bracketed.js';
import renderToStaticMarkup from '../renderToStaticMarkup.js';

test('bracketed', function (t) {
  t.plan(9);

  t.equal(
    bracketed('Text'),
    '(Text)',
    'Passed string is returned inside () with no type argument',
  );

  t.equal(
    bracketed('Text', {type: '()'}),
    '(Text)',
    'Passed string is returned inside () when () specified as type',
  );

  t.equal(
    bracketed('Text', {type: '[]'}),
    '[Text]',
    'Passed string is returned inside [] when [] specified as type',
  );

  const spanNoType = bracketed(<span>{'Text'}</span>);

  t.ok(
    isValidElement(spanNoType),
    'Passed span is returned as a React element with no type argument',
  );

  t.equal(
    renderToStaticMarkup(spanNoType),
    '(<span>Text</span>)',
    'Passed span is returned inside () with no type argument',
  );

  const spanParenType = bracketed(<span>{'Text'}</span>, {type: '()'});

  t.ok(
    isValidElement(spanParenType),
    'Passed span is returned as a React element when () specified as type',
  );

  t.equal(
    renderToStaticMarkup(spanParenType),
    '(<span>Text</span>)',
    'Passed span is returned inside () when () specified as type',
  );

  const spanSquareType = bracketed(<span>{'Text'}</span>, {type: '[]'});

  t.ok(
    isValidElement(spanSquareType),
    'Passed span is returned as a React element when [] specified as type',
  );

  t.equal(
    renderToStaticMarkup(spanSquareType),
    '[<span>Text</span>]',
    'Passed span is returned inside [] when [] specified as type',
  );
});

test('bracketedText', function (t) {
  t.plan(3);

  t.equal(
    bracketedText('Text'),
    '(Text)',
    'Passed string is returned inside () with no type argument',
  );

  t.equal(
    bracketedText('Text', {type: '()'}),
    '(Text)',
    'Passed string is returned inside () when () specified as type',
  );

  t.equal(
    bracketedText('Text', {type: '[]'}),
    '[Text]',
    'Passed string is returned inside [] when [] specified as type',
  );
});
