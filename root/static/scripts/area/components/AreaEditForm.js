/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import mutate from 'mutate-cow';
import * as React from 'react';

import type {
  AreaFormT,
} from '../../../../area/types.js';
import {SanitizedCatalystContext} from '../../../../context.mjs';
import TypeBubble from '../../common/components/TypeBubble.js';
import isBlank from '../../common/utility/isBlank.js';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../../edit/components/DateRangeFieldset.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowTextListSimple, {
  type ActionT as Iso3166ActionT,
  createInitialState as createIso3166State,
  runReducer as runIso3166Reducer,
}
  from '../../edit/components/FormRowTextListSimple.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
} from '../../edit/components/GuessCaseOptions.js';
import {
  _ExternalLinksEditor,
  ExternalLinksEditor,
  prepareExternalLinksHtmlFormSubmission,
} from '../../edit/externalLinks.js';
import {
  type Iso3166Variant,
  ISO_3166_VARIANTS,
  iso3166VariantSnake,
  isValidIso3166,
} from '../../edit/utility/iso3166.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'toggle-type-bubble'}
  | {
      +type: 'update-iso-3166',
      +variant: Iso3166Variant,
      +action: Iso3166ActionT,
    }
  | {+type: 'update-date-range', +action: DateRangeFieldsetActionT}
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
    +form: AreaFormT,
    +guessCaseOptions: GuessCaseOptionsStateT,
    +isGuessCaseOptionsOpen: boolean,
    +showTypeBubble: boolean,
};

function createInitialState(form: AreaFormT): StateT {
  const formCtx = mutate(form);

  for (const variant of ISO_3166_VARIANTS) {
    formCtx
      .update('field', iso3166VariantSnake(variant), (iso3166Ctx) => {
        iso3166Ctx.set(createIso3166State(iso3166Ctx.read()));
        updateIso3166FieldErrors(variant, iso3166Ctx);
      });
  }

  return {
    form: formCtx.final(),
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    showTypeBubble: false,
  };
}

function updateIso3166FieldErrors(
  variant: Iso3166Variant,
  fieldCtx: CowContext<RepeatableFieldT<FieldT<string>>>,
) {
  const innerFieldCtx = fieldCtx.get('field');
  const innerFieldLength = innerFieldCtx.read().length;
  for (let i = 0; i < innerFieldLength; i++) {
    const subFieldCtx = innerFieldCtx.get(i);
    const value = subFieldCtx.get('value').read();

    if (empty(value) || isValidIso3166(variant, value)) {
      subFieldCtx.set('has_errors', false);
      subFieldCtx.set('pendingErrors', []);
      subFieldCtx.set('errors', []);
    } else {
      subFieldCtx.set('has_errors', true);
      subFieldCtx.set('errors', [
        l(`This is not a valid ${variant} code`),
      ]);
    }
  }
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  const fieldCtx = newStateCtx.get('form', 'field');

    match (action) {
    {type: 'set-type', const type_id} => {
      fieldCtx.set('type_id', 'value', type_id);
    }
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(newStateCtx.get('form'));
    }
    {type: 'toggle-type-bubble'} => {
      newStateCtx.set('showTypeBubble', true);
    }
    {type: 'update-iso-3166', const variant, const action} => {
      const fieldName = iso3166VariantSnake(variant);
      const iso3166StateCtx = mutate(state.form.field[fieldName]);

      runIso3166Reducer(iso3166StateCtx, action);

      const iso3166State = iso3166StateCtx.read();
      newStateCtx
        .update('form', 'field', fieldName, (iso3166FieldCtx) => {
          iso3166FieldCtx.set(iso3166State);
          updateIso3166FieldErrors(variant, iso3166FieldCtx);
        });
    }
    {type: 'update-date-range', const action} => {
      runDateRangeFieldsetReducer(
        newStateCtx.get('form', 'field', 'period'),
        action,
      );
    }
    {type: 'update-name', const action} => {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action);

      const nameState = nameStateCtx.read();
      newStateCtx
        .update('form', 'field', 'name', (nameFieldCtx) => {
          nameFieldCtx.set(nameState.field);
          if (isBlank(nameState.field.value)) {
            nameFieldCtx.set('has_errors', true);
            nameFieldCtx.set('pendingErrors', [
              l('Required field.'),
            ]);
          } else {
            nameFieldCtx.set('has_errors', false);
            nameFieldCtx.set('pendingErrors', []);
            nameFieldCtx.set('errors', []);
          }
        })
        .set('guessCaseOptions', nameState.guessCaseOptions)
        .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen);
    }
    }
    return newStateCtx.final();
}

