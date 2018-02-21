/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Args = $ReadOnlyArray<string>;

class NopArgs {
  args: Args;

  constructor(args: Args) {
    this.args = args;
  }
}

module.exports = NopArgs;
