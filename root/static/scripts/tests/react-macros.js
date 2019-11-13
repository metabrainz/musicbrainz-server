/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

'use strict';

require('@babel/register');

const global = require('../global').default;

let document = global.document;
if (!document) {
  document = new (require('jsdom').JSDOM)('').window.document;
}

const React = require('react');
const ReactDOMServer = require('react-dom/server');

/* eslint-disable no-unused-vars */

const DescriptiveLink = require('../common/components/DescriptiveLink').default;
const EditorLink = require('../common/components/EditorLink').default;
const EntityLink = require('../common/components/EntityLink').default;
const l = require('../common/i18n').l;
const diffArtistCredits = require('../edit/utility/diffArtistCredits').default;
const Diff = require('../edit/components/edit/Diff').default;
const FullChangeDiff = require('../edit/components/edit/FullChangeDiff').default;
const WordDiff = require('../edit/components/edit/WordDiff').default;

/* eslint-enable no-unused-vars */

function throwNotEquivalent(message, got, expected) {
  throw {message: message, got: got, expected: expected};
}

function formatException(e) {
  return [e.message + ':', 'Got:', e.got, 'Expected:', e.expected].join('\n');
}

function attributesDiffer(a /* got */, b /* expected */) {
  if (a.attributes.length !== b.attributes.length) {
    return true;
  }

  for (let i = 0; i < a.attributes.length; i++) {
    const attrA = a.attributes.item(i);
    const attrB = b.attributes.getNamedItem(attrA.name);

    if (!attrA !== !attrB) {
      return true;
    }

    if (attrA.value !== attrB.value) {
      return true;
    }
  }

  return false;
}

function removeComments(parentNode) {
  const childNodes = Array.prototype.slice.call(parentNode.childNodes, 0);
  childNodes.forEach(node => {
    if (node.nodeType === 8) {
      parentNode.removeChild(node);
    }
  });
}

function compareNodes(a, b) {
  if (a.nodeType !== b.nodeType) {
    throwNotEquivalent('Different node types', a.outerHTML, b.outerHTML);
  }

  if (a.nodeType === 1) { // element
    // strip comments added by react
    removeComments(a);
    removeComments(b);

    // merge adjacent text nodes
    a.normalize();
    b.normalize();

    if (a.childNodes.length !== b.childNodes.length) {
      throwNotEquivalent('Different number of children', a.outerHTML, b.outerHTML);
    }

    if (attributesDiffer(a, b)) {
      throwNotEquivalent('Different attributes', a.outerHTML, b.outerHTML);
    }

    for (let i = 0; i < a.childNodes.length; i++) {
      compareNodes(a.childNodes[i], b.childNodes[i]);
    }
  }

  if (a.nodeType === 3) { // text
    // collapse whitespace
    const textA = a.textContent.replace(/\s{2,}/g, ' ');
    const textB = b.textContent.replace(/\s{2,}/g, ' ');

    if (textA !== textB) {
      throwNotEquivalent(
        'Different text content',
        JSON.stringify(textA),
        JSON.stringify(textB),
      );
    }
  }
}

function compareHTML(markupA /* got */, markupB /* expected */) {
  const a = document.createElement('div');
  const b = document.createElement('div');

  a.innerHTML = markupA;
  b.innerHTML = markupB;

  compareNodes(a, b);
}

const testData = JSON.parse(process.argv[2]);
const testResults = [];

testData.forEach(function (test) {
  const entity = test.entity;

  const ttMarkup = test.tt_markup
    .replace(/<tr>\s+<(td|th)>/g, '<tr><$1>')
    .replace(/<\/(td|th)>\s+<(td|th)/g, '</$1><$2')
    .replace(/<\/(td|th)>\s+<\/tr>/g, '</$1></tr>')
    .replace('&#39;', '&#x27;');

  const reactMarkup =
    ReactDOMServer.renderToStaticMarkup(
      React.createElement('div', null, eval(test.react_element)),
    )
    .replace(/^<div>(.*)<\/div>$/, '$1')
    .replace(/([^\s])\/>/g, '$1 />');

  const testCases = [
    {
      got: ttMarkup,
      failMessage: 'TT markup does not match what was expected',
    },
    {
      got: reactMarkup,
      failMessage: 'React markup does not match what was expected',
    },
  ];

  testCases.forEach(function (testCase) {
    try {
      compareHTML(testCase.got, test.expected_markup);
      testResults.push('ok');
    } catch (e) {
      let prefix = '';

      if (e.got !== testCase.got && e.expected !== test.expected_markup) {
        prefix = formatException({
          message: testCase.failMessage,
          got: testCase.got,
          expected: test.expected_markup,
        }) + '\n';
      } else {
        prefix = testCase.failMessage + ':\n';
      }

      testResults.push(prefix + formatException(e));
    }
  });
});

// eslint-disable-next-line no-console
console.log(JSON.stringify(testResults));
