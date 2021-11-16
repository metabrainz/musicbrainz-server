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
import UrlRelationshipCreditFieldset
  from './UrlRelationshipCreditFieldset.js';

type PropsT = {
  creditableEntityProp: 'entity0_credit' | 'entity1_credit' | null,
  onConfirm: ($ReadOnly<Partial<LinkStateT>>) => void,
  relationship: LinkRelationshipT,
};

type StateT = {
  +credit: FieldT<string | null>,
  +datePeriodField: DatePeriodFieldT,
  +initialDatePeriodField: DatePeriodFieldT,
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
  | {+credit: string, +type: 'update-relationship-credit'}
  | {+type: 'reset'}
  | {+type: 'show-all-pending-errors'};

const createInitialState = (props: PropsT): StateT => {
  const relationship = props.relationship;
  const beginDate = relationship.begin_date;
  const endDate = relationship.end_date;

  const credit = createField(
    'credit',
    props.creditableEntityProp
      ? relationship[props.creditableEntityProp]
      : null,
  );

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
    credit,
    datePeriodField,
    initialDatePeriodField: datePeriodField,
  };
};

const reducer = (state: StateT, action: ActionT): StateT => {
  const ctx = mutate(state);

  switch (action.type) {
    case 'update-date-period':
      runDateRangeFieldsetReducer(
        ctx.get('datePeriodField'),
        action.action,
      );
      break;
    case 'update-initial-date-period':
      copyDatePeriodField(
        createInitialState(action.props).initialDatePeriodField,
        ctx.get('initialDatePeriodField'),
      );
      break;
    case 'reset':
      copyDatePeriodField(
        ctx.get('initialDatePeriodField').read(),
        ctx.get('datePeriodField'),
      );
      break;
    case 'show-all-pending-errors':
      applyAllPendingErrors(ctx.get('datePeriodField'));
      break;
    case 'update-relationship-credit':
      ctx.set('credit', 'value', action.credit);
      break;
    default:
      throw new Error('Unknown action: ' + action.type);
  }

  return ctx.final();
};

const ExternalLinkAttributeDialog = (props: PropsT): React$MixedElement => {
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
    const dateFields = state.datePeriodField.field;
    const confirmedProps = {
      begin_date: partialDateFromField(dateFields.begin_date),
      end_date: partialDateFromField(dateFields.end_date),
      ended: dateFields.ended.value,
    };
    if (props.creditableEntityProp) {
      // $FlowIgnore[prop-missing]
      confirmedProps[props.creditableEntityProp] = state.credit.value;
    }
    props.onConfirm(confirmedProps);
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
    (closeAndReturnFocus: () => void): React$Element<'form'> => {
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
          {props.creditableEntityProp ? (
            <UrlRelationshipCreditFieldset
              dispatch={dispatch}
              field={state.credit}
            />
          ) : null}
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
        title: lp('Edit attributes', 'interactive'),
      }}
      buttonRef={buttonRef}
      id="external-link-attribute-dialog"
      isOpen={open}
      toggle={onToggle}
    />
  );
};

export default ExternalLinkAttributeDialog;
