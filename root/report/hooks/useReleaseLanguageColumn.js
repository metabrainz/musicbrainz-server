/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptionsNoValue} from 'react-table';

import {
  defineReleaseLanguageColumn,
} from '../../utility/tableColumns.js';
import type {ReportReleaseT} from '../types.js';

function useReleaseLanguageColumn<
  D: $ReadOnly<{...ReportReleaseT, ...}>,
>(): $ReadOnlyArray<ColumnOptionsNoValue<D>> {
  const columns = React.useMemo(
    () => {
      const releaseLanguageColumn = defineReleaseLanguageColumn<D>({
        getEntity: result => result.release ?? null,
      });

      return [
        releaseLanguageColumn,
      ];
    },
    [],
  );

  return columns;
}

export default useReleaseLanguageColumn;
