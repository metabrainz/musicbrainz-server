/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import IntentionallyRawIcon from '../components/IntentionallyRawIcon';
import EntityLink
  from '../../static/scripts/common/components/EntityLink';
import expand2react from '../../static/scripts/common/i18n/expand2react';

type Props = {
  +allowNew?: boolean,
  +edit: AddInstrumentEditT,
};

const AddInstrument = ({allowNew, edit}: Props): React.MixedElement => {
  const display = edit.display_data;
  const description = display.description;
  const instrumentType = display.type;

  return (
    <>
      <table className="details">
        <tr>
          <th>{addColonText(l('Instrument'))}</th>
          <td>
            <EntityLink
              allowNew={allowNew}
              entity={display.instrument}
            />
          </td>
        </tr>
      </table>

      <table className="details add-instrument">
        <tr>
          <th>{addColonText(l('Name'))}</th>
          <td>
            {display.name}
            {' '}
            <IntentionallyRawIcon />
          </td>
        </tr>

        {nonEmpty(display.comment) ? (
          <tr>
            <th>{addColonText(l('Disambiguation'))}</th>
            <td>{display.comment}</td>
          </tr>
        ) : null}

        {instrumentType ? (
          <tr>
            <th>{addColonText(l('Type'))}</th>
            <td>{lp_attributes(instrumentType.name, 'instrument_type')}</td>
          </tr>
        ) : null}

        {nonEmpty(description) ? (
          <tr>
            <th>{addColonText(l('Description'))}</th>
            <td>
              {expand2react(description)}
              {' '}
              <IntentionallyRawIcon />
            </td>
          </tr>
        ) : null}
      </table>
    </>
  );
};

export default AddInstrument;
