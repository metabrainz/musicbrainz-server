/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {EventFormT} from '../../../../event/types.js';
import TypeBubble from '../../common/components/TypeBubble.js';
import isBlank from '../../common/utility/isBlank.js';
import DateRangeFieldset, {
  type ActionT as DateRangeFieldsetActionT,
  runReducer as runDateRangeFieldsetReducer,
} from '../../edit/components/DateRangeFieldset.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowText from '../../edit/components/FormRowText.js';
import FormRowTextArea from '../../edit/components/FormRowTextArea.js';
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
import isValidSetlist from '../../edit/utility/isValidSetlist.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'set-setlist', +setlist: string}
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'toggle-type-bubble'}
  | {+type: 'update-date-range', +action: DateRangeFieldsetActionT}
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +form: EventFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +showTypeBubble: boolean,
};

function createInitialState(form: EventFormT) {
  return {
    form,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    showTypeBubble: false,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  const fieldCtx = newStateCtx.get('form', 'field');

  match (action) {
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

      const nameState = nameStateCtx.final();
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
    {type: 'toggle-type-bubble'} => {
      newStateCtx.set('showTypeBubble', true);
    }
    {type: 'set-setlist', const setlist} => {
      fieldCtx.update('setlist', (setlistFieldCtx) => {
        setlistFieldCtx.set('value', setlist);
        if (isValidSetlist(setlist)) {
          setlistFieldCtx.set('has_errors', false);
          setlistFieldCtx.set('errors', []);
        } else {
          setlistFieldCtx.set('has_errors', true);
          setlistFieldCtx.set('errors', [
            l(`Please ensure all lines start with @, * or #,
                followed by a space.`),
          ]);
        }
      });
    }
    {type: 'set-type', const type_id} => {
      fieldCtx.set('type_id', 'value', type_id);
    }
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(newStateCtx.get('form'));
    }
  }
  return newStateCtx.final();
}

component EventEditForm(
  eventDescriptions: {+[id: string]: string},
  eventTypes: SelectOptionsT,
  form as initialForm: EventFormT,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const typeOptions = {
    grouped: false as const,
    options: eventTypes,
  };

  const [state, dispatch] = React.useReducer(
    reducer,
    initialForm,
    createInitialState,
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  function handleTypeFocus() {
    dispatch({type: 'toggle-type-bubble'});
  }

  const setType = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    dispatch({type: 'set-type', type_id: event.currentTarget.value});
  }, [dispatch]);

  const handleSetlistChange = React.useCallback((
    event: SyntheticEvent<HTMLTextAreaElement>,
  ) => {
    dispatch({setlist: event.currentTarget.value, type: 'set-setlist'});
  }, [dispatch]);

  const dispatchDateRange = React.useCallback((
    action: DateRangeFieldsetActionT,
  ) => {
    dispatch({action, type: 'update-date-range'});
  }, [dispatch]);

  const hasErrors = hasSubfieldErrors(state.form);

  const event = $c.stash.source_entity;
  invariant(event && event.entityType === 'event');

  const externalLinksEditorRef = React.createRef<_ExternalLinksEditor>();

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
    }
  };

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
    invariant(externalLinksEditorRef.current);
    prepareExternalLinksHtmlFormSubmission(
      'edit-event',
      externalLinksEditorRef.current,
    );
  };

  const typeSelectRef = React.useRef<HTMLDivElement | null>(null);

  return (
    <form
      className="edit-event"
      method="post"
      onKeyDown={handleKeyDown}
      onSubmit={handleSubmit}
    >
      <p>
        {exp.l(
          'For more information, check the {doc_doc|documentation}.',
          {doc_doc: {href: '/doc/Event', target: '_blank'}},
        )}
      </p>

      <div className="half-width">
        <fieldset>
          <legend>{l('Event details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={event}
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
          <FormRowCheckbox
            field={state.form.field.cancelled}
            label={l('This event was cancelled.')}
            uncontrolled
          />
          <FormRowTextArea
            cols={80}
            field={state.form.field.setlist}
            label={addColonText(l('Setlist'))}
            onChange={handleSetlistChange}
            rows={10}
            uncontrolled={false}
          />
          <p>
            {l(
              `Add "@ " at line start to indicate artists,
               "* " for a work/song,
               "# " for additional info (such as "Encore").
               [mbid|name] allows linking to artists and works.`,
            )}
          </p>
          <p>
            {exp.l(
              `If needed, the characters "[", "]", and "&" can be escaped
               using the HTML entities "<code>&amp;lsqb;</code>",
               "<code>&amp;rsqb;</code>", and "<code>&amp;amp;</code>"
               respectively.`,
            )}
          </p>
        </fieldset>

        <DateRangeFieldset
          dispatch={dispatchDateRange}
          field={state.form.field.period}
        >
          <FormRowText
            className="time"
            field={state.form.field.time}
            label={addColonText(lp('Time', 'event'))}
            placeholder={l('HH:MM')}
            size={5}
            uncontrolled
          />
        </DateRangeFieldset>

        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />

        <fieldset>
          <legend>{l('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!event.id}
            ref={externalLinksEditorRef}
            sourceData={event}
          />
        </fieldset>

        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>

      <div className="documentation">
         {state.showTypeBubble ? (
          <TypeBubble
            controlRef={typeSelectRef}
            descriptions={eventDescriptions}
            field={state.form.field.type_id}
            types={eventTypes}
          />
         ) : null}
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<EventEditForm>>(
  'div.event-edit-form',
  EventEditForm,
): component(...React.PropsOf<EventEditForm>));
