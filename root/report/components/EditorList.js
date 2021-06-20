/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import Table from '../../components/Table';
import EditorLink from '../../static/scripts/common/components/EditorLink';
import bracketed from '../../static/scripts/common/utility/bracketed';
import {
  defineTextColumn,
} from '../../utility/tableColumns';
import type {ReportEditorT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportEditorT>,
  +pager: PagerT,
};

const EditorList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingEditorItems = items.reduce((result, item) => {
    if (item.editor != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = {
        Cell: ({row: {original}}) => {
          const editor = original.editor;
          return (
            <>
              <EditorLink editor={editor} />
              {' '}
              {bracketed(
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

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingEditorItems} />
    </PaginatedResults>
  );
};

export default EditorList;
