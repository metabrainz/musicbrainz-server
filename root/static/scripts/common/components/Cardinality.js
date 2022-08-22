/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {bracketedText} from '../utility/bracketed.js';

type Props = {
  +cardinality: number,
};

const Cardinality = ({cardinality}: Props): React.MixedElement => {
  let cardinalityName;
  switch (cardinality) {
    case 0:
      cardinalityName = l('Few relationships');
      break;
    case 1:
      cardinalityName = l('Many relationships');
      break;
    default:
      cardinalityName = l('Unknown');
      break;
  }

  return (
    <>
      {cardinalityName}
      {' '}
      {bracketedText(cardinality.toString())}
    </>
  );
};

export default Cardinality;
