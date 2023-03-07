/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import PaginatedResults from '../../components/PaginatedResults.js';
import ArtistCreditUsageLink
  from '../../static/scripts/common/components/ArtistCreditUsageLink.js';
import loopParity from '../../utility/loopParity.js';
import type {ReportArtistCreditT} from '../types.js';

type Props = {
  +items: $ReadOnlyArray<ReportArtistCreditT>,
  +pager: PagerT,
};

const ArtistCreditList = ({
  items,
  pager,
}: Props): React$Element<typeof PaginatedResults> => (
  <PaginatedResults pager={pager}>
    <table className="tbl">
      <thead>
        <tr>
          <th>{l('Artist Credit')}</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr className={loopParity(index)} key={item.artist_credit_id}>
            {item.artist_credit ? (
              <>
                <td>
                  <ArtistCreditUsageLink
                    artistCredit={item.artist_credit}
                    showEditsPending
                  />
                </td>
              </>
            ) : (
              <td>
                {l('This artist credit no longer exists.')}
              </td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  </PaginatedResults>
);

export default ArtistCreditList;
