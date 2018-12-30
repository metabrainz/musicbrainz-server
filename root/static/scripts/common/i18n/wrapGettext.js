// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const isNodeJS = require('detect-node');
const sliced = require('sliced');

const cleanMsgid = require('./cleanMsgid').default;
const expand2 = require('./expand2').default;

let gettext;
if (isNodeJS) {
  // Avoid bundling this module in the browser by using a dynamic require().
  const gettextPath = '../../../../server/gettext';
  gettext = require(gettextPath);
} else {
  const Jed = require('jed');
  const jedData = require('./jedData');
  // jedData contains all domains used by the client.
  gettext = new Jed(jedData[jedData.locale]);
}

const canLoadDomain = typeof gettext.loadDomain === 'function';

/*
 * /script/xgettext.js will strip newlines and collapse adjacent
 * whitespace when extracting strings into .pot files. Yet the string
 * in the source code obviously remains unchanged. So to make sure we
 * look up the correct key, we have to apply the same whitespace
 * transformation here. The key/msgid's argument position depends on
 * which method we're wrapping.
 */
const MSGID_ARG_POSITIONS = new Map([
  ['gettext', 0],
  ['dgettext', 1],
  ['dcgettext', 1],
  ['ngettext', 0],
  ['dngettext', 1],
  ['dcngettext', 1],
  ['pgettext', 1],
  ['dpgettext', 2],
  ['npgettext', 1],
  ['dnpgettext', 2],
  ['dcnpgettext', 2],
]);

function wrapGettext(method, domain) {
  return function () {
    if (canLoadDomain && !gettext.options.locale_data[domain]) {
      gettext.loadDomain(domain);
    }

    let args = sliced(arguments);
    let expandArgs = args[args.length - 1];
    if (expandArgs && typeof expandArgs === 'object') {
      args.pop();
    } else {
      expandArgs = null;
    }

    if (method === 'dpgettext') {
      // Swap order of context, msgid.
      [args[0], args[1]] = [args[1], args[0]];
    }

    args.unshift(domain);

    // See comment for MSGID_ARG_POSITIONS above.
    const msgidArg = MSGID_ARG_POSITIONS.get(method);
    args[msgidArg] = cleanMsgid(args[msgidArg]);

    const string = gettext[method].apply(gettext, args);
    return expand2(string, expandArgs);
  };
}

module.exports = wrapGettext;
