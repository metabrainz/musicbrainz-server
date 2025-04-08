/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isolateText from '../utility/isolateText.js';
import mediumFormatName from '../utility/mediumFormatName.js';

export component MinimalMediumDescription(medium: MediumT) {
  const mediumDescription = mediumFormatName(medium);
  if (medium.name) {
    return (
      <>
        {addColonText(mediumDescription)}
        {' '}
        <span className="medium-name">{isolateText(medium.name)}</span>
      </>
    );
  }
  return mediumDescription;
}

component MediumDescription(medium: MediumT) {
  const formatAndPosition = medium.format ? (
    texp.l('Medium {position} ({medium_format})', {
      medium_format: mediumFormatName(medium),
      position: medium.position,
    })
  ) : (
    texp.l('Medium {position}', {
      position: medium.position,
    })
  );

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
}

export default MediumDescription;
