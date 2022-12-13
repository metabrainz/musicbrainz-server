/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import parseDate from '../static/scripts/common/utility/parseDate.js';

import {age, displayAgeAgo} from './age.js';

export function getCDStubAddedAgeAgo(cdStub: CDStubT): string {
  const now = parseDate((new Date()).toISOString().slice(0, 10));

  const addedAge = nonEmpty(cdStub.date_added) ? age({
    begin_date: parseDate(cdStub.date_added.slice(0, 10)),
    end_date: now,
    ended: true,
  }) : null;

  return addedAge ? displayAgeAgo(addedAge) : '';
}

export function getCDStubModifiedAgeAgo(cdStub: CDStubT): string {
  const now = parseDate((new Date()).toISOString().slice(0, 10));

  const lastModifiedAge = nonEmpty(cdStub.last_modified) ? age({
    begin_date: parseDate(cdStub.last_modified.slice(0, 10)),
    end_date: now,
    ended: true,
  }) : null;

  return lastModifiedAge ? displayAgeAgo(lastModifiedAge) : '';
}
