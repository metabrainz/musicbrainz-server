/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AliasTableBody from './AliasTableBody.js';

component AliasTable(...props: React.PropsOf<AliasTableBody>) {
  return (
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Alias')}</th>
          <th>{l('Sort name')}</th>
          <th>{l('Begin date')}</th>
          <th>{l('End date')}</th>
          <th>{l('Type')}</th>
          <th>{l('Locale')}</th>
          {props.allowEditing
            ? <th className="actions">{l('Actions')}</th>
            : null}
        </tr>
      </thead>
      <AliasTableBody {...props} />
    </table>
  );
}

export default AliasTable;
