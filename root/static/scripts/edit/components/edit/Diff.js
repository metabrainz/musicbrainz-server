/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {INSERT, DELETE} from '../../utility/editDiff';

import DiffSide from './DiffSide';

export type DiffProps = {
  +label: string,
  +newText: string,
  +oldText: string,
};

type Props = {
  ...DiffProps,
  +split?: string,
};

const Diff = ({
  label,
  newText,
  oldText,
  split = '',
}: Props): React.Element<'tr'> | null => (
  oldText === newText ? null : (
    <tr>
      <th>{label}</th>
      <td className="old">
        <DiffSide
          filter={DELETE}
          newText={newText}
          oldText={oldText}
          split={split}
        />
      </td>
      <td className="new">
        <DiffSide
          filter={INSERT}
          newText={newText}
          oldText={oldText}
          split={split}
        />
      </td>
    </tr>
  )
);

export default Diff;
