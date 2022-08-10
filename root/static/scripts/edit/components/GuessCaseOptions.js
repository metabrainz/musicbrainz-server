/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import expand2react from '../../common/i18n/expand2react';
import bracketed from '../../common/utility/bracketed';
import getBooleanCookie from '../../common/utility/getBooleanCookie';
import setCookie from '../../common/utility/setCookie';
import * as modes from '../../guess-case/modes';
import gc from '../../guess-case/MB/GuessCase/Main';

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {+type: 'set-mode', +modeName: string}
  | {+type: 'set-keep-upper-case', +enabled: boolean}
  | {+type: 'set-upper-case-roman', +enabled: boolean};
/* eslint-enable flowtype/sort-keys */

export type DispatchT = (ActionT) => void;

export type StateT = {
  +keepUpperCase: boolean,
  +modeName: string,
  +upperCaseRoman: boolean,
};

export type WritableStateT = {
  ...StateT,
};

export type PropsT = $ReadOnly<{
  ...StateT,
  +dispatch: (ActionT) => void,
}>;

export function createInitialState(): StateT {
  return {
    keepUpperCase: gc.CFG_KEEP_UPPERCASED,
    modeName: gc.modeName,
    upperCaseRoman: getBooleanCookie('guesscase_roman'),
  };
}

export function runReducer(
  state: WritableStateT,
  action: ActionT,
): void {
  switch (action.type) {
    case 'set-mode': {
      const modeName = action.modeName;
      gc.modeName = modeName;
      setCookie('guesscase_mode', modeName);
      state.modeName = modeName;
      break;
    }
    case 'set-keep-upper-case': {
      const enabled = action.enabled;
      gc.CFG_KEEP_UPPERCASED = enabled;
      setCookie('guesscase_keepuppercase', enabled);
      state.keepUpperCase = enabled;
      break;
    }
    case 'set-upper-case-roman': {
      const enabled = action.enabled;
      setCookie('guesscase_roman', enabled);
      state.upperCaseRoman = enabled;
      break;
    }
  }
}

const GuessCaseOptions = ({
  dispatch,
  keepUpperCase,
  modeName,
  upperCaseRoman,
}: PropsT): React.Element<'div'> => {
  function handleModeChange(event: SyntheticEvent<HTMLSelectElement>) {
    const newModeName = event.currentTarget.value;

    if (newModeName !== gc.modeName) {
      dispatch({modeName: newModeName, type: 'set-mode'});
    }
  }

  function handleKeepUpperCaseChanged(
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    dispatch({
      enabled: event.currentTarget.checked,
      type: 'set-keep-upper-case',
    });
  }

  function handleUpperCaseRomanChanged(
    event: SyntheticEvent<HTMLInputElement>,
  ) {
    dispatch({
      enabled: event.currentTarget.checked,
      type: 'set-upper-case-roman',
    });
  }

  return (
    <div id="guesscase-options">
      <h1>{l('Guess case options')}</h1>
      <select onChange={handleModeChange} value={modeName}>
        <option value="English">{l('English')}</option>
        <option value="Sentence">{l('Sentence')}</option>
        <option value="French">{l('French')}</option>
        <option value="Turkish">{l('Turkish')}</option>
      </select>
      {' '}
      {bracketed(
        <a href="/doc/Guess_Case" target="_blank">
          {l('help')}
        </a>,
      )}
      <p>
        {expand2react(modes[modeName].description ?? '')}
      </p>
      <label>
        <input
          checked={keepUpperCase}
          onChange={handleKeepUpperCaseChanged}
          type="checkbox"
        />
        {l('Keep all-uppercase words uppercased')}
      </label>
      <br />
      <label>
        <input
          checked={upperCaseRoman}
          onChange={handleUpperCaseRomanChanged}
          type="checkbox"
        />
        {l('Uppercase Roman numerals')}
      </label>
    </div>
  );
};

export default GuessCaseOptions;
