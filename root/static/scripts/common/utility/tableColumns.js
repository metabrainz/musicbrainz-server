/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {ColumnOptions} from 'react-table';

import AcoustIdCell from '../components/AcoustIdCell.js';

/*
 * NOTE: This file is like root/utility/tableColumns.js, but contains columns
 * used on the client. The containing path root/static/scripts/ allows any
 * translated header strings to appear in client Jed bundles.
 */

export const acoustIdsColumn:
  ColumnOptions<{+gid?: string, ...}, string> = {
    accessor: x => x.gid ?? '',
    Cell: ({cell: {value}}) => <AcoustIdCell recordingMbid={value} />,
    Header: N_l('AcoustIDs'),
    id: 'acoustid',
  };
