/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../context';
import {l} from '../../static/scripts/common/i18n';
import {l_instrument_descriptions} from '../../static/scripts/common/i18n/instrument_descriptions';
import {lp_attributes} from '../../static/scripts/common/i18n/attributes';
import EntityLink from '../../static/scripts/common/components/EntityLink';
import loopParity from '../../utility/loopParity';
import type {ResultsPropsT} from '../types';

import PaginatedSearchResults from './PaginatedSearchResults';
import ResultsLayout from './ResultsLayout';

function buildResult(result, index) {
  const instrument = result.entity;
  const score = result.score;

  return (
    <tr className={loopParity(index)} data-score={score} key={instrument.id}>
      <td>
        <EntityLink entity={instrument} />
      </td>
      <td>{instrument.typeName ? lp_attributes(instrument.typeName, 'instrument_type') : null}</td>
      <td>
        {instrument.description
          ? l_instrument_descriptions(instrument.description)
          : null}
      </td>
    </tr>
  );
}

const InstrumentResults = ({
  $c,
  form,
  lastUpdated,
  pager,
  query,
  results,
}: ResultsPropsT<InstrumentT>) => (
  <ResultsLayout form={form} lastUpdated={lastUpdated}>
    <PaginatedSearchResults
      buildResult={buildResult}
      columns={
        <>
          <th>{l('Name')}</th>
          <th>{l('Type')}</th>
          <th>{l('Description')}</th>
        </>
      }
      pager={pager}
      query={query}
      results={results}
    />
  </ResultsLayout>
);

export default withCatalystContext(InstrumentResults);
