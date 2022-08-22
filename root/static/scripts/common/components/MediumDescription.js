/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {addColonText} from '../i18n/addColon.js';
import isolateText from '../utility/isolateText.js';
import mediumFormatName from '../utility/mediumFormatName.js';

type Props = {
  +medium: MediumT,
};

const MediumDescription = ({medium}: Props): Expand2ReactOutput => {
  const formatAndPosition = texp.l('{medium_format} {position}', {
    medium_format: mediumFormatName(medium),
    position: medium.position,
  });
  if (medium.name) {
    return (
      <>
        {addColonText(formatAndPosition)}
        {' '}
        <span className="medium-name">{isolateText(medium.name)}</span>
      </>
    );
  }
  return formatAndPosition;
};

export default MediumDescription;
