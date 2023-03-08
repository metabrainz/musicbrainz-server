/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import ButtonPopover from '../../common/components/ButtonPopover.js';
import type {
  LinkRelationshipT,
  LinkStateT,
} from '../externalLinks.js';
import {copyDatePeriodField} from '../utility/copyFieldData.js';
import {
  createCompoundFieldFromObject,
  createField,
} from '../utility/createField.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../utility/subfieldErrors.js';

import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  partialDateFromField,
  runReducer as runDateRangeFieldsetReducer,
} from './DateRangeFieldset.js';

type PropsT = {
  onConfirm: ($ReadOnly<Partial<LinkStateT>>) => void,
  relationship: LinkRelationshipT,
};

type StateT = {
  +datePeriodField: DatePeriodFieldT,
  initialDatePeriodField: DatePeriodFieldT,
};

type WritableStateT = {
  ...StateT,
  datePeriodField: WritableDatePeriodFieldT,
  initialDatePeriodField: WritableDatePeriodFieldT,
};

type ActionT =
  | {
      +action: DateRangeFieldsetActionT,
      +type: 'update-date-period',
    }
  | {
      +props: PropsT,
      +type: 'update-initial-date-period',
    }
  | {+type: 'reset'}
  | {+type: 'show-all-pending-errors'};

const createInitialState = (props: PropsT): StateT => {
  const relationship = props.relationship;
  const beginDate = relationship.begin_date;
  const endDate = relationship.end_date;

  const datePeriodField = {
    errors: [],
    has_errors: false,
    field: {
      begin_date: createCompoundFieldFromObject(
        'period.begin_date',
        {
          day: beginDate?.day ?? null,
          month: beginDate?.month ?? null,
          year: beginDate?.year ?? null,
        },
      ),
      end_date: createCompoundFieldFromObject(
        'period.end_date',
        {
          day: endDate?.day ?? null,
          month: endDate?.month ?? null,
          year: endDate?.year ?? null,
        },
      ),
      ended: createField('period.ended', relationship.ended),
    },
    html_name: '',
    id: 0,
    type: 'compound_field',
  };

  return {
    datePeriodField,
    initialDatePeriodField: datePeriodField,
  };
};

const reducer = (state: StateT, action: ActionT): StateT => {
  return mutate<WritableStateT, StateT>(
    state, (newState) => {
      switch (action.type) {
        case 'update-date-period':
          runDateRangeFieldsetReducer(
            newState.datePeriodField,
            action.action,
          );
          break;
        case 'update-initial-date-period':
          copyDatePeriodField(
            createInitialState(action.props).initialDatePeriodField,
            newState.initialDatePeriodField,
          );
          break;
        case 'reset':
          copyDatePeriodField(
            newState.initialDatePeriodField,
            newState.datePeriodField,
          );
          break;
        case 'show-all-pending-errors':
          applyAllPendingErrors(newState.datePeriodField);
          break;
        default:
          throw new Error('Unknown action: ' + action.type);
      }
    },
  );
};

const ExternalLinkAttributeDialog = (props: PropsT): React.MixedElement => {
  const buttonRef = React.useRef<HTMLButtonElement | null>(null);
  const [open, setOpen] = React.useState(false);

  const [state, dispatch] = React.useReducer(
    reducer,
    props,
    createInitialState,
  );
  const hasErrors = hasSubfieldErrors(state.datePeriodField);

  React.useEffect(() => {
    dispatch({type: 'update-initial-date-period', props});
  }, [props]);

  const dateDispatch = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-period'});
  }, [dispatch]);

  const onToggle = (open: boolean) => {
    if (open) {
      dispatch({type: 'reset'});
    }
    setOpen(open);
  };

  const handleConfirm = (closeAndReturnFocus: () => void) => {
    if (hasErrors) {
      return;
    }
    const field = state.datePeriodField.field;
    props.onConfirm({
      begin_date: partialDateFromField(field.begin_date),
      end_date: partialDateFromField(field.end_date),
      ended: field.ended.value,
    });
    closeAndReturnFocus();
  };

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
  };

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
  };

  const buildPopoverChildren =
    (closeAndReturnFocus: () => void): React.Element<'form'> => {
      return (
        <form
          className="external-link-attribute-dialog"
          onKeyDown={handleKeyDown}
          onSubmit={handleSubmit}
        >
          <DateRangeFieldset
            dispatch={dateDispatch}
            endedLabel={l('This relationship has ended.')}
            field={state.datePeriodField}
          />
          <div
            className="buttons"
            style={{display: 'block', marginTop: '1em'}}
          >
            <button
              className="negative"
              onClick={closeAndReturnFocus}
              type="button"
            >
              {l('Cancel')}
            </button>
            <div className="buttons-right">
              <button
                className="positive"
                disabled={hasErrors}
                onClick={() => handleConfirm(closeAndReturnFocus)}
                type="submit"
              >
                {l('Done')}
              </button>
            </div>
          </div>
        </form>
      );
    };

  return (
    <ButtonPopover
      buildChildren={buildPopoverChildren}
      buttonContent={null}
      buttonProps={{
        className: 'icon edit-item',
        title: l('Edit Attributes'),
      }}
      buttonRef={buttonRef}
      id="external-link-attribute-dialog"
      isOpen={open}
      toggle={onToggle}
    />
  );
};

export default ExternalLinkAttributeDialog;
