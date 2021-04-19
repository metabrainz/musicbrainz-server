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
  defineArtistCreditColumn,
  defineEntityColumn,
  defineTextHtmlColumn,
  defineTextColumn,
} from '../../utility/tableColumns';
import type {ReportReleaseAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseAnnotationT>,
  +pager: PagerT,
};

const ReleaseAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingReleaseItems = items.reduce((result, item) => {
    if (item.release != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const releaseColumn = defineEntityColumn<ReportReleaseAnnotationT>({
        columnName: 'release',
        descriptive: false,
        getEntity: result => result.release ?? null,
        title: l('Release'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportReleaseAnnotationT>({
          columnName: 'artist',
          getArtistCredit: result => result.release?.artistCredit ?? null,
          title: l('Artist'),
        });
      const annotationColumn =
        defineTextHtmlColumn<ReportReleaseAnnotationT>({
          columnName: 'annotation',
          getText: result => result.text,
          title: l('Annotation'),
        });
      const editedColumn = defineTextColumn<ReportReleaseAnnotationT>({
        columnName: 'created',
        getText: result => result.created,
        headerProps: {className: 'last-edited-heading'},
        title: l('Last edited'),
      });

      return [
        releaseColumn,
        artistCreditColumn,
        annotationColumn,
        editedColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseItems} />
    </PaginatedResults>
  );
};

export default ReleaseAnnotationList;
