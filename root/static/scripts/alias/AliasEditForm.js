/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import type {
  AliasEditFormT,
} from '../../../entity/alias/types.js';
import isBlank from '../common/utility/isBlank.js';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../edit/components/DateRangeFieldset.js';
import EnterEdit from '../edit/components/EnterEdit.js';
import EnterEditNote from '../edit/components/EnterEditNote.js';
import FormRowCheckbox from '../edit/components/FormRowCheckbox.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../edit/components/FormRowNameWithGuessCase.js';
import FormRowSelect from '../edit/components/FormRowSelect.js';
import FormRowSortNameWithGuessCase, {
  type ActionT as SortNameActionT,
  runReducer as runSortNameReducer,
} from '../edit/components/FormRowSortNameWithGuessCase.js';
import {
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
} from '../edit/components/GuessCaseOptions.js';
import copyFieldData, {
  copyDatePeriodField,
} from '../edit/utility/copyFieldData.js';
import {
  createCompoundFieldFromObject,
  createField,
} from '../edit/utility/createField.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../edit/utility/subfieldErrors.js';

type Props = {
  +aliasTypes: SelectOptionsT,
  +entity: EntityWithAliasesT,
  +form: AliasEditFormT,
  +locales: SelectOptionsT,
  +searchHintType: number,
};

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'set-locale', +locale: string}
  | {+type: 'set-primary-for-locale', +enabled: boolean}
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'update-date-range', +action: DateRangeFieldsetActionT}
  | {+type: 'update-name', +action: NameActionT}
  | {+type: 'update-sortname', +action: SortNameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +form: AliasEditFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +isTypeSearchHint: boolean,
  +previousForm?: AliasEditFormT | null,
  +searchHintType: number,
};

const blankDatePeriod = {
  errors: [],
  field: {
    begin_date: createCompoundFieldFromObject(
      'period.begin_date',
      {day: '', month: '', year: ''},
    ),
    end_date: createCompoundFieldFromObject(
      'period.end_date',
      {day: '', month: '', year: ''},
    ),
    ended: createField('period.ended', false),
  },
  has_errors: false,
  html_name: '',
  id: 0,
  type: 'compound_field',
};

