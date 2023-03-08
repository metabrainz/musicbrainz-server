/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const cleanupBannerStrings = {
  artist: N_l(
    `This artist has no relationships, recordings, releases or
     release groups, and will be removed automatically in the next
     few days. If this is not intended, please add more data to
     this artist.`,
  ),
  event: N_l(
    `This event has no relationships and will be removed automatically 
     in the next few days. If this is not intended, 
     please add more data to this event.`,
  ),
  label: N_l(
    `This label has no relationships or releases and will be removed
     automatically in the next few days. If this is not intended,
     please add more data to this label.`,
  ),
  place: N_l(
    `This place has no relationships and will be removed automatically
     in the next few days. If this is not intended,
     please add more data to this place.`,
  ),
  release_group: N_l(
    `This release group has no relationships or releases associated,
     and will be removed automatically in the next few days. If this
     is not intended, please add more data to this release group.`,
  ),
  series: N_l(
    `This series has no relationships and will be removed automatically
     in the next few days. If this is not intended, please add more data
     to this series.`,
  ),
  work: N_l(
    `This work has no relationships and will be removed automatically
     in the next few days. If this is not intended, please add
     relationships to this work.`,
  ),
};

type Props = {
  +entityType: string,
};

const CleanupBanner = ({entityType}: Props): React$Element<'p'> => (
  <p className="cleanup">
    {cleanupBannerStrings[entityType]()}
  </p>
);

export default CleanupBanner;
