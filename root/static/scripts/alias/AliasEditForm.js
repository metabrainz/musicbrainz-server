/*
 * @flow
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
  WritableAliasEditFormT,
} from '../../../entity/alias/types';
import EnterEdit from '../../../components/EnterEdit';
import EnterEditNote from '../../../components/EnterEditNote';
import FormRowCheckbox from '../../../components/FormRowCheckbox';
import FormRowSelect from '../../../components/FormRowSelect';
import isBlank from '../common/utility/isBlank';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../edit/components/DateRangeFieldset';
import FormRowNameWithGuessCase, {
  runReducer as runNameReducer,
  type ActionT as NameActionT,
} from '../edit/components/FormRowNameWithGuessCase';
import FormRowSortNameWithGuessCase, {
  runReducer as runSortNameReducer,
  type ActionT as SortNameActionT,
} from '../edit/components/FormRowSortNameWithGuessCase';
import {
  createInitialState as createGuessCaseOptionsState,
  type StateT as GuessCaseOptionsStateT,
  type WritableStateT as WritableGuessCaseOptionsStateT,
} from '../edit/components/GuessCaseOptions';
import copyFieldData, {
  copyDatePeriodField,
} from '../edit/utility/copyFieldData';
import {
  createCompoundField,
  createField,
} from '../edit/utility/createField';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../../utility/subfieldErrors';

type Props = {
  +$c: CatalystContextT,
  +aliasTypes: SelectOptionsT,
  +entity: CoreEntityT,
  +form: AliasEditFormT,
  +locales: SelectOptionsT,
  +searchHintType: number,
};

/* eslint-disable flowtype/sort-keys */
type ActionT =
  | {+type: 'set-locale', +locale: string}
  | {+type: 'set-primary-for-locale', +enabled: boolean}
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'update-date-range', +action: DateRangeFieldsetActionT}
  | {+type: 'update-name', +action: NameActionT}
  | {+type: 'update-sortname', +action: SortNameActionT};
/* eslint-enable flowtype/sort-keys */

type StateT = {
  +form: AliasEditFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +isTypeSearchHint: boolean,
  +previousForm?: AliasEditFormT | null,
  +searchHintType: number,
};

type WritableStateT = {
  ...StateT,
  form: WritableAliasEditFormT,
  guessCaseOptions: WritableGuessCaseOptionsStateT,
  previousForm?: AliasEditFormT | null,
};

const blankDatePeriod = {
  errors: [],
  field: {
    begin_date: createCompoundField(
      'period.begin_date',
      {day: '', month: '', year: ''},
    ),
    end_date: createCompoundField(
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
  return mutate<WritableStateT, StateT>(state, newState => {
    switch (action.type) {
      case 'update-date-range': {
        runDateRangeFieldsetReducer(
          newState.form.field.period,
          action.action,
        );
        break;
      }
      case 'update-name': {
        const nameState = {
          field: newState.form.field.name,
          guessCaseOptions: newState.guessCaseOptions,
          isGuessCaseOptionsOpen: newState.isGuessCaseOptionsOpen,
        };
        runNameReducer(nameState, action.action);
        newState.guessCaseOptions = nameState.guessCaseOptions;
        newState.isGuessCaseOptionsOpen = nameState.isGuessCaseOptionsOpen;
        break;
      }
      case 'update-sortname': {
        runSortNameReducer({
          nameField: state.form.field.name,
          sortNameField: newState.form.field.sort_name,
        }, action.action);
        break;
      }
      case 'set-locale': {
        newState.form.field.locale.value = action.locale;
        if (action.locale === '') {
          newState.form.field.primary_for_locale.value = false;
        }
        break;
      }
      case 'set-primary-for-locale': {
        const enabled = action.enabled;
        newState.form.field.primary_for_locale.value = enabled;
        break;
      }
      case 'set-type': {
        const formField = newState.form.field;
        formField.type_id.value = action.type_id;
        const isTypeSearchHint =
          parseInt(action.type_id, 10) === state.searchHintType;
        newState.isTypeSearchHint = isTypeSearchHint;
        /*
         * Many fields are irrelevant for search hints,
         * so we blank (and disable) them if the user selects
         * the search hint type, and bring them back if they select
         * something else again.
         */
        if (isTypeSearchHint) {
          newState.previousForm = state.form;
          formField.sort_name.value = '';
          formField.locale.value = '';
          formField.primary_for_locale.value = false;
          copyDatePeriodField(blankDatePeriod, formField.period);
        } else if (state.previousForm) {
          const previousFormField = state.previousForm.field;
          copyFieldData(previousFormField.sort_name, formField.sort_name);
          copyFieldData(previousFormField.locale, formField.locale);
          copyFieldData(
            previousFormField.primary_for_locale,
            formField.primary_for_locale,
          );
          copyDatePeriodField(previousFormField.period, formField.period);
          newState.previousForm = null;
        }
        break;
      }
      case 'show-all-pending-errors': {
        applyAllPendingErrors(newState.form);
        break;
      }
      default: {
        /*:: exhaustive(action); */
      }
    }
  });
}

const AliasEditForm = ({
  $c,
  aliasTypes,
  entity,
  form: initialForm,
  locales,
  searchHintType,
}: Props): React.Element<typeof React.Fragment> => {
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

  const setLocale = React.useCallback((event) => {
    dispatch({locale: event.currentTarget.value, type: 'set-locale'});
  }, [dispatch]);

  const setPrimaryForLocale = React.useCallback((event) => {
    dispatch({
      enabled: event.currentTarget.checked,
      type: 'set-primary-for-locale',
    });
  }, [dispatch]);

  const setType = React.useCallback((event) => {
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
        action={$c.req.uri}
        className="edit-alias"
        method="post"
        onKeyDown={handleKeyDown}
        onSubmit={handleSubmit}
      >
        <div className="half-width">
          <fieldset>
            <legend>{l('Alias Details')}</legend>
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
): React.AbstractComponent<Props, void>);
