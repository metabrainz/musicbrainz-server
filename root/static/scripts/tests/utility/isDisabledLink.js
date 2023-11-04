/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import isDisabledLink from '../../common/utility/isDisabledLink.js';

import {genericUrl} from './constants.js';

test('isDisabledLink', function (t) {
  t.plan(6);

  const malwareUrl = {
    ...genericUrl,
    href_url: 'http://www.starzik.com/mp3/produits/Destroyer-2170839.html',
  };
  const endedRelationshipDate = {
    end_date: {year: 1999},
    ended: true,
  };
  const endedInFutureRelationshipDate = {
    end_date: {year: 2999},
    ended: true,
  };
  const notEndedRelationshipDate = {
    end_date: null,
    ended: false,
  };

  t.ok(
    isDisabledLink(notEndedRelationshipDate, malwareUrl),
    'Malware URL is disabled when its relationship is not ended',
  );
  t.ok(
    !isDisabledLink(notEndedRelationshipDate, genericUrl),
    'Generic URL is not disabled when its relationship is not ended',
  );

  t.ok(
    isDisabledLink(endedInFutureRelationshipDate, malwareUrl),
    'Malware URL is disabled when its relationship has a future end date',
  );
  t.ok(
    !isDisabledLink(endedInFutureRelationshipDate, genericUrl),
    'Generic URL is not disabled when its relationship has a future end date',
  );

  t.ok(
    isDisabledLink(endedRelationshipDate, malwareUrl),
    'Malware URL is disabled when its relationship has a past end date',
  );
  t.ok(
    isDisabledLink(endedRelationshipDate, genericUrl),
    'Generic URL is disabled when its relationship has a past end date',
  );
});
