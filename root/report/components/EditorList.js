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
import EditorLink from '../../static/scripts/common/components/EditorLink';
import bracketed from '../../static/scripts/common/utility/bracketed';
import loopParity from '../../utility/loopParity';
import type {ReportEditorT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportEditorT>,
  +pager: PagerT,
};

const EditorList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Editor')}</th>
          <th>{l('Member since')}</th>
          <th>{l('Website')}</th>
          <th>{l('Email')}</th>
          <th>{l('Bio')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => {
          const editor = item.editor;
          if (!editor) {
            return null;
          }
          return (
            <tr className={loopParity(index)} key={editor.name}>
              <td>
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
              </td>
              <td>{editor.registration_date}</td>
              <td>{editor.website}</td>
              <td>{editor.email}</td>
              <td>{editor.biography}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  </PaginatedResults>
);

export default EditorList;
