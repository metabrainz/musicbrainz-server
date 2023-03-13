#!/usr/bin/env node
/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const readline = require('readline');

const {generateFlowType} = require('../root/utility/generateFlowType');

(async function () {
  console.log(
    await generateFlowType(
      readline.createInterface({
        input: process.stdin,
        terminal: false,
      }),
      {isEditDataTypeInfo: false},
    ),
  );
}()).catch((error: mixed) => {
  throw error;
});
