/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {isPerfectMatch} from '../../../../cdtoc/utils.js';

component CDTocEditColumn(
  mediumCDToc: MediumCDTocT,
) {
  const cdToc = mediumCDToc.cdtoc;
  const medium = mediumCDToc.medium;
  invariant(medium, 'No medium found');

  return (
    <td>
      {isPerfectMatch(medium, cdToc) ? null : (
        <>
          <a
            href={
              `/cdtoc/${cdToc.discid}/set-durations?medium=${medium.id}`
            }
          >
            {l('Set track lengths')}
          </a>
          {' | '}
        </>
      )}
      <a
        href={`/cdtoc/remove?medium_id=${medium.id}&cdtoc_id=${cdToc.id}`}
      >
        {l('Remove')}
      </a>
      {' | '}
      <a href={`/cdtoc/move?toc=${mediumCDToc.id}`}>
        {l('Move')}
      </a>
    </td>
  );
}

export default CDTocEditColumn;
