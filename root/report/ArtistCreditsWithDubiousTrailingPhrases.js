/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ArtistCreditList from './components/ArtistCreditList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportArtistCreditT, ReportDataT} from './types.js';

const ArtistCreditsWithDubiousTrailingPhrases = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportArtistCreditT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists artist credits that have a trailing join phrase
       that looks like it might have been left behind in error, such as
       a trailing comma or “feat.”.`,
    )}
    entityType="artist_credit"
    filtered={filtered}
    generated={generated}
    title={l('Artist credits with dubious trailing join phrases')}
    totalEntries={pager.total_entries}
  >
    <ArtistCreditList items={items} pager={pager} />
  </ReportLayout>
);

export default ArtistCreditsWithDubiousTrailingPhrases;
