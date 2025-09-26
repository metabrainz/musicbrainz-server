/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CellRenderProps} from 'react-table';

import EntityLink from '../static/scripts/common/components/EntityLink.js';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseUrlT} from './types.js';

const urlColumn = {
  Cell: ({row: {original}}: CellRenderProps<ReportReleaseUrlT, empty>) => {
    const url = original.url;
    return (
      url ? (
        <EntityLink
          content={url.href_url}
          entity={url}
        />
      ) : (
        l_reports('This URL no longer exists.')
      )
    );
  },
  Header: l_reports('URL'),
  id: 'url',
};

component BadAmazonUrls(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows releases with Amazon URLs which don't follow
         the expected format. They might still be correct if they're
         archive.org cover links, but in any other case they should
         probably be fixed or removed.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports('Bad Amazon URLs')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsAfter={[urlColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default BadAmazonUrls;
