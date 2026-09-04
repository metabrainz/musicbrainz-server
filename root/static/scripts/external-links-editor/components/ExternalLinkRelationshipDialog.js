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

import {expect} from '../../../../utility/invariant.js';
import ButtonPopover from '../../common/components/ButtonPopover.js';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../../edit/components/DateRangeFieldset.js';
import {
  createCompoundFieldFromObject,
  createField,
} from '../../edit/utility/createField.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import type {
  LinkRelationshipStateT,
  LinksEditorActionT,
  LinksEditorRelationshipDialogActionT as ActionT,
  LinksEditorRelationshipDialogStateT as StateT,
  LinkStateT,
} from '../types.js';

import UrlRelationshipCreditFieldset
  from './UrlRelationshipCreditFieldset.js';

export function createInitialState(
  relationship: LinkRelationshipStateT,
): StateT {
  const beginDate = relationship.beginDate;
  const endDate = relationship.endDate;
  const datePeriodField = {
    errors: [],
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
    has_errors: false,
    html_name: '',
    id: 0,
    type: 'compound_field' as const,
  };
  return {
    creditField: createField('credit', relationship.entityCredit),
    datePeriodField,
  };
}

export const reducer = (state: StateT, action: ActionT): StateT => {
  const ctx = mutate(state);

  match (action) {
    {type: 'update-date-period', const action} => {
      runDateRangeFieldsetReducer(
        ctx.get('datePeriodField'),
        action,
      );
    }
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(ctx.get('datePeriodField'));
    }
    {type: 'update-relationship-credit', const credit} => {
      ctx.set('creditField', 'value', credit);
    }
  }

  return ctx.final();
};

component ExternalLinkRelationshipDialogContent(
  closeAndReturnFocus: () => void,
  creditable: boolean,
  dispatch as parentDispatch: (LinksEditorActionT) => void,
  link: LinkStateT,
  relationship: LinkRelationshipStateT,
) {
  const state = expect(relationship.dialogState);
  const creditField = state.creditField;
  const datePeriodField = state.datePeriodField;
  const hasErrors = hasSubfieldErrors(datePeriodField);

  const dispatch = React.useCallback((
    action: ActionT,
  ) => {
    parentDispatch({
      action,
      link,
      relationship,
      type: 'update-link-relationship-dialog',
    });
  }, [link, parentDispatch, relationship]);

  const dateDispatch = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-period'});
  }, [dispatch]);

  const handleConfirm = React.useCallback((
    closeAndReturnFocus: () => void,
  ) => {
    if (hasErrors) {
      return;
    }
    parentDispatch({
      link,
      relationship,
      type: 'accept-link-relationship-dialog',
    });
    closeAndReturnFocus();
  }, [hasErrors, parentDispatch, link, relationship]);

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLFormElement>,
  ) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
  }, [hasErrors, dispatch]);

  const handleSubmit = React.useCallback((
    event: SyntheticEvent<HTMLFormElement>,
    closeAndReturnFocus: () => void,
  ) => {
    event.stopPropagation();
    event.preventDefault();
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
    } else {
      handleConfirm(closeAndReturnFocus);
    }
  }, [hasErrors, dispatch, handleConfirm]);

  return (
    <form
      className="external-link-relationship-dialog"
      onKeyDown={handleKeyDown}
      onSubmit={(event) => handleSubmit(event, closeAndReturnFocus)}
    >
      <DateRangeFieldset
        dispatch={dateDispatch}
        endedLabel={l('This relationship has ended.')}
        field={datePeriodField}
      />
      {creditable ? (
        <UrlRelationshipCreditFieldset
          dispatch={dispatch}
          field={creditField}
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
            type="submit"
          >
            {l('Done')}
          </button>
        </div>
      </div>
    </form>
  );
}

component _ExternalLinkRelationshipDialog(
  creditable: boolean,
  dispatch as parentDispatch: (LinksEditorActionT) => void,
  link: LinkStateT,
  relationship: LinkRelationshipStateT,
) {
  const onToggle = React.useCallback((open: boolean) => {
    parentDispatch({
      link,
      open,
      relationship,
      type: 'toggle-link-relationship-dialog',
    });
  }, [link, parentDispatch, relationship]);

  const buildPopoverChildren = React.useCallback((
    closeAndReturnFocus: () => void,
  ): React.MixedElement => (
    <ExternalLinkRelationshipDialogContent
      closeAndReturnFocus={closeAndReturnFocus}
      creditable={creditable}
      dispatch={parentDispatch}
      link={link}
      relationship={relationship}
    />
  ), [creditable, parentDispatch, link, relationship]);

  return (
    <ButtonPopover
      buildChildren={buildPopoverChildren}
      buttonContent={null}
      buttonProps={{
        className: 'icon edit-item',
        title: lp('Edit relationship', 'interactive'),
      }}
      id="external-link-relationship-dialog"
      isOpen={relationship.dialogState !== null}
      toggle={onToggle}
    />
  );
}

const ExternalLinkRelationshipDialog:
  component(...React.PropsOf<_ExternalLinkRelationshipDialog>) =
    React.memo(_ExternalLinkRelationshipDialog);

export default ExternalLinkRelationshipDialog;
