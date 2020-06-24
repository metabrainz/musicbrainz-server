/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';


const style = {float: 'left', margin: '1em'};

const GuessCaseIcon = (): React.Element<'img'> => (
  <img
    alt=""
    src={require('../../../images/icons/guesscase.32x32.png')}
    style={style}
  />
);

export default GuessCaseIcon;
