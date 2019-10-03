/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {addColonText} from '../i18n/addColon';
import isolateText from '../utility/isolateText';
import mediumFormatName from '../utility/mediumFormatName';

const MediumDescription = ({medium}: {+medium: MediumT}) => {
  const formatAndPosition = texp.l('{medium_format} {position}', {
    medium_format: mediumFormatName(medium),
    position: medium.position,
  });
  if (medium.name) {
    return (
      <>
        <span>{addColonText(formatAndPosition)}</span>
        {' '}
        <span className="medium-name">{isolateText(medium.name)}</span>
      </>
    );
  }
  return <span>{formatAndPosition}</span>;
};

export default MediumDescription;