component AreaEditForm(
    areaDescriptions: {+[id: string]: string},
    areaTypes: SelectOptionsT,
    form as initialForm: AreaFormT
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const typeOptions = {
    grouped: false as const,
    options: areaTypes,
  };

  const [state, dispatch] = React.useReducer(
    reducer,
    createInitialState(initialForm),
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const setType = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    dispatch({type: 'set-type', type_id: event.currentTarget.value});
  }, [dispatch]);

  const handleTypeFocus = React.useCallback(() => {
    dispatch({type: 'toggle-type-bubble'});
  }, [dispatch]);

  const handleIso3166Update = React.useCallback(
    (variant: Iso3166Variant) => (action: Iso3166ActionT) => {
      dispatch({
        action,
        type: 'update-iso-3166',
        variant,
      });
    }, [dispatch],
  );

  const dispatchDateRange = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-range'});
  }, [dispatch]);

  const hasErrors = hasSubfieldErrors(state.form);

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
  };

  const area = $c.stash.source_entity;
  invariant(area && area.entityType === 'area');

  const externalLinksEditorRef = React.createRef<_ExternalLinksEditor>();

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
    invariant(externalLinksEditorRef.current);
    prepareExternalLinksHtmlFormSubmission(
      'edit-area',
      externalLinksEditorRef.current,
    );
  };

  const typeSelectRef = React.useRef<HTMLDivElement | null>(null);

  return (
    <form
      className="edit-area"
      method="post"
      onKeyDown={handleKeyDown}
      onSubmit={handleSubmit}
    >
      <div className="half-width">
        <fieldset>
          <legend>{l('Area details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={area}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l('Name'))}
          />
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l('Disambiguation'))}
            uncontrolled
          />
          <FormRowSelect
            allowEmpty
            field={state.form.field.type_id}
            label={addColonText(l('Type'))}
            onChange={setType}
            onFocus={handleTypeFocus}
            options={typeOptions}
            rowRef={typeSelectRef}
          />
          {ISO_3166_VARIANTS.map((variant) => {
            const fieldName = iso3166VariantSnake(variant);

            return (
              <FormRowTextListSimple
                addButtonId={`add-${fieldName}`}
                addButtonLabel={l(`Add ${variant}`)}
                dispatch={handleIso3166Update(variant)}
                key={fieldName}
                label={addColonText(l(variant))}
                removeButtonLabel={l(`Remove ${variant}`)}
                repeatable={state.form.field[fieldName]}
              />
            );
          })}
        </fieldset>
        <DateRangeFieldset
          dispatch={dispatchDateRange}
          endedLabel={l('This area has ended.')}
          field={state.form.field.period}
        />
        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />
        <fieldset>
          <legend>{l('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!area.id}
            ref={externalLinksEditorRef}
            sourceData={area}
          />
        </fieldset>

        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>

      <div className="documentation">
        {state.showTypeBubble ? (
          <TypeBubble
            controlRef={typeSelectRef}
            descriptions={areaDescriptions}
            field={state.form.field.type_id}
            types={areaTypes}
          />
        ) : null}
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<AreaEditForm>>(
  'div.area-edit-form',
  AreaEditForm,
): component(...React.PropsOf<AreaEditForm>));
