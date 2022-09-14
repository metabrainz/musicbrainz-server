/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import SubHeader from '../components/SubHeader.js';
import Tabs from '../components/Tabs.js';
import CDStubLink from '../static/scripts/common/components/CDStubLink.js';

type Props = {
  +cdstub: CDStubT,
  +page: string,
};

const CDStubHeader = ({
  cdstub,
  page,
}: Props): React.Element<typeof React.Fragment> => {
  const subHeading = exp.l(
    'CD stub by {artist}',
    {artist: cdstub.artist || l('Various Artists')},
  );

  return (
    <>
      <div className="blankheader">
        <h1>
          {cdstub.title}
        </h1>
        <SubHeader subHeading={subHeading} />
      </div>
      <Tabs>
        <li className={page === 'index' ? 'sel' : ''} key="index">
          <CDStubLink
            cdstub={cdstub}
            content={l('Overview')}
          />
        </li>
        <li className={page === 'edit' ? 'sel' : ''} key="edit">
          <CDStubLink
            cdstub={cdstub}
            content={l('Edit')}
            subPath="edit"
          />
        </li>
      </Tabs>
    </>
  );
};

export default CDStubHeader;
