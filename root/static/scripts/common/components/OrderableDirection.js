/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {bracketedText} from '../utility/bracketed.js';

component OrderableDirection(direction: OrderableDirectionT) {
  const directionName = match (direction) {
    0 => lp('None', 'relationship order direction'),
    1 => l('Forward'),
    2 => l('Backward'),
  };

  return (
    <>
      {directionName}
      {' '}
      {bracketedText(direction.toString())}
    </>
  );
}

export default OrderableDirection;
