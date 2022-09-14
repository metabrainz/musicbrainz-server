/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type PropsT = {
  +isDoneDisabled: boolean,
  +onCancel: () => void,
  +onDone: () => void,
};

const DialogButtons = (React.memo<PropsT>(({
  isDoneDisabled,
  onCancel,
  onDone,
}: PropsT): React$Element<'div'> => (
  <div
    className="buttons ui-helper-clearfix"
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
)): React.AbstractComponent<PropsT>);

export default DialogButtons;
