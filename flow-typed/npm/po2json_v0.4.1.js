/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare module 'po2json' {
  import type {JedOptions} from 'jed';

  declare module.exports: {
    parseFileSync: (
      fileName: string,
      options: {domain: string, format: 'jed1.x'}
    ) => JedOptions,
  };
}
