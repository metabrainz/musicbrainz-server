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
  +date: string,
  +user?: EditorT,
};

const ExpirationTime = ({date, user}: PropsT) => {
  const dateMoment = moment(date);
  const userDate = formatUserDate(user, date);

  if (dateMoment.isAfter()) {
    const duration = moment.duration(dateMoment.diff(moment()));
    if (duration.days() > 0) {
      return exp.ln(
        `Expires in
         <span class="tooltip" title="{exactdate}">{num} day</span>`,
        `Expires in
         <span class="tooltip" title="{exactdate}">{num} days</span>`,
        duration.days(),
        {exactdate: userDate, num: duration.days()},
      );
    } else if (duration.hours() > 0) {
      return exp.ln(
        `Expires in
         <span class="tooltip" title="{exactdate}">{num} hour</span>`,
        `Expires in
         <span class="tooltip" title="{exactdate}">{num} hours</span>`,
        duration.hours(),
        {exactdate: userDate, num: duration.hours()},
      );
    }
    return exp.ln(
      `Expires in
       <span class="tooltip" title="{exactdate}">{num} minute</span>`,
      `Expires in
       <span class="tooltip" title="{exactdate}">{num} minutes</span>`,
      duration.minutes(),
      {exactdate: userDate, num: duration.minutes()},
    );
  }
  return l('Already expired');
};

export default ExpirationTime;
