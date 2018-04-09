/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {l} from '../static/scripts/common/i18n';

import Frag from './Frag';

type Props = {|
  +wikipediaExtract?: WikipediaExtractT,
|};

const WikipediaExtract = ({wikipediaExtract}: Props) => (
  wikipediaExtract
    ? (
      <Frag>
        <h2 className="wikipedia">{l('Wikipedia')}</h2>
        <div
          className="wikipedia-extract-body wikipedia-extract-collapse"
          dangerouslySetInnerHTML={{__html: wikipediaExtract.content}}
        />
        <a href={wikipediaExtract.url}>
          {l('Continue reading at Wikipedia...')}
        </a>
        <small>
          {l('Wikipedia content provided under the terms of the {license_link|Creative Commons BY-SA license}',
            {__react: true, license_link: 'http://creativecommons.org/licenses/by-sa/3.0/'})}
        </small>
      </Frag>
    ) : null
);

export default WikipediaExtract;
