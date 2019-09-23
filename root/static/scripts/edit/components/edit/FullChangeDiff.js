/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {type DiffProps} from './Diff';

const FullChangeDiff = ({label, newText, oldText}: DiffProps) => (
  oldText === newText ? null : (
    <tr>
      <th>{label}</th>
      <td className="old">{oldText}</td>
      <td className="new">{newText}</td>
    </tr>
  )
);

export default FullChangeDiff;
