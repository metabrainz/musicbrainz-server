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
  defineEntityColumn,
  defineTextHtmlColumn,
  defineTextColumn,
} from '../../utility/tableColumns';
import type {ReportSeriesAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportSeriesAnnotationT>,
  +pager: PagerT,
};

const SeriesAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingSeriesItems = items.reduce((result, item) => {
    if (item.series != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportSeriesAnnotationT>({
        columnName: 'series',
        getEntity: result => result.series ?? null,
        title: l('Series'),
      });
      const annotationColumn = defineTextHtmlColumn<ReportSeriesAnnotationT>({
        columnName: 'annotation',
        getText: result => result.text,
        title: l('Annotation'),
      });
      const editedColumn = defineTextColumn<ReportSeriesAnnotationT>({
        columnName: 'created',
        getText: result => result.created,
        headerProps: {className: 'last-edited-heading'},
        title: l('Last edited'),
      });

      return [
        nameColumn,
        annotationColumn,
        editedColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingSeriesItems} />
    </PaginatedResults>
  );
};

export default SeriesAnnotationList;
