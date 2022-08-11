/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {Props as FormRowTextProps} from './FormRowText.js';
import FormRowTextLong from './FormRowTextLong.js';

const FormRowEmailLong = (
  props: FormRowTextProps,
): React.Element<typeof FormRowTextLong> => (
  <FormRowTextLong type="email" {...props} />
);

export default FormRowEmailLong;
