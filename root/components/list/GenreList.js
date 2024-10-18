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
import manifest from '../../static/manifest.mjs';
import {defineNameAndCommentColumn}
  from '../../static/scripts/common/utility/tableColumns.js';
import {
  defineCheckboxColumn,
  defineNameColumn,
} from '../../utility/tableColumns.js';

component GenreList(
  canEditCollectionComments?: boolean,
  checkboxes?: string,
  collectionComments?: {
    +[entityGid: string]: string,
  },
  collectionId?: number,
  genres: $ReadOnlyArray<GenreT>,
  order?: string,
  showCollectionComments: boolean = false,
  sortable?: boolean,
) {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes))
        ? defineCheckboxColumn({name: checkboxes})
        : null;
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<GenreT>({
          canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId,
          order,
          sortable,
          title: l('Genre'),
        })
      ) : (
        defineNameColumn<GenreT>({
          order,
          sortable,
          title: l('Genre'),
        })
      );

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
      ];
    },
    [$c.user, checkboxes, order, sortable],
  );

  const table = useTable<GenreT>({columns, data: genres});

  return (
    <>
      {table}
      {manifest('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
}

export default GenreList;
