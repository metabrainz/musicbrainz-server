/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SubHeader from '../components/SubHeader.js';
import CDStubLink from '../static/scripts/common/components/CDStubLink.js';

type Props = {
  +cdstub: CDStubT,
};

const CDStubHeader = ({
  cdstub,
}: Props): React$Element<'div'> => {
  const subHeading = exp.l(
    'CD stub by {artist}',
    {artist: cdstub.artist || l('Various Artists')},
  );

  return (
    <div className="blankheader">
      <h1>
        <CDStubLink cdstub={cdstub} content={cdstub.title} />
      </h1>
      <SubHeader subHeading={subHeading} />
    </div>
  );
};

export default CDStubHeader;
