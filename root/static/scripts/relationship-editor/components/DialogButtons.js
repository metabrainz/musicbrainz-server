/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

component _DialogButtons(
  isDoneDisabled: boolean,
  onCancel: () => void,
  onDone: () => void,
) {
  return (
    <div
      className="buttons"
      style={{marginTop: '1em'}}
    >
      <button className="negative" onClick={onCancel} type="button">
        {l('Cancel')}
      </button>
      <div className="buttons-right">
        <button
          className="positive"
          disabled={isDoneDisabled}
          onClick={onDone}
          type="button"
        >
          {l('Done')}
        </button>
      </div>
    </div>
  );
}

const DialogButtons: React$AbstractComponent<
  React.PropsOf<_DialogButtons>
> = React.memo(_DialogButtons);

export default DialogButtons;
