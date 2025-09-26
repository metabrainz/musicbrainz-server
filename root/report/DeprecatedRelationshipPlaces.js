/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  relTypeColumn,
} from '../utility/tableColumns.js';

import PlaceList from './components/PlaceList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportPlaceRelationshipT} from './types.js';

component DeprecatedRelationshipPlaces(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportPlaceRelationshipT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists places which have relationships using
        deprecated and grouping-only relationship types.`,
      )}
      entityType="place"
      filtered={filtered}
      generated={generated}
      title={l_reports('Places with deprecated relationships')}
      totalEntries={pager.total_entries}
    >
      <PlaceList
        columnsBefore={[relTypeColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default DeprecatedRelationshipPlaces;
