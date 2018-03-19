/*
 * @flow
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {l} from '../i18n';
import type {Node as ReactNode} from 'react';

type Args = $Shape<{
  __react: boolean,
}>;

export default function bracketed(text: ?ReactNode, args: Args = {}) {
  if (text) {
    return l(' ({text})', {text, ...args});
  }
  return '';
}
