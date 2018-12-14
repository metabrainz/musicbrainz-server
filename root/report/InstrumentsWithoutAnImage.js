/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../context';
import Layout from '../layout';
import formatUserDate from '../utility/formatUserDate';
import {l} from '../static/scripts/common/i18n';

import InstrumentList from './components/InstrumentList';
import type {ReportDataT, ReportInstrumentT} from './types';

const InstrumentsWithoutAnImage = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportInstrumentT>) => (
  <Layout fullWidth title={l('Instruments without an image')}>
    <h1>{l('Instruments without an image')}</h1>

    <ul>
      <li>{l('This report shows instruments without image \
              relationships nor Wikidata relationships.')}
      </li>
      <li>{l('Total instruments found: {count}', {__react: true, count: pager.total_entries})}</li>
      <li>{l('Generated on {date}', {__react: true, date: formatUserDate($c.user, generated)})}</li>

    </ul>

    <InstrumentList items={items} pager={pager} />

  </Layout>
);

export default withCatalystContext(InstrumentsWithoutAnImage);
