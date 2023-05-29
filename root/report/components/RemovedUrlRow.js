/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const RemovedUrlRow = ({
  colSpan,
  index,
}: {colSpan: string, index: number}): React$Element<'tr'> => (
  <tr className="even" key={index}>
    <td colSpan={colSpan}>
      {l('This URL no longer exists.')}
    </td>
  </tr>
);

export default RemovedUrlRow;
