// Copyright (C) 2015 MetaBrainz Foundation
//
// This file is part of MusicBrainz, the open internet music database,
// and is licensed under the GPL version 2, or (at your option) any
// later version: http://www.gnu.org/licenses/gpl-2.0.txt

const isNodeJS = require('detect-node');
const sliced = require('sliced');

const expand = require('./expand');
const NopArgs = require('./NopArgs');

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

function wrapGettext(method, domain) {
  let domainLoaded = !isNodeJS;

  return function () {
    if (!domainLoaded) {
      gettext.loadDomain(domain);
      domainLoaded = true;
    }

    let args = sliced(arguments);
    const firstArg = args[0];

    if (typeof firstArg === 'object' && firstArg instanceof NopArgs) {
      args = firstArg.args.concat(args.slice(1));
    }

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
    const string = gettext[method].apply(gettext, args);

    if (expandArgs) {
      return expand(string, expandArgs, !!expandArgs.__react);
    }

    return string;
  };
}

module.exports = wrapGettext;
