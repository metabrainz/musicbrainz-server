/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {l_instruments, lp_instruments} from './instruments';

function localizeInstrumentName(instrument: InstrumentT) {
  if (instrument.comment) {
    return lp_instruments(instrument.name, instrument.comment);
  }
  return l_instruments(instrument.name);
}

export default localizeInstrumentName;
