#!./bin/sucrase-node
/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import pg from 'pg';
import Cursor from 'pg-cursor';
import yargs from 'yargs';

import * as DBDefs from '../root/static/scripts/common/DBDefs.mjs';
import {generateFlowType} from '../root/utility/generateFlowType.js';

yargs
  .option('edit-type', {
    describe: 'Specifies the edit type number to generate a Flow type for.',
    type: 'number',
  })
  .required('edit-type');

(async function () {
  const pgClient = new pg.Client(DBDefs.DATABASES.PROD_STANDBY);
  await pgClient.connect();

  class SingleColumnCursor extends Cursor<string> {
    constructor(
      config: string,
      values: $ReadOnlyArray<mixed>,
    ) {
      super(config, values);
      this._result.parseRow = function (rowData) {
        return rowData[0];
      };
    }
  }

  await pgClient.query<string>('BEGIN');
  await pgClient.query<string>('SET LOCAL statement_timeout = 0');

  const cursor = pgClient.query(
    new SingleColumnCursor(
      'SELECT DISTINCT edit_data_type_info(ed.data) ' +
        'FROM edit_data ed ' +
        'JOIN edit e ON e.id = ed.edit ' +
       'WHERE e.type = $1',
      [yargs.argv['edit-type']],
    ),
  );

  const createIterator = () => {
    let buffer: Array<string> | null = [];
    let index = 0;
    const it: AsyncIterator<string> = {
      /*:: @@asyncIterator: function () { return it; }, */
      async next() {
        if (buffer == null) {
          return {done: true};
        }
        if (index < buffer.length) {
          return {
            done: false,
            value: buffer[index++],
          };
        }
        return new Promise<IteratorResult<string, void>>((
          resolve,
          reject,
        ) => {
          cursor.read(500, (err, rows) => {
            if (err) {
              reject(err);
            } else if (rows.length) {
              buffer = rows;
              index = 0;
              resolve({
                done: false,
                value: buffer[index++],
              });
            } else {
              buffer = null;
              resolve({done: true});
            }
          });
        });
      },
    };
    return it;
  };

  const objectStrings = {
    // $FlowIssue[prop-missing]
    [Symbol.asyncIterator]: createIterator,
    /*:: @@asyncIterator: createIterator, */
  };

  console.log(await generateFlowType(objectStrings, {
    isEditDataTypeInfo: true,
  }));

  await pgClient.query<string>('ROLLBACK');
  await pgClient.end();
}());
