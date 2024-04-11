/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import Diff from './Diff.js';

component WordDiff(...props: React.PropsOf<Diff>) {
  return (
    <Diff {...props} split="\s+" />
  );
}

export default WordDiff;
