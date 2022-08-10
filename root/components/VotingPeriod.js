/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {formatUserDateObject} from '../utility/formatUserDate.js';
import parseIsoDate from '../utility/parseIsoDate.js';

type PropsT = {
  +$c: CatalystContextT,
  +closingDate: string,
};

const VotingPeriod = ({
  $c,
  closingDate,
}: PropsT): Expand2ReactOutput | null => {
  const date = parseIsoDate(closingDate);
  if (!date) {
    return null;
  }
  const userDate = formatUserDateObject($c, date);
  const now = new Date();

  if (date > now) {
    const durationSeconds = Math.floor((date - now) / 1000);
    const durationMinutes = Math.round(durationSeconds / 60);
    const durationHours = Math.round(durationMinutes / 60);
    const durationDays = Math.round(durationHours / 24);

    if (durationHours > 23) {
      return exp.ln(
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} day</span>`,
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} days</span>`,
        durationDays,
        {exactdate: userDate, num: durationDays},
      );
    } else if (durationMinutes > 59) {
      return exp.ln(
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} hour</span>`,
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} hours</span>`,
        durationHours,
        {exactdate: userDate, num: durationHours},
      );
    }
    return exp.ln(
      `Closes in
       <span class="tooltip" title="{exactdate}">{num} minute</span>`,
      `Closes in
       <span class="tooltip" title="{exactdate}">{num} minutes</span>`,
      durationMinutes,
      {exactdate: userDate, num: durationMinutes},
    );
  }
  return l('About to close');
};

export default VotingPeriod;
