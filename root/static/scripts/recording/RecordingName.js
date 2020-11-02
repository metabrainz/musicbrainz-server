/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import hydrate from '../../../utility/hydrate';
import MB from '../common/MB';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
} from '../edit/components/FormRowNameWithGuessCase';
import {
  createInitialState as createGuessCaseOptionsState,
  runReducer as runGuessCaseOptionsReducer,
  type StateT as GuessCaseOptionsStateT,
  type WritableStateT as WritableGuessCaseOptionsStateT,
} from '../edit/components/GuessCaseOptions';

type Props = {
  +field: ReadOnlyFieldT<string>,
  +recording: {
    +entityType: 'recording',
    +name: string,
  },
};

/*
 * State must be moved higher up in the component hierarchy once more
 * of the page is converted to React.
 */
type StateT = {
  +field: ReadOnlyFieldT<string | null>,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
};

type WritableStateT = {
  ...StateT,
  field: FieldT<string | null>,
  guessCaseOptions: WritableGuessCaseOptionsStateT,
};

function createInitialState(field) {
  return {
    field,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
  };
}

function reducer(state: StateT, action: NameActionT): StateT {
  return mutate<WritableStateT, StateT>(state, newState => {
    switch (action.type) {
      case 'set-name': {
        newState.field.value = action.name;
        break;
      }
      case 'guess-case': {
        newState.field.value =
          (MB.GuessCase: any).recording.guess(
            state.field.value ?? '',
          );
        break;
      }
      case 'open-guess-case-options': {
        newState.isGuessCaseOptionsOpen = true;
        break;
      }
      case 'close-guess-case-options': {
        newState.isGuessCaseOptionsOpen = false;
        break;
      }
      case 'update-guess-case-options': {
        runGuessCaseOptionsReducer(
          newState.guessCaseOptions,
          action.action,
        );
        break;
      }
    }
  });
}

export const RecordingName = ({
  field,
  recording,
}: Props): React.Element<typeof FormRowNameWithGuessCase> => {
  /*
   * State must be moved higher up in the component hierarchy once more
   * of the page is converted to React.
   */
  const [state, dispatch] = React.useReducer(
    reducer,
    field,
    createInitialState,
  );

  return (
    <FormRowNameWithGuessCase
      dispatch={dispatch}
      entity={recording}
      field={state.field}
      guessCaseOptions={state.guessCaseOptions}
      guessFeat
      isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
    />
  );
};

/*
 * Hydration must be moved higher up in the component hierarchy once
 * more of the page is converted to React.
 */
export default (hydrate<Props>(
  'div.recording-name',
  RecordingName,
): React.AbstractComponent<Props, void>);
