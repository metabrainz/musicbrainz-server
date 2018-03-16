/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import * as manifest from '../static/manifest';

import CommonsImage from './CommonsImage';
import Frag from './Frag';

type Props = {|
  +image?: CommonsImageT | null,
  +imageEndpoint?: string,
|};

const CommonsImageWrapper = (props: Props) => (
  <Frag>
    <div id="commons-image">
      <CommonsImage image={props.image} />
    </div>
    {props.image ? null : manifest.js('commons-image', {
      'async': true,
      'data-args': JSON.stringify(props),
    })}
  </Frag>
);

export default CommonsImageWrapper;
