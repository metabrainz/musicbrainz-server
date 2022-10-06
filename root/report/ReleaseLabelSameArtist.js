/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {CellRenderProps} from 'react-table';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseLabelT} from './types.js';

const ReleaseLabelSameArtist = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseLabelT>): React.Element<typeof ReportLayout> => {
  const labelColumn = {
    Cell: ({
      row: {original},
    }: CellRenderProps<ReportReleaseLabelT, empty>) => (
      <a href={'/label/' + encodeURIComponent(original.label_gid)}>
        {original.label_name}
      </a>
    ),
    Header: l('Label'),
    id: 'label',
  };

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l(
        `This report lists releases where the label name is the same as the
         artist name. Often this means the release is self-released, and the
         label {SpecialPurposeLabel|should be "[no label]" instead}.`,
        {
          SpecialPurposeLabel:
          '/doc/Style/Unknown_and_untitled/Special_purpose_label',
        },
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases where artist name and label name are the same')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsAfter={[labelColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default ReleaseLabelSameArtist;
