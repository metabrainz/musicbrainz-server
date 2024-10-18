/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {ColumnOptions} from 'react-table';

import SortableTableHeader
  from '../../../../components/SortableTableHeader.js';
import type {OrderableProps} from '../../../../utility/tableColumns.js';
import AcoustIdCell from '../components/AcoustIdCell.js';
import NameWithCommentCell from '../components/NameWithCommentCell.js';

/*
 * NOTE: This file is like root/utility/tableColumns.js, but contains columns
 * used on the client. The containing path root/static/scripts/ allows any
 * translated header strings to appear in client Jed bundles.
 */

/* eslint-disable-next-line import/prefer-default-export */
export const acoustIdsColumn:
  ColumnOptions<{+gid?: string, ...}, string> = {
    accessor: x => x.gid ?? '',
    Cell: ({cell: {value}}) => <AcoustIdCell recordingMbid={value} />,
    Header: N_l('AcoustIDs'),
    id: 'acoustid',
  };

export function defineNameAndCommentColumn
  <T: NonUrlRelatableEntityT | CollectionT>(
  props: {
    ...OrderableProps,
    +canEditCollectionComments?: boolean,
    +collectionComments?: {+[entityGid: string]: string},
    +collectionId: number,
    +descriptive?: boolean,
    +showArtworkPresence?: boolean,
    +title: string,
  },
): ColumnOptions<T, string> {
  const descriptive =
    Object.hasOwn(props, 'descriptive')
      ? props.descriptive
      : true;
  return {
    Cell: ({row: {original}}) => (
      <NameWithCommentCell
        canEditCollectionComments={props.canEditCollectionComments}
        collectionComments={props.collectionComments}
        collectionId={props.collectionId}
        descriptive={descriptive}
        entity={original}
        showArtworkPresence={props.showArtworkPresence}
      />
    ),
    Header: (props.sortable /*:: === true */
      ? (
        <SortableTableHeader
          label={props.title}
          name="name"
          order={props.order ?? ''}
        />
      )
      : props.title),
    id: 'name',
  };
}
