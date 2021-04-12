/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import {
  defineCheckboxColumn,
  defineCollectionCommentsColumn,
  defineNameColumn,
  defineTypeColumn,
  instrumentDescriptionColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns';

type Props = {
  ...CollectionCommentsRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +instruments: $ReadOnlyArray<InstrumentT>,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showCollectionComments?: boolean,
  +sortable?: boolean,
};

const InstrumentList = ({
  $c,
  checkboxes,
  collectionComments,
  instruments,
  mergeForm,
  order,
  showCollectionComments = false,
  sortable,
}: Props): React.Element<typeof Table> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<InstrumentT>({
        order: order,
        sortable: sortable,
        title: l('Instrument'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'instrument_type',
      });
      const collectionCommentsColumn = showCollectionComments
        ? defineCollectionCommentsColumn({
          collectionComments: collectionComments,
        })
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        instrumentDescriptionColumn,
        ...(collectionCommentsColumn ? [collectionCommentsColumn] : []),
        ...(mergeForm && instruments.length > 2
          ? [removeFromMergeColumn]
          : []),
      ];
    },
    [
      $c.user,
      collectionComments,
      checkboxes,
      instruments,
      mergeForm,
      order,
      showCollectionComments,
      sortable,
    ],
  );

  return <Table columns={columns} data={instruments} />;
};

export default InstrumentList;
