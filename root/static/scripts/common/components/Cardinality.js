/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {bracketedText} from '../utility/bracketed.js';

component Cardinality(cardinality: number) {
  const cardinalityName = match (cardinality) {
    0 => l('Few relationships'),
    1 => l('Many relationships'),
    _ => lp('Unknown', 'cardinality'),
  };

  return (
    <>
      {cardinalityName}
      {' '}
      {bracketedText(cardinality.toString())}
    </>
  );
}

export default Cardinality;
