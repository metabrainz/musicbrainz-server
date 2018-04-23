/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const React = require('react');

const Frag = require('../components/Frag');
const Layout = require('../layout');
const EntityLink = require('../static/scripts/common/components/EntityLink');
const {l} = require('../static/scripts/common/i18n');
const {lp_attributes} = require('../static/scripts/common/i18n/attributes');
const {l_instrument_descriptions} = require('../static/scripts/common/i18n/instrument_descriptions');

type PropsT = {|
  +instrument_types: $ReadOnlyArray<InstrumentTypeT>,
  +instruments_by_type: {|
    +[number]: $ReadOnlyArray<InstrumentT>,
    +unknown: $ReadOnlyArray<InstrumentT>,
  |},
|};

const Instrument = ({instrument}) => (
  <li>
    <EntityLink entity={instrument} />
    {instrument.description
      ? (
        <Frag>
          {' — '}
          <span
            className="description"
            dangerouslySetInnerHTML={{__html: l_instrument_descriptions(instrument.description)}}
          />
        </Frag>
      )
      : null}
  </li>
);

const InstrumentList = ({
  instrument_types: instrumentTypes,
  instruments_by_type: instrumentsByType,
}: PropsT) => {
  const unknown = instrumentsByType.unknown;

  return (
    <Layout fullWidth title={l('Instrument List')}>
      <div id="content">
        <h1>{l('Instrument List')}</h1>
        {instrumentTypes.map(type => (
          <Frag key={type.id}>
            <h2>{lp_attributes(type.name, 'instrument_type')}</h2>
            <ul>
              {(instrumentsByType[type.id] || []).map(instrument => (
                <Instrument instrument={instrument} key={instrument.id} />
              ))}
            </ul>
          </Frag>
        ))}
        {(unknown && unknown.length)
          ? (
            <Frag>
              <h2>{l('Unclassified instrument')}</h2>
              <ul>
                {unknown.map(instrument => (
                  <Instrument instrument={instrument} key={instrument.id} />
                ))}
              </ul>
            </Frag>
          )
          : null}
      </div>
    </Layout>
  );
};

module.exports = InstrumentList;
