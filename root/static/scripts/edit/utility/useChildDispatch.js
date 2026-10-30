/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useCallback} from 'react';

export default function useChildDispatch<ChildAction, const ParentActionType>(
  dispatch: ({
    readonly action: ChildAction,
    readonly type: ParentActionType,
  }) => void,
  parentActionType: ParentActionType,
): (ChildAction) => void {
  return useCallback((action: ChildAction) => {
    dispatch({action, type: parentActionType});
  }, [dispatch, parentActionType]);
}
