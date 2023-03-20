/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import InstrumentSidebar
  from '../layout/components/sidebar/InstrumentSidebar.js';
import Layout from '../layout/index.js';
import localizeInstrumentName
  from '../static/scripts/common/i18n/localizeInstrumentName.js';

import InstrumentHeader from './InstrumentHeader.js';

type Props = {
  +children: React$Node,
  +entity: InstrumentT,
  +fullWidth?: boolean,
  +page: string,
  +title?: string,
};

const InstrumentLayout = ({
  children,
  entity: instrument,
  fullWidth = false,
  page,
  title,
}: Props): React$Element<typeof Layout> => {
  const nameWithType = texp.l('{type} “{instrument}”', {
    instrument: localizeInstrumentName(instrument),
    type: nonEmpty(instrument.typeName)
      ? lp_attributes(instrument.typeName, 'instrument_type')
      : l('Instrument'),
  });
  return (
    <Layout
      title={nonEmpty(title)
        ? hyphenateTitle(nameWithType, title)
        : nameWithType}
    >
      <div id="content">
        <InstrumentHeader instrument={instrument} page={page} />
        {children}
      </div>
      {fullWidth ? null : <InstrumentSidebar instrument={instrument} />}
    </Layout>
  );
};

export default InstrumentLayout;
