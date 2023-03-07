/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const DataTrackIcon = (): React$Element<'div'> => (
  <div
    className="data-track icon img"
    title={l('This track is a data track.')}
  />
);

export default DataTrackIcon;
