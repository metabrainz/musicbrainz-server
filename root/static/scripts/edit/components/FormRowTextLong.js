/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {Props as FormRowTextProps} from './FormRowText.js';
import FormRowText from './FormRowText.js';

const FormRowTextLong = (
  props: FormRowTextProps,
): React.Element<typeof FormRowText> => (
  <FormRowText size={47} {...props} />
);

export default FormRowTextLong;
