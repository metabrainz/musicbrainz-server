/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingT} from './types.js';

component KaraokePlusInstrumentalRecordings(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l(
        `This report shows recordings which have a
         {doc_karaoke_rel|“karaoke” relationship} to another recording,
         but are linked to a work with the
         {doc_instrumental_attr|“instrumental” attribute}, or the other
         way around, with an
         {doc_instrumental_rel|“instrumental” relationship} and the
         {doc_karaoke_attr|“karaoke” attribute}.`,
        {
          doc_instrumental_attr: '/relationship-attributes#instrumental',
          doc_instrumental_rel:
            '/relationship/9fc01a58-7801-4bd2-b07d-61cc7ffacf90',
          doc_karaoke_attr: '/relationship-attributes#karaoke',
          doc_karaoke_rel:
            '/relationship/39a08d0e-26e4-44fb-ae19-906f5fe9435d',
        },
      )}
      entityType="relationship"
      extraInfo={l(
        `Keep in mind that “instrumental” in MusicBrainz implies the lyrics
         are not relevant to the recording. Since lyrics are by definition
         relevant to karaoke recordings, “instrumental” should not be used
         on them (use “karaoke” instead). Alternatively, if this is not
         a karaoke recording, but just a standard instrumental recording,
         it shouldn’t be linked to another recording with a “karaoke”
         relationship, but with an “instrumental” one.`,
      )}
      filtered={filtered}
      generated={generated}
      title={l('Recordings marked as both karaoke and instrumental')}
      totalEntries={pager.total_entries}
    >
      <RecordingList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default KaraokePlusInstrumentalRecordings;
