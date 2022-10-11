/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {MAX_POSTGRES_INT} from '../../common/utility/isDatabaseRowId.js';
import HelpIcon from '../../edit/components/HelpIcon.js';
import type {
  DialogLinkOrderActionT,
} from '../types/actions.js';

type PropsT = {
  +dispatch: (DialogLinkOrderActionT) => void,
  +linkOrder: number,
};

const DialogLinkOrder = (React.memo<PropsT>(({
  dispatch,
  linkOrder,
}: PropsT): React.Element<'tr'> => {
  const handleLinkOrderChange = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    let newLinkOrder = parseInt(event.currentTarget.value, 10);
    if (Number.isNaN(newLinkOrder)) {
      newLinkOrder = 0;
    }
    newLinkOrder = Math.min(newLinkOrder, MAX_POSTGRES_INT);
    dispatch({
      newLinkOrder,
      type: 'update-link-order',
    });
  }, [dispatch]);

  return (
    <tr className="link-order">
      <td className="section">
        {addColonText(l('Order'))}
      </td>
      <td className="fields">
        <input
          max={MAX_POSTGRES_INT}
          min="0"
          onChange={handleLinkOrderChange}
          type="number"
          value={linkOrder}
        />
        <HelpIcon
          content={l(
            `If this relationship has a specific order among others of the
             same type, you may set its position in the list here (as an
             alternative to the up- and down-arrow buttons).`,
          )}
        />
      </td>
    </tr>
  );
}): React.AbstractComponent<PropsT>);

export default DialogLinkOrder;
