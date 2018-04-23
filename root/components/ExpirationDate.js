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
import {l, ln} from '../static/scripts/common/i18n';
import bracketed from '../static/scripts/common/utility/bracketed';
import formatUserDate from '../utility/formatUserDate';

type PropsT = {
  +date: string,
  +user?: EditorT,
};

const ExpirationDate = ({date, user}: PropsT) => {
  const dateMoment = moment(date);
  const userDate = formatUserDate(user, date);
  let durationString = null;
  let result = l('Already expired');
  if (dateMoment.isAfter()) {
    const duration = moment.duration(dateMoment.diff(moment()));
    if (duration.days() > 0) {
      durationString = ln('{num} day',
        '{num} days',
        duration.days(),
        {num: duration.days()});
    } else if (duration.hours() > 0) {
      durationString = ln('{num} hour',
        '{num} hours',
        duration.hours(),
        {num: duration.hours()});
    } else {
      durationString = ln('{num} minute',
        '{num} minutes',
        duration.minutes(),
        {num: duration.minutes()});
    }
  }
  if (durationString) {
    result = l('Expires in {time}', {
      __react: true,
      time: (
        <span className="tooltip" title={userDate}>
          {durationString}
        </span>
      ),
    });
  }
  return bracketed(result, {__react: true});
};

export default ExpirationDate;
