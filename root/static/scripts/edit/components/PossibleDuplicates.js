/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink from '../../common/components/EntityLink.js';

type StateT<T: ArtistT | LabelT> = {
  +commentEmpty: boolean,
  +commentRequired: boolean,
  +duplicates: Array<T>,
  +entityType: T['entityType'],
  +isConfirmed: boolean,
  +name: string,
  +needsConfirmation: boolean,
  +requestPending: boolean,
};


export function createInitialState(
  initialState: StateT,
): {...StateT} {
  const {
    commentEmpty,
    commentRequired,
    duplicates: [],
    entityType,
    isConfirmed,
    name,
    needsConfirmation,
    requestPending,
  } = initialState;

  const inputValue =
    initialInputValue ??
    (selectedItem == null ? null : unwrapNl<string>(selectedItem.name)) ??
    '';

  if (staticItems) {
    indexItems(staticItems, extractSearchTerms);
  }

  let staticResults = staticItems ?? null;
  if (staticResults && nonEmpty(inputValue)) {
    staticResults = searchItems(staticResults, inputValue);
  }

  const state: {...StateT} = {
    commentEmpty,
    commentRequired,
    duplicates: [],
    entityType,
    isConfirmed,
    name,
    needsConfirmation,
    requestPending: false,
  };

  state.items = generateItems(state);
  state.statusMessage = generateStatusMessage(state);

  return state;
}

component PossibleDuplicates(
  duplicates: $ReadOnlyArray<EditableEntityT>,
  name: string,
  onCheckboxChange: (event: SyntheticEvent<HTMLInputElement>) => void,
) {
  return (
    <div>
      <h3>{l('Possible duplicates')}</h3>
      <p>{l('We found the following entities with very similar names:')}</p>
      <ul>
        {duplicates.map(dupe => (
          <li key={dupe.gid}>
            <EntityLink entity={dupe} target="_blank" />
          </li>
        ))}
      </ul>
      <p>
        <label>
          <input onChange={onCheckboxChange} type="checkbox" />
          {' '}
          {texp.l(
            'Yes, I still want to enter “{entity_name}”.',
            {entity_name: name},
          )}
        </label>
      </p>
      <p>
        {exp.l(
          `Please enter a {doc_disambiguation|disambiguation}
           to help distinguish this entity from the others.`,
          {
            doc_disambiguation: {
              href: '/doc/Disambiguation_Comment',
              target: '_blank',
            },
          },
        )}
      </p>
    </div>
  );
}

export default PossibleDuplicates;
