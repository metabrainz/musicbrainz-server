/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';
import moment from 'moment';

import formatUserDate from '../utility/formatUserDate';

type PropsT = {
  +closingDate: string,
  +user?: EditorT,
};

const VotingPeriod = ({closingDate, user}: PropsT) => {
  const dateMoment = moment(closingDate);
  const userDate = formatUserDate(user, closingDate);

  if (dateMoment.isAfter()) {
    const duration = moment.duration(dateMoment.diff(moment()));
    if (duration.days() > 0) {
      return exp.ln(
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} day</span>`,
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} days</span>`,
        duration.days(),
        {exactdate: userDate, num: duration.days()},
      );
    } else if (duration.hours() > 0) {
      return exp.ln(
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} hour</span>`,
        `Closes in
         <span class="tooltip" title="{exactdate}">{num} hours</span>`,
        duration.hours(),
        {exactdate: userDate, num: duration.hours()},
      );
    }
    return exp.ln(
      `Closes in
       <span class="tooltip" title="{exactdate}">{num} minute</span>`,
      `Closes in
       <span class="tooltip" title="{exactdate}">{num} minutes</span>`,
      duration.minutes(),
      {exactdate: userDate, num: duration.minutes()},
    );
  }
  return l('Already closed');
};

export default VotingPeriod;
