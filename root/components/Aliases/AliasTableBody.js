/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AliasTableRow from './AliasTableRow.js';

component AliasTableBody(
  aliases: $ReadOnlyArray<AnyAliasT>,
  ...rowProps: {
    +allowEditing: boolean,
    +entity: EntityWithAliasesT,
  }
 ) {
  const aliasRows = [];
  for (let i = 0; i < aliases.length; i++) {
    const alias = aliases[i];
    aliasRows.push(
      <AliasTableRow
        alias={alias}
        key={alias.id}
        row={i % 2 ? 'even' : 'odd'}
        {...rowProps}
      />,
    );
  }
  return <tbody>{aliasRows}</tbody>;
}

export default AliasTableBody;
