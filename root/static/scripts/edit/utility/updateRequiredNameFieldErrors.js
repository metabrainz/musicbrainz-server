/*
 * @flow strict-local
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import isBlank from '../../common/utility/isBlank.js';

export default function updateRequiredNameFieldErrors(
  nameFieldCtx: CowContext<FieldT<string | null>>,
): void {
  if (isBlank(nameFieldCtx.get('value').read())) {
    nameFieldCtx.set('has_errors', true);
    nameFieldCtx.set('pendingErrors', [
      l('Required field.'),
    ]);
  } else {
    nameFieldCtx.set('has_errors', false);
    nameFieldCtx.set('pendingErrors', []);
    nameFieldCtx.set('errors', []);
  }
}
