/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {WEB_SERVER} from '../../common/DBDefs-client.mjs';

component ConfirmSeedButtons(autoSubmit: boolean) {
  const submitRef = React.useRef<HTMLButtonElement | null>(null);
  React.useEffect(() => {
    if (autoSubmit) {
      submitRef.current?.click();
    }
  }, [autoSubmit, submitRef]);

  return (
    <>
      <button ref={submitRef} type="submit">
        {l('Continue')}
      </button>
      <button
        className="negative"
        onClick={() => {
          if (history.length > 1) {
            history.back();
          } else {
            window.location.replace(
              window.location.protocol + '//' +
              WEB_SERVER,
            );
          }
        }}
        type="button"
      >
        {l('Leave')}
      </button>
    </>
  );
}

export default (hydrate(
  'span.buttons.confirm-seed',
  ConfirmSeedButtons,
): component(...React.PropsOf<ConfirmSeedButtons>));
