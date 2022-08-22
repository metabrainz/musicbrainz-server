/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ButtonPopover from '../../common/components/ButtonPopover.js';

import GuessCaseOptions, {
  type PropsT as GuessCaseOptionsPropsT,
} from './GuessCaseOptions.js';

type Props = $ReadOnly<{
  +isOpen: boolean,
  +toggle: (boolean) => void,
  ...GuessCaseOptionsPropsT,
}>;

const buttonProps = {
  className: 'guesscase-options icon',
  title: N_l('Guess case options'),
};

const GuessCaseOptionsPopover = (React.memo(({
  dispatch,
  isOpen,
  keepUpperCase,
  modeName,
  toggle,
  upperCaseRoman,
}: Props): React.Element<typeof ButtonPopover> => {
  const buttonRef = React.useRef<HTMLButtonElement | null>(null);

  const buildChildren = React.useCallback((
    closeAndReturnFocus: () => void,
  ) => (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        closeAndReturnFocus();
      }}
    >
      <GuessCaseOptions
        dispatch={dispatch}
        keepUpperCase={keepUpperCase}
        modeName={modeName}
        upperCaseRoman={upperCaseRoman}
      />
      <div
        className="buttons"
        style={{marginTop: '1em'}}
      >
        <div
          className="buttons-right"
          style={{float: 'right', textAlign: 'right'}}
        >
          <button
            className="positive"
            onClick={closeAndReturnFocus}
            type="button"
          >
            {l('Done')}
          </button>
        </div>
      </div>
    </form>
  ), [
    dispatch,
    keepUpperCase,
    modeName,
    upperCaseRoman,
  ]);

  return (
    <ButtonPopover
      buildChildren={buildChildren}
      buttonContent={null}
      buttonProps={buttonProps}
      buttonRef={buttonRef}
      id="gc-options-dialog"
      isOpen={isOpen}
      toggle={toggle}
    />
  );
}): React.AbstractComponent<Props, void>);

export default GuessCaseOptionsPopover;
