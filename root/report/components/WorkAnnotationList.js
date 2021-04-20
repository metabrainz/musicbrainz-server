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
import {
  defineArtistRolesColumn,
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns';
import useAnnotationColumns from '../hooks/useAnnotationColumns';
import type {ReportWorkAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportWorkAnnotationT>,
  +pager: PagerT,
};

const WorkAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingWorkItems = items.reduce((result, item) => {
    if (item.work != null) {
      result.push(item);
    }
    return result;
  }, []);
  const annotationColumns = useAnnotationColumns();

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportWorkAnnotationT>({
        columnName: 'work',
        getEntity: result => result.work ?? null,
        title: l('Work'),
      });
      const writersColumn = defineArtistRolesColumn<ReportWorkAnnotationT>({
        columnName: 'writers',
        getRoles: result => result.work?.writers ?? [],
        title: l('Writers'),
      });
      const typeColumn = defineTextColumn<ReportWorkAnnotationT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.work?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'work_type')
            : l('Unknown')
          );
        },
        title: l('Type'),
      });

      return [
        nameColumn,
        writersColumn,
        typeColumn,
        ...annotationColumns,
      ];
    },
    [annotationColumns],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingWorkItems} />
    </PaginatedResults>
  );
};

export default WorkAnnotationList;
