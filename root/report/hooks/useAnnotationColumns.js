/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptions} from 'react-table';

import {
  defineTextColumn,
  defineTextHtmlColumn,
} from '../../utility/tableColumns.js';
import type {ReportAnnotationRoleT} from '../types.js';

function useAnnotationColumns<
  D: $ReadOnly<{...ReportAnnotationRoleT, ...}>,
>(): $ReadOnlyArray<ColumnOptions<D, StrOrNum>> {
  const columns = React.useMemo(
    () => {
      const annotationColumn =
        defineTextHtmlColumn<D>({
          columnName: 'annotation',
          getText: result => result.text,
          title: l('Annotation'),
        });
      const editedColumn = defineTextColumn<D>({
        columnName: 'created',
        getText: result => result.created,
        headerProps: {className: 'last-edited-heading'},
        title: l('Last edited'),
      });

      return [
        annotationColumn,
        editedColumn,
      ];
    },
    [],
  );

  return columns;
}

export default useAnnotationColumns;
