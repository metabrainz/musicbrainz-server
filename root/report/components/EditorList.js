/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {CellRenderProps} from 'react-table';

import PaginatedResults from '../../components/PaginatedResults.js';
import useTable from '../../hooks/useTable.js';
import EditorLink from '../../static/scripts/common/components/EditorLink.js';
import bracketed from '../../static/scripts/common/utility/bracketed.js';
import {
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportEditorT} from '../types.js';

type Props = {
  +items: $ReadOnlyArray<ReportEditorT>,
  +pager: PagerT,
};

const EditorList = ({
  items,
  pager,
}: Props): React$Element<typeof PaginatedResults> => {
  const existingEditorItems = items.reduce((
    result: Array<ReportEditorT>,
    item,
  ) => {
    if (item.editor != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = {
        Cell: ({
          row: {original},
        }: CellRenderProps<ReportEditorT, ?EditorT>) => {
          const editor = original.editor;
          return (
            <>
              <EditorLink editor={editor} />
              {' '}
              {editor == null ? null : bracketed(
                <a
                  href={'/admin/user/delete/' +
                  encodeURIComponent(editor.name)}
                >
                  {l('delete')}
                </a>,
              )}
            </>
          );
        },
        Header: l('Editor'),
        id: 'editor',
      };
      const memberSinceColumn = defineTextColumn<ReportEditorT>({
        columnName: 'registration_date',
        getText: result => result.editor?.registration_date ?? '',
        title: l('Member since'),
      });
      const websiteColumn = defineTextColumn<ReportEditorT>({
        columnName: 'website',
        getText: result => result.editor?.website ?? '',
        title: l('Website'),
      });
      const emailColumn = defineTextColumn<ReportEditorT>({
        columnName: 'email',
        getText: result => result.editor?.email ?? '',
        title: l('Email'),
      });
      const bioColumn = defineTextColumn<ReportEditorT>({
        columnName: 'biography',
        getText: result => result.editor?.biography ?? '',
        title: l('Bio'),
      });

      return [
        nameColumn,
        memberSinceColumn,
        websiteColumn,
        emailColumn,
        bioColumn,
      ];
    },
    [],
  );

  const table = useTable<ReportEditorT>({
    columns,
    data: existingEditorItems,
  });

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
};

export default EditorList;
