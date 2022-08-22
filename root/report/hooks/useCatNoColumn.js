/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptionsNoValue} from 'react-table';

import {
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportReleaseCatNoT} from '../types.js';

function useCatNoColumn<
  D: $ReadOnly<{...ReportReleaseCatNoT, ...}>,
>(): $ReadOnlyArray<ColumnOptionsNoValue<D>> {
  const columns = React.useMemo(
    () => {
      const catNoColumn = defineTextColumn<D>({
        columnName: 'catalog-number',
        getText: result => result.catalog_number,
        title: l('Catalog Number'),
      });


      return [
        catNoColumn,
      ];
    },
    [],
  );

  return columns;
}

export default useCatNoColumn;
