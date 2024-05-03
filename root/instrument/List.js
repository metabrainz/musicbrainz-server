/*
 * @flow strict
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';
import EntityLink from '../static/scripts/common/components/EntityLink.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';

type InstrumentsByTypeT = {
  +[typeId: number]: $ReadOnlyArray<InstrumentT>,
  +unknown: $ReadOnlyArray<InstrumentT>,
};

component Instrument(instrument: InstrumentT) {
  return (
    <li>
      <EntityLink entity={instrument} />
      {instrument.description
        ? (
          <>
            {' — '}
            {expand2react(l_instrument_descriptions(instrument.description))}
          </>
        )
        : null}
    </li>
  );
}

component InstrumentList(
  instrument_types as instrumentTypes: $ReadOnlyArray<InstrumentTypeT>,
  instruments_by_type as instrumentsByType: InstrumentsByTypeT,
) {
  const unknown = instrumentsByType.unknown;

  return (
    <Layout fullWidth title={l('Instrument list')}>
      <div id="content">
        <h1>{l('Instrument list')}</h1>
        {instrumentTypes.map(type => (
          <React.Fragment key={type.id}>
            <h2>{lp_attributes(type.name, 'instrument_type')}</h2>
            <ul>
              {(instrumentsByType[type.id] || []).map(instrument => (
                <Instrument instrument={instrument} key={instrument.id} />
              ))}
            </ul>
          </React.Fragment>
        ))}
        {unknown?.length
          ? (
            <>
              <h2>{l('Unclassified instrument')}</h2>
              <ul>
                {unknown.map(instrument => (
                  <Instrument instrument={instrument} key={instrument.id} />
                ))}
              </ul>
            </>
          )
          : null}
        <p>
          {exp.l(
            `Is this list missing an instrument?
             Request it by following {link|these instructions}.`,
            {link: '/doc/How_to_Add_Instruments'},
          )}
        </p>
      </div>
    </Layout>
  );
}

export default InstrumentList;
