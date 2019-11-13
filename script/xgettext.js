#!/usr/bin/env node
/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2018 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const fs = require('fs');
const path = require('path');

const rootPath = path.resolve(__dirname, '..');

require('@babel/register')({
  /*
   * Needed to allow executing this script with po/ as the cwd.
   * https://github.com/babel/babel/issues/8321
   */
  ignore: [/node_modules/],
  only: [rootPath],
  root: rootPath,
});

const gettextParser = require('gettext-parser');
const has = require('lodash/has');
const XGettext = require('xgettext-js');
const argv = require('yargs').argv;

const cleanMsgid = require('../root/static/scripts/common/i18n/cleanMsgid').default;

const PO_DIR = path.resolve(__dirname, '../po');

const translations = {};

const potFile = {
  charset: 'utf-8',

  headers: {
    'project-id-version': 'PACKAGE VERSION',
    'report-msgid-bugs-to': '',
    'po-revision-date': 'YEAR-MO-DA HO:MI+ZONE',
    'last-translator': 'FULL NAME <EMAIL@ADDRESS>',
    'language-team': 'LANGUAGE <LL@li.org>',
    'language': '',
    'mime-version': '1.0',
    'content-type': 'text/plain; charset=UTF-8',
    'content-transfer-encoding': '8bit',
    'plural-forms': 'nplurals=INTEGER; plural=EXPRESSION;',
  },

  translations,
};

function extractStringLiteral(node) {
  switch (node.type) {
    case 'StringLiteral':
      return node.value;

    case 'TemplateLiteral':
      if (node.expressions.length) {
        throw new Error('Error: Template literals are not allowed to contain expressions');
      }
      return node.quasis[0].value.cooked;

    // Handle string concatenation
    case 'BinaryExpression':
      if (node.operator !== '+') {
        return null;
      }
      const left = extractStringLiteral(node.left);
      if (left === null) {
        return null;
      }
      const right = extractStringLiteral(node.right);
      if (right === null) {
        return null;
      }
      return left + right;

    default:
      return null;
  }
}

function extractMsg(node) {
  const msgid = extractStringLiteral(node);
  if (msgid === null) {
    return null;
  }
  return cleanMsgid(msgid);
}

let currentFile;
let nextMsgIndex = 0;

const getReference = node => (
  path.relative(PO_DIR, currentFile) +
  ':' +
  String(node.loc.start.line)
);

const getComments = node => ({reference: getReference(node)});
const msgOrdering = new WeakMap();

const addMsg = (data) => {
  const msgid = data.msgid;
  const msgctxt = data.msgctxt || '';

  if (!has(translations, msgctxt)) {
    translations[msgctxt] = {};
  }

  const prev = translations[msgctxt][msgid];
  if (prev) {
    prev.comments.reference += '\n' + data.comments.reference;
    if (data.msgid_plural !== prev.msgid_plural) {
      console.warn(
        `Warning: Plural forms differ ` +
        `(${JSON.stringify(prev.msgid_plural)} vs. ` +
        `${JSON.stringify(data.msgid_plural)}):`,
        prev,
      );
    }
  } else {
    translations[msgctxt][msgid] = data;
    msgOrdering.set(data, nextMsgIndex++);
  }
};

const catchErrors = cb => {
  return match => {
    try {
      cb(match);
    } catch (err) {
      console.error
        (`Bad string in ${JSON.stringify(currentFile)}:`,
        match,
      );
      throw err;
    }
  };
};

const keywords = {
  N_l: match => keywords.l(match),
  N_ln: match => keywords.ln(match),
  N_lp: match => keywords.lp(match),

  l: catchErrors(function (match) {
    const [arg0] = match.arguments;

    if (!arg0) {
      throw new Error('Error: First argument (msgid) is missing');
    }

    const msgid = extractMsg(arg0);

    // l(var) will return null, e.g.
    if (msgid !== null) {
      addMsg({
        comments: getComments(arg0),
        msgid,
      });
    }
  }),

  ln: catchErrors(function (match) {
    const [arg0, arg1] = match.arguments;

    if (!arg0) {
      throw new Error('Error: First argument (msgid) is missing');
    }

    if (!arg1) {
      throw new Error('Error: Second argument (msgid_plural) is missing');
    }

    const msgid = extractMsg(arg0);
    const msgidPlural = extractMsg(arg1);

    if (msgid !== null && msgidPlural !== null) {
      addMsg({
        comments: getComments(arg0),
        msgid,
        msgid_plural: msgidPlural,
        msgstr: ['', ''],
      });
    }
  }),

  lp: catchErrors(function (match) {
    const [arg0, arg1] = match.arguments;

    if (!arg0) {
      throw new Error('Error: First argument (msgid) is missing');
    }

    if (!arg1) {
      throw new Error('Error: Second argument (msgctxt) is missing');
    }

    const msgid = extractMsg(arg0);
    const msgctxt = extractMsg(arg1);

    if (msgid !== null && msgctxt !== null) {
      addMsg({
        comments: getComments(arg0),
        msgctxt,
        msgid,
      });
    }
  }),
};

const parser = new XGettext({
  keywords,
  parseOptions: {
    plugins: [
      'jsx',
      'flow',
      'dynamicImport',
      'classProperties',
      'optionalChaining',
      'nullishCoalescingOperator',
    ],
    sourceType: 'unambiguous',
  },
});

for (currentFile of argv._) {
  currentFile = path.resolve(process.cwd(), currentFile);
  const fp = fs.readFileSync(currentFile);
  try {
    parser.getMatches(fp.toString('utf-8'));
  } catch (err) {
    console.error(`Error parsing ${JSON.stringify(currentFile)}:`);
    throw err;
  }
}

// eslint-disable-next-line no-console
console.log(
  gettextParser.po
    .compile(potFile, {
      sort: function (a, b) {
        return msgOrdering.get(a) - msgOrdering.get(b);
      },
    })
    .toString('utf-8')
);
