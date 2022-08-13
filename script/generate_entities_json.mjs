#!./bin/sucrase-node
/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import canonicalJson from 'canonical-json';

import ENTITIES from '../entities.mjs';

console.log(canonicalJson({
  '': 'Automatically generated, do not edit. ' +
      'Refer to entities.mjs for instructions.',
  ...ENTITIES,
}, null, 4));
