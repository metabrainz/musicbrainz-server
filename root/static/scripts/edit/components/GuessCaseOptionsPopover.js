/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ButtonPopover from '../../common/components/ButtonPopover.js';

import GuessCaseOptions from './GuessCaseOptions.js';

const buttonProps: React.PropsOf<ButtonPopover>['buttonProps'] = {
  className: 'guesscase-options icon',
  title: N_l('Guess case options'),
};

component _GuessCaseOptionsPopover(
  isOpen: boolean,
  toggle: (boolean) => void,
  ...guessCaseOptionsProps: React.PropsOf<GuessCaseOptions>
) {
  const buildChildren = React.useCallback((
    closeAndReturnFocus: () => void,
  ) => (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        closeAndReturnFocus();
      }}
    >
      <GuessCaseOptions {...guessCaseOptionsProps} />
      <div
        className="buttons"
        style={{marginTop: '1em'}}
      >
        <div className="buttons-right">
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
  ), [guessCaseOptionsProps]);

  return (
    <ButtonPopover
      buildChildren={buildChildren}
      buttonContent={null}
      buttonProps={buttonProps}
      id="gc-options-dialog"
      isOpen={isOpen}
      toggle={toggle}
    />
  );
}

const GuessCaseOptionsPopover:
  component(...React.PropsOf<_GuessCaseOptionsPopover>) =
  React.memo(_GuessCaseOptionsPopover);

export default GuessCaseOptionsPopover;
