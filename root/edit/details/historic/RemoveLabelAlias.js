/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Props = {
  +edit: RemoveLabelAliasHistoricEditT,
};

const RemoveLabelAlias = ({edit}: Props): React$Element<'table'> => (
  <table className="details remove-label-alias">
    <tr>
      <th>{l('Alias:')}</th>
      <td>{edit.display_data.alias}</td>
    </tr>
  </table>
);

export default RemoveLabelAlias;
