/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import {withCatalystContext} from '../../context';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineRemoveFromMergeColumn,
  defineTypeColumn,
  instrumentDescriptionColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +instruments: $ReadOnlyArray<InstrumentT>,
  +mergeForm?: MergeFormT,
  +order?: string,
  +sortable?: boolean,
};

const InstrumentList = ({
  $c,
  checkboxes,
  instruments,
  mergeForm,
  order,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
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
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn({toMerge: instruments})
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        instrumentDescriptionColumn,
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user, checkboxes, instruments, mergeForm, order, sortable],
  );

  return <Table columns={columns} data={instruments} />;
};

export default withCatalystContext(InstrumentList);
