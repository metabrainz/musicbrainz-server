/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {DELETE, INSERT} from '../../utility/editDiff.js';

import DiffSide from './DiffSide.js';

export type DiffProps = {
  +extraNew?: React.Node,
  +extraOld?: React.Node,
  +label: string,
  +newText: string,
  +oldText: string,
};

type Props = {
  ...DiffProps,
  +split?: string,
};

const Diff = ({
  extraNew,
  extraOld,
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
        {extraOld}
      </td>
      <td className="new">
        <DiffSide
          filter={INSERT}
          newText={newText}
          oldText={oldText}
          split={split}
        />
        {extraNew}
      </td>
    </tr>
  )
);

export default Diff;
