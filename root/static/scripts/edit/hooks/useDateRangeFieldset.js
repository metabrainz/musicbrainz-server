/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import type {
  ActionT,
} from '../components/DateRangeFieldset.js';
import type {
  ActionT as FormRowPartialDateActionT,
} from '../components/FormRowPartialDate.js';

type DateRangeFieldsetHooksT = {
  +beginDateDispatch: (FormRowPartialDateActionT) => void,
  +beginYearInputRef: {current: HTMLInputElement | null},
  +endDateDispatch: (FormRowPartialDateActionT) => void,
  +endYearInputRef: {current: HTMLInputElement | null},
  +handleDateCopy: () => void,
  +handleEndedChange: (event: SyntheticEvent<HTMLInputElement>) => void,
};

export default function useDateRangeFieldset(
  dispatch: (ActionT) => void,
): DateRangeFieldsetHooksT {
  const handleEndedChange = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      enabled: event.currentTarget.checked,
      type: 'set-ended',
    });
  }, [dispatch]);

  const handleDateCopy = () => {
    dispatch({type: 'copy-date'});
  };

  const beginDateDispatch = React.useCallback((
    action: FormRowPartialDateActionT,
  ) => {
    dispatch({action, type: 'update-begin-date'});
  }, [dispatch]);

  const endDateDispatch = React.useCallback((
    action: FormRowPartialDateActionT,
  ) => {
    dispatch({action, type: 'update-end-date'});
  }, [dispatch]);

  const beginYearInputRef = React.useRef(null);

  const endYearInputRef = React.useRef(null);

  return {
    beginDateDispatch,
    beginYearInputRef,
    endDateDispatch,
    endYearInputRef,
    handleDateCopy,
    handleEndedChange,
  };
}
