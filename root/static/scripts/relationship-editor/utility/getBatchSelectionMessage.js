/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {bracketedText} from '../../common/utility/bracketed.js';

export default function getBatchSelectionMessage(
  sourceType: CentralEntityTypeT,
  batchSelectionCount: number,
): string {
  switch (sourceType) {
    case 'recording': {
      return bracketedText(texp.ln(
        '{n} recording selected',
        '{n} recordings selected',
        batchSelectionCount,
        {n: batchSelectionCount},
      ));
    }
    case 'work': {
      return bracketedText(texp.ln(
        '{n} work selected',
        '{n} works selected',
        batchSelectionCount,
        {n: batchSelectionCount},
      ));
    }
  }
  return '';
}
