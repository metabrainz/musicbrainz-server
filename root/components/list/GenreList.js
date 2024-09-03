/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import useTable from '../../hooks/useTable.js';
import {
  defineCheckboxColumn,
  defineNameColumn,
} from '../../utility/tableColumns.js';

component GenreList(
  checkboxes?: string,
  genres: $ReadOnlyArray<GenreT>,
  order?: string,
  sortable?: boolean,
) {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes))
        ? defineCheckboxColumn({name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<GenreT>({
        order,
        sortable,
        title: l('Genre'),
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
      ];
    },
    [$c.user, checkboxes, order, sortable],
  );

  return useTable<GenreT>({columns, data: genres});
}

export default GenreList;
