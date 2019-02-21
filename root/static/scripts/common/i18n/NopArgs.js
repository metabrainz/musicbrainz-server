/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type Args = $ReadOnlyArray<mixed>;

type Func = (...Args) => string;

class NopArgs {
  args: Args;
  func: Func;

  constructor(func: Func, args: Args) {
    this.func = func;
    this.args = args;
  }

  /*
   * This is what `Object.prototype.toLocaleString` does, but it's
   * also implemented here for clarity.
   */
  toLocaleString(...args: Array<mixed>) {
    return this.toString(...args);
  }

  toLocaleLowerCase() {
    return this.toString().toLowerCase();
  }

  toString(...args: Array<mixed>) {
    return this.func(...this.args, ...args);
  }
}

export default NopArgs;
