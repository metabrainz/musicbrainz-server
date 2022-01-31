/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import WarningIcon from './WarningIcon';

type Props = {
  +className?: string,
  +message: string,
};

const Warning = ({
  className,
  message,
  ...divProps
}: Props): React.Element<'div'> => (
  <div
    className={'warning' + (nonEmpty(className) ? ' ' + className : '')}
    {...divProps}
  >
    <WarningIcon />
    <p>
      <strong>{addColonText(l('Warning'))}</strong>
      {' '}
      {message}
    </p>
  </div>
);

export default Warning;
