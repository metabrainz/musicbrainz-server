/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const cleanupDangerBannerStrings = {
  artist: N_l(
    `This artist has no relationships, recordings, releases or
     release groups, and will be removed automatically once the
     pending “Add artist” edit has passed. If this is not intended,
     please add more data to this artist.`,
  ),
  event: N_l(
    `This event has no relationships and will be removed automatically 
     once the pending “Add event” edit has passed. If this is not intended, 
     please add more data to this event.`,
  ),
  label: N_l(
    `This label has no relationships or releases and will be removed
     automatically once the pending “Add label” edit has passed.
     If this is not intended, please add more data to this label.`,
  ),
  place: N_l(
    `This place has no relationships and will be removed automatically
     once the pending “Add place” edit has passed. If this is not intended,
     please add more data to this place.`,
  ),
  release_group: N_l(
    `This release group has no relationships or releases associated,
     and will be removed automatically once the pending “Add release
     group” edit has passed. If this is not intended, please
     add more data to this release group.`,
  ),
  series: N_l(
    `This series has no relationships and will be removed automatically
     once the pending “Add series” edit has passed. If this is not intended,
     please add more data to this series.`,
  ),
  work: N_l(
    `This work has no relationships and will be removed automatically
     once the pending “Add work” edit has passed. If this is not
     intended, please add relationships to this work.`,
  ),
};

const CleanupDangerBanner = (
  {entityType}: {entityType: string},
): React.Element<'p'> => (
  <p className="cleanup">
    {cleanupDangerBannerStrings[entityType]()}
  </p>
);

export default CleanupDangerBanner;
