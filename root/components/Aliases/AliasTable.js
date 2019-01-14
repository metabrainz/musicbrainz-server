/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../../static/scripts/common/i18n';

import AliasTableBody from './AliasTableBody';

type Props = {
  +aliases: $ReadOnlyArray<AliasT>,
  +allowEditing: boolean,
  +entity: CoreEntityT,
};

const AliasTable = (props: Props) => (
  <table className="tbl">
    <thead>
      <tr>
        <th>{l('Alias')}</th>
        <th>{l('Sort name')}</th>
        <th>{l('Begin Date')}</th>
        <th>{l('End Date')}</th>
        <th>{l('Type')}</th>
        <th>{l('Locale')}</th>
        {props.allowEditing
          ? <th className="actions-header">{l('Actions')}</th>
          : null}
      </tr>
    </thead>
    <AliasTableBody {...props} />
  </table>
);

export default AliasTable;
