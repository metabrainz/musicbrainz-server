/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {CellRenderProps} from 'react-table';

import EntityLink from '../static/scripts/common/components/EntityLink';

import ReleaseList from './components/ReleaseList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseUrlT} from './types';

const BadAmazonUrls = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseUrlT>): React.Element<typeof ReportLayout> => {
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
          l('This URL no longer exists.')
        )
      );
    },
    Header: l('URL'),
    id: 'url',
  };

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows releases with Amazon URLs which don't follow
         the expected format. They might still be correct if they're
         archive.org cover links, but in any other case they should
         probably be fixed or removed.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Bad Amazon URLs')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsAfter={[urlColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default BadAmazonUrls;
