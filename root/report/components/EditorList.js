/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../static/scripts/common/i18n';
import PaginatedResults from '../../components/PaginatedResults';
import EditorLink from '../../static/scripts/common/components/EditorLink';
import loopParity from '../../utility/loopParity';
import type {ReportEditorT} from '../types';

const EditorList = ({items, pager}: {items: $ReadOnlyArray<ReportEditorT>, pager: PagerT}) => (
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
          { /* Hack to make this linkable with EditorLink */ }
          { /* $FlowFixMe */ }
          item.entityType = 'editor';
          return (
            <tr className={loopParity(index)} key={item.name}>
              <td>
                <EditorLink editor={item} />
                {' ('}
                <a href={'/admin/user/delete/' + item.name}>{l('delete')}</a>
                {')'}
              </td>
              <td>{item.member_since}</td>
              <td>{item.website}</td>
              <td>{item.email}</td>
              <td>{item.bio}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  </PaginatedResults>
);
export default EditorList;
