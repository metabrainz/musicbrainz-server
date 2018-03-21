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
import WikipediaExtract from './WikipediaExtract';

type Props = {|
  +wikipediaExtract?: WikipediaExtractT,
  +wikipediaExtractURL?: string,
|};

const EntityWikipediaExtract = ({
  wikipediaExtract,
  wikipediaExtractURL,
}: Props) => (
  wikipediaExtract
    ? <WikipediaExtract wikipediaExtract={wikipediaExtract} />
    : wikipediaExtractURL
      ? (
        <Frag>
          <span id="wikipedia-insertion-point" style={{display: 'none'}} />
          <script
            dangerouslySetInnerHTML={{
              __html: `
                $.get('` + wikipediaExtractURL + `',
                  function (data) {
                    $('#wikipedia-insertion-point').replaceWith(data);
                    MB.makeCollapsible('wikipedia-extract');
                  },
                  'html');
              `,
            }}
            type="text/javascript"
          />
        </Frag>
      ) : null
);

export default EntityWikipediaExtract;
