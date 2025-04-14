/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  defineEntityColumn,
  defineTextColumn,
} from '../utility/tableColumns.js';

import ReportLayout from './components/ReportLayout.js';
import SeriesList from './components/SeriesList.js';
import type {ReportDataT, ReportSeriesDuplicatesT} from './types.js';

const entityColumn = defineEntityColumn<ReportSeriesDuplicatesT>({
  columnName: 'duplicate',
  getEntity: result => result.entity ?? null,
  showIcon: true,
  title: l('Duplicate entity'),
});

const numberColumn = defineTextColumn<ReportSeriesDuplicatesT>({
  columnName: 'number',
  getText: result => result.order_number ?? '',
  title: l('Number'),
});

component SeriesContainingDuplicates(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportSeriesDuplicatesT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report lists series which contain the same entity multiple
         times with the same number attribute.`,
      )}
      entityType="series"
      filtered={filtered}
      generated={generated}
      title={l('Series containing duplicates')}
      totalEntries={pager.total_entries}
    >
      <SeriesList
        columnsAfter={[entityColumn, numberColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default SeriesContainingDuplicates;
