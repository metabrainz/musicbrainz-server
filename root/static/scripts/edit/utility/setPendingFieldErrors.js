/*
 * @flow strict-local
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import {arraysEqual} from '../../common/utility/arrays.js';

export default function setPendingFieldErrors(
  fieldCtx: CowContext<AnyFieldT>,
  pendingErrors: ReadonlyArray<string>,
): void {
  const field = fieldCtx.read();
  const unfixedErrors = field.errors.filter(
    (error) => pendingErrors.includes(error),
  );
  if (unfixedErrors.length !== field.errors.length) {
    fieldCtx.set('errors', unfixedErrors);
  }
  if (!arraysEqual(field.pendingErrors ?? [], pendingErrors)) {
    fieldCtx.set('pendingErrors', pendingErrors);
  }
  fieldCtx.set('has_errors', pendingErrors.length > 0);
}
