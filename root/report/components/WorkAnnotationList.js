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
  defineTextHtmlColumn,
  defineTextColumn,
} from '../../utility/tableColumns';
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
      const annotationColumn = defineTextHtmlColumn<ReportWorkAnnotationT>({
        columnName: 'annotation',
        getText: result => result.text,
        title: l('Annotation'),
      });
      const editedColumn = defineTextColumn<ReportWorkAnnotationT>({
        columnName: 'created',
        getText: result => result.created,
        headerProps: {className: 'last-edited-heading'},
        title: l('Last edited'),
      });

      return [
        nameColumn,
        writersColumn,
        typeColumn,
        annotationColumn,
        editedColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingWorkItems} />
    </PaginatedResults>
  );
};

export default WorkAnnotationList;
