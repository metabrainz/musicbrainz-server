/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {bracketedText} from '../utility/bracketed.js';

type Props = {
  +direction: number,
};

const OrderableDirection = ({
  direction,
}: Props): React.MixedElement => {
  let directionName;
  switch (direction) {
    case 0:
      directionName = l('None');
      break;
    case 1:
      directionName = l('Forward');
      break;
    case 2:
      directionName = l('Backward');
      break;
  }

  return (
    <>
      {directionName}
      {' '}
      {bracketedText(direction.toString())}
    </>
  );
};

export default OrderableDirection;
