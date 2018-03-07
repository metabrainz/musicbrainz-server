/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');
const AliasTableRow = require('./AliasTableRow');
const {l} = require('../../static/scripts/common/i18n');

type Props = {
  +aliases: $ReadOnlyArray<AliasT>,
  +allowEditing: boolean,
  +entity: $Subtype<CoreEntityT>,
};

const AliasTableBody = ({aliases, ...props}: Props) => {
  const aliasRows = [];
  for (let i = 0; i < aliases.length; i++) {
    const alias = aliases[i];
    aliasRows.push(<AliasTableRow alias={alias} row={i % 2 ? 'even' : 'odd'} {...props} />);
  }
  return <tbody>{aliasRows}</tbody>;
};

module.exports = AliasTableBody;