function createInitialState(form: AliasEditFormT, searchHintType: number) {
  return {
    form,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    isTypeSearchHint: form.field.type_id.value === searchHintType,
    searchHintType,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  const fieldCtx = newStateCtx.get('form', 'field');

  switch (action.type) {
    case 'update-date-range': {
      runDateRangeFieldsetReducer(
        newStateCtx.get('form', 'field', 'period'),
        action.action,
      );
      break;
    }
    case 'update-name': {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action.action);
      const nameState = nameStateCtx.read();
      newStateCtx
        .set('form', 'field', 'name', nameState.field)
        .set('guessCaseOptions', nameState.guessCaseOptions)
        .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen);
      break;
    }
    case 'update-sortname': {
      const sortNameStateCtx = mutate({
        nameField: state.form.field.name,
        sortNameField: state.form.field.sort_name,
      });
      runSortNameReducer(sortNameStateCtx, action.action);
      const sortNameState = sortNameStateCtx.read();
      fieldCtx
        .set('name', sortNameState.nameField)
        .set('sort_name', sortNameState.sortNameField);
      break;
    }
    case 'set-locale': {
      fieldCtx.set('locale', 'value', action.locale);
      if (action.locale === '') {
        fieldCtx.set('primary_for_locale', 'value', false);
      }
      break;
    }
    case 'set-primary-for-locale': {
      const enabled = action.enabled;
      fieldCtx.set('primary_for_locale', 'value', enabled);
      break;
    }
    case 'set-type': {
      fieldCtx.set('type_id', 'value', action.type_id);
      const isTypeSearchHint =
        parseInt(action.type_id, 10) === state.searchHintType;
      newStateCtx.set('isTypeSearchHint', isTypeSearchHint);
      /*
       * Many fields are irrelevant for search hints,
       * so we blank (and disable) them if the user selects
       * the search hint type, and bring them back if they select
       * something else again.
       */
      if (isTypeSearchHint) {
        newStateCtx.set('previousForm', state.form);
        fieldCtx
          .set('sort_name', 'value', '')
          .set('locale', 'value', '')
          .set('primary_for_locale', 'value', false);
        copyDatePeriodField(blankDatePeriod, fieldCtx.get('period'));
      } else if (state.previousForm) {
        const previousFormField = state.previousForm.field;
        copyFieldData(previousFormField.sort_name, fieldCtx.get('sort_name'));
        copyFieldData(previousFormField.locale, fieldCtx.get('locale'));
        copyFieldData(
          previousFormField.primary_for_locale,
          fieldCtx.get('primary_for_locale'),
        );
        copyDatePeriodField(previousFormField.period, fieldCtx.get('period'));
        newStateCtx.set('previousForm', null);
      }
      break;
    }
    case 'show-all-pending-errors': {
      applyAllPendingErrors(newStateCtx.get('form'));
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newStateCtx.final();
}

const AliasEditForm = ({
  aliasTypes,
  entity,
  form: initialForm,
  locales,
  searchHintType,
}: Props): React$Element<React$FragmentType> => {
  const localeOptions = {
    grouped: false,
    options: locales,
  };

  const typeOptions = {
    grouped: false,
    options: aliasTypes,
  };

  const [state, dispatch] = React.useReducer(
    reducer,
    createInitialState(initialForm, searchHintType),
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const sortNameDispatch = React.useCallback((action: SortNameActionT) => {
    dispatch({action, type: 'update-sortname'});
  }, [dispatch]);

  const setLocale = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    dispatch({locale: event.currentTarget.value, type: 'set-locale'});
  }, [dispatch]);

  const setPrimaryForLocale = React.useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      enabled: event.currentTarget.checked,
      type: 'set-primary-for-locale',
    });
  }, [dispatch]);

  const setType = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    dispatch({type: 'set-type', type_id: event.currentTarget.value});
  }, [dispatch]);

  const dispatchDateRange = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-range'});
  }, [dispatch]);

  const missingRequired = isBlank(state.form.field.name.value);

  const hasErrors = missingRequired || hasSubfieldErrors(state.form);

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

  return (
    <>
      <p>
        {exp.l(
          `An alias is an alternate name for an entity. They typically contain
           common misspellings or variations of the name and are also used
           to improve search results. View the {doc|alias documentation}
           for more details.`,
          {doc: '/doc/Aliases'},
        )}
      </p>

      <form
        className="edit-alias"
        method="post"
        onKeyDown={handleKeyDown}
        onSubmit={handleSubmit}
      >
        <div className="half-width">
          <fieldset>
            <legend>{l('Alias details')}</legend>
            <FormRowNameWithGuessCase
              dispatch={nameDispatch}
              entity={entity}
              field={state.form.field.name}
              guessCaseOptions={state.guessCaseOptions}
              isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
              label={l('Alias name:')}
            />
            <FormRowSortNameWithGuessCase
              disabled={state.isTypeSearchHint}
              dispatch={sortNameDispatch}
              entity={entity}
              field={state.form.field.sort_name}
            />
            <FormRowSelect
              allowEmpty
              disabled={state.isTypeSearchHint}
              field={state.form.field.locale}
              label={addColonText(l('Locale'))}
              onChange={setLocale}
              options={localeOptions}
            />
            <div
              id="allow_primary_for_locale"
            >
              <FormRowCheckbox
                disabled={
                  state.isTypeSearchHint || !state.form.field.locale.value
                }
                field={state.form.field.primary_for_locale}
                label={l('This is the primary alias for this locale')}
                onChange={setPrimaryForLocale}
              />
            </div>
            <FormRowSelect
              allowEmpty
              field={state.form.field.type_id}
              label={addColonText(l('Type'))}
              onChange={setType}
              options={typeOptions}
            />
          </fieldset>
          <DateRangeFieldset
            disabled={state.isTypeSearchHint}
            dispatch={dispatchDateRange}
            endedLabel={l('This alias is no longer current.')}
            field={state.form.field.period}
          />
          <EnterEditNote field={state.form.field.edit_note} />
          <EnterEdit
            disabled={hasErrors}
            form={state.form}
          />
        </div>
      </form>
    </>
  );
};

export default (hydrate<Props>(
  'div.alias-edit-form',
  AliasEditForm,
): React$AbstractComponent<Props, void>);
