/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import WarningIcon from '../../edit/components/WarningIcon';

type Props = {|
  +className?: string,
  +message: string,
|};

const Warning = ({
  className,
  message,
  ...divProps
}: Props) => (
  <div className={'warning' + (className ? ' ' + className : '')} {...divProps}>
    <WarningIcon />
    <p>
      <strong>{addColon(l('Warning'))}</strong>
      {message}
    </p>
  </div>
);

export default Warning;
