/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component RemoveLabelAlias(edit: RemoveLabelAliasHistoricEditT) {
  return (
    <table className="details remove-label-alias">
      <tr>
        <th>{addColonText(l('Alias'))}</th>
        <td>{edit.display_data.alias}</td>
      </tr>
    </table>
  );
}

export default RemoveLabelAlias;
