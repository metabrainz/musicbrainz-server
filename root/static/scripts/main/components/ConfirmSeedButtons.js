/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DBDefs from '../../common/DBDefs-client.mjs';

type PropsT = {
  +autoSubmit: boolean,
};

const ConfirmSeedButtons = ({
  autoSubmit,
}: PropsT): React$MixedElement => {
  const submitRef = React.useRef<HTMLButtonElement | null>(null);
  React.useEffect(() => {
    if (autoSubmit) {
      submitRef.current?.click();
    }
  });

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
              DBDefs.WEB_SERVER,
            );
          }
        }}
        type="button"
      >
        {l('Leave')}
      </button>
    </>
  );
};

export default (hydrate(
  'span.buttons.confirm-seed',
  ConfirmSeedButtons,
): React$AbstractComponent<PropsT, void>);
