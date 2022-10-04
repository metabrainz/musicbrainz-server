#!/usr/bin/env node
/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const path = require('path');

const CDP = require('chrome-remote-interface');
const fileUrl = require('file-url');
const utf8 = require('utf8');

CDP((client) => {
  const {Page, Runtime} = client;

  function getValue(arg) {
    return utf8.encode(arg.value);
  }

  Promise.all([
    Page.enable(),
    Runtime.enable(),
  ]).then(() => {
    let timeout;
    let done = false;

    function exit(code) {
      process.exitCode = code;
      client.close();
    }

    function onTimeout() {
      if (!done) {
        console.error('ERROR: Test timed out');
        exit(2);
      }
    }

    Runtime.consoleAPICalled(function (event) {
      clearTimeout(timeout);

      const args = event.args.map(getValue);
      (console[event.type] || console.log).apply(console, args);

      if (/^\s*# ok\s*$/.test(args[0])) {
        done = true;
        exit(0);
      } else {
        timeout = setTimeout(onTimeout, 1000);
      }
    });

    Runtime.exceptionThrown(function (event) {
      console.error(
        utf8.encode(event.exceptionDetails.exception.description) + '\n',
      );
      exit(1);
    });

    return Page.navigate({
      url: fileUrl(
        path.resolve(__dirname, '../root/static/scripts/tests/web.html'),
      ),
    });
  });
}).on('error', (err) => {
  throw err;
});
