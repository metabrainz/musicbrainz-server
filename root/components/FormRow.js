/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import type {Node as ReactNode} from 'react';

type Props = {
  +children: ReactNode,
  +hasNoLabel?: boolean,
};

const FormRow = ({children, hasNoLabel, ...props}: Props) => (
  <div className={'row' + (hasNoLabel ? ' no-label' : '')} {...props}>
    {children}
  </div>
);

export default FormRow;
