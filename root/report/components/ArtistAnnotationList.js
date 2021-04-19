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
import type {ReportArtistAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportArtistAnnotationT>,
  +pager: PagerT,
};

const ArtistAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingArtistItems = items.reduce((result, item) => {
    if (item.artist != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportArtistAnnotationT>({
        columnName: 'artist',
        getEntity: result => result.artist ?? null,
        title: l('Artist'),
      });
      const typeColumn = defineTextColumn<ReportArtistAnnotationT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.artist?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'artist_type')
            : l('Unknown')
          );
        },
        title: l('Type'),
      });
      const annotationColumn = defineTextHtmlColumn<ReportArtistAnnotationT>({
        columnName: 'annotation',
        getText: result => result.text,
        title: l('Annotation'),
      });
      const editedColumn = defineTextColumn<ReportArtistAnnotationT>({
        columnName: 'created',
        getText: result => result.created,
        headerProps: {className: 'last-edited-heading'},
        title: l('Last edited'),
      });

      return [
        nameColumn,
        typeColumn,
        annotationColumn,
        editedColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingArtistItems} />
    </PaginatedResults>
  );
};

export default ArtistAnnotationList;
