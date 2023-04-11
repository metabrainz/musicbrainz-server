/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {RelationshipEditorActionT} from '../types/actions.js';

/*
 * This syncs the entity name from the form (which is currently not managed
 * by React) into the relationship editor state, which uses the current
 * entity name in edit previews.
 */
export default function useEntityNameFromField(
  entityType: RelatableEntityTypeT,
  nameFieldId: string,
  dispatch: (RelationshipEditorActionT) => void,
  mapName?: (string) => string,
): void {
  React.useEffect(() => {
    const nameField = document.getElementById(nameFieldId);

    const handleNameChange = function (event: InputEvent) {
      // $FlowIgnore[prop-missing]
      let name: string = event.target.value;
      if (mapName) {
        name = mapName(name);
      }
      dispatch({
        type: 'update-entity',
        entityType,
        changes: {name},
      });
    };

    nameField?.addEventListener('input', handleNameChange);

    return function () {
      nameField?.removeEventListener('input', handleNameChange);
    };
  }, [entityType, nameFieldId, dispatch, mapName]);
}
