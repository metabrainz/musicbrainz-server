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
} from '../../utility/tableColumns';
import useAnnotationColumns from '../hooks/useAnnotationColumns';
import type {ReportPlaceAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportPlaceAnnotationT>,
  +pager: PagerT,
};

const PlaceAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingPlaceItems = items.reduce((result, item) => {
    if (item.place != null) {
      result.push(item);
    }
    return result;
  }, []);
  const annotationColumns = useAnnotationColumns();

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportPlaceAnnotationT>({
        columnName: 'place',
        getEntity: result => result.place ?? null,
        title: l('Place'),
      });

      return [
        nameColumn,
        ...annotationColumns,
      ];
    },
    [annotationColumns],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingPlaceItems} />
    </PaginatedResults>
  );
};

export default PlaceAnnotationList;
