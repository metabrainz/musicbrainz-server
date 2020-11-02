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
import MB from '../common/MB';
import isBlank from '../common/utility/isBlank';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../edit/components/DateRangeFieldset';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
} from '../edit/components/FormRowNameWithGuessCase';
import FormRowSortNameWithGuessCase, {
  type ActionT as SortNameActionT,
} from '../edit/components/FormRowSortNameWithGuessCase';
import {
  createInitialState as createGuessCaseOptionsState,
  runReducer as runGuessCaseOptionsReducer,
  type StateT as GuessCaseOptionsStateT,
  type WritableStateT as WritableGuessCaseOptionsStateT,
} from '../edit/components/GuessCaseOptions';
import hydrate from '../../../utility/hydrate';
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
  | NameActionT
  | SortNameActionT
  | {+type: 'set-locale', +locale: string}
  | {+type: 'set-primary-for-locale', +enabled: boolean}
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'update-date-range', +action: DateRangeFieldsetActionT};
/* eslint-enable flowtype/sort-keys */

type StateT = {
  +form: AliasEditFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +isTypeSearchHint: boolean,
  +searchHintType: number,
};

type WritableStateT = {
  ...StateT,
  form: WritableAliasEditFormT,
  guessCaseOptions: WritableGuessCaseOptionsStateT,
};

function createInitialState(form, searchHintType) {
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
      case 'set-name': {
        newState.form.field.name.value = action.name;
        break;
      }
      case 'guess-case': {
        const nameField = newState.form.field.name;
        nameField.value =
          (MB.GuessCase: any)[action.entity.entityType].guess(
            nameField.value ?? '',
          );
        break;
      }
      case 'set-sortname': {
        newState.form.field.sort_name.value = action.sortName;
        break;
      }
      case 'guess-case-sortname': {
        const {entityType, typeID} = action.entity;
        newState.form.field.sort_name.value =
          (MB.GuessCase: any)[entityType].sortname(
            state.form.field.name.value ?? '',
            typeID,
          );
        break;
      }
      case 'copy-sortname': {
        newState.form.field.sort_name.value =
          state.form.field.name.value ?? '';
        break;
      }
      case 'open-guess-case-options': {
        newState.isGuessCaseOptionsOpen = true;
        break;
      }
      case 'close-guess-case-options': {
        newState.isGuessCaseOptionsOpen = false;
        break;
      }
      case 'update-guess-case-options': {
        runGuessCaseOptionsReducer(
          newState.guessCaseOptions,
          action.action,
        );
        break;
      }
      case 'update-date-range': {
        runDateRangeFieldsetReducer(
          newState.form.field.period,
          action.action,
        );
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
        newState.form.field.type_id.value = action.type_id;
        const isTypeSearchHint =
          parseInt(action.type_id, 10) === state.searchHintType;
        newState.isTypeSearchHint = isTypeSearchHint;
        if (isTypeSearchHint) {
          newState.form.field.primary_for_locale.value = false;
        }
        break;
      }
      case 'show-all-pending-errors': {
        applyAllPendingErrors(newState.form);
        break;
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

  const missingRequired = state.isTypeSearchHint
    ? isBlank(state.form.field.name.value)
    : isBlank(state.form.field.name.value) ||
      isBlank(state.form.field.sort_name.value);

  const hasErrors = missingRequired || hasSubfieldErrors(state.form);

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
  };

  const handleSubmit = (event) => {
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
              dispatch={dispatch}
              entity={entity}
              field={state.form.field.name}
              guessCaseOptions={state.guessCaseOptions}
              isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
              label={l('Alias name:')}
            />
            <FormRowSortNameWithGuessCase
              disabled={state.isTypeSearchHint}
              dispatch={dispatch}
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
  'div.recording-name',
  AliasEditForm,
): React.AbstractComponent<Props, void>);
