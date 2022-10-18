/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';

export default function useCatalystUser(): ActiveEditorT {
  const {user} = React.useContext(SanitizedCatalystContext);
  invariant(user, 'user is not defined');
  return user;
}
