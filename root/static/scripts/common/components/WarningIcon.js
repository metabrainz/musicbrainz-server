/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import warningIconUrl from '../../../images/icons/warning.png';

const WarningIcon = (): React$Element<'img'> => (
  <img
    alt={l('Warning')}
    className="warning"
    src={warningIconUrl}
  />
);

export default WarningIcon;
