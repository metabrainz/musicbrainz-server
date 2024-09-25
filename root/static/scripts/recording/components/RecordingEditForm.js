/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {RecordingFormT} from '../../../../recording/types.js';
import Bubble from '../../common/components/Bubble.js';
import {
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import formatTrackLength
  from '../../common/utility/formatTrackLength.js';
import isBlank from '../../common/utility/isBlank.js';
import ArtistCreditEditor, {
  createInitialState as createArtistCreditState,
  reducer as runArtistCreditReducer,
} from '../../edit/components/ArtistCreditEditor.js';
import {
  type ActionT as ArtistCreditActionT,
  type StateT as ArtistCreditStateT,
} from '../../edit/components/ArtistCreditEditor/types.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import {NonHydratedFormRowTextList as FormRowTextList}
  from '../../edit/components/FormRowTextList.js';
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
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'show-all-pending-errors'}
  | {+type: 'toggle-isrc-bubble'}
  | {+type: 'update-name', +action: NameActionT}
  | {+type: 'update-artist-credit', +action: ArtistCreditActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +artistCredit: ArtistCreditStateT,
  +form: RecordingFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
  +recording: RecordingT,
  +showIsrcBubble: boolean,
};

function createInitialState(
  form: RecordingFormT,
  $c: SanitizedCatalystContextT,
) {
  const recording = getSourceEntityDataForRelationshipEditor($c);
  invariant(recording && recording.entityType === 'recording');

  return {
    artistCredit: createArtistCreditState({
      entity: recording,
      formName: form.name,
      id: 'artist-credit-editor',
    }),
    form,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    recording,
    showIsrcBubble: false,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  switch (action.type) {
    case 'update-name': {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action.action);

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
      break;
    }
    case 'toggle-isrc-bubble': {
      newStateCtx.set('showIsrcBubble', true);
      break;
    }
    case 'show-all-pending-errors': {
      applyAllPendingErrors(newStateCtx.get('form'));
      break;
    }
    case 'update-artist-credit': {
      newStateCtx.set(
        'artistCredit',
        runArtistCreditReducer(state.artistCredit, action.action),
      );
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newStateCtx.final();
}

component RecordingEditForm(
  form as initialForm: RecordingFormT,
  usedByTracks: boolean,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const [state, dispatch] = React.useReducer(
    reducer,
    createInitialState(initialForm, $c),
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const artistCreditEditorDispatch = React.useCallback((
    action: ArtistCreditActionT,
  ) => {
    dispatch({action, type: 'update-artist-credit'});
  }, [dispatch]);

  function handleIsrcFocus() {
    dispatch({type: 'toggle-isrc-bubble'});
  }

  const hasErrors = hasSubfieldErrors(state.form);

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
      'edit-recording',
      externalLinksEditorRef.current,
    );
  };

  const isrcFieldRef = React.useRef<HTMLDivElement | null>(null);

  return (
    <form
      className="edit-recording"
      method="post"
      onKeyDown={handleKeyDown}
      onSubmit={handleSubmit}
    >
      <p>
        {exp.l(
          'For more information, check the {doc_doc|documentation}.',
          {doc_doc: {href: '/doc/Recording', target: '_blank'}},
        )}
      </p>

      <div className="half-width">
        <fieldset>
          <legend>{l('Recording details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={state.recording}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l('Name'))}
          />
          <FormRow>
            <label className="required" htmlFor="ac-source-single-artist">
              {addColonText(l('Artist'))}
            </label>
            <ArtistCreditEditor
              dispatch={artistCreditEditorDispatch}
              state={state.artistCredit}
            />
            <FieldErrors field={state.form.field.artist_credit} />
          </FormRow>
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l('Disambiguation'))}
            uncontrolled
          />
          {(!usedByTracks || state.form.field.length.has_errors) ? (
            <FormRowTextLong
              field={state.form.field.length}
              label={addColonText(l('Length'))}
              uncontrolled
            />
          ) : (
            <FormRow>
              <label>{addColonText(l('Length'))}</label>
              {exp.l(
                `{recording_length}
                 ({length_info|derived} from the associated track lengths)`,
                {
                  length_info: {href: '/doc/Recording', target: '_blank'},
                  recording_length: formatTrackLength(
                    nonEmpty(state.form.field.length.value)
                      ? parseInt(state.form.field.length.value, 10)
                      : null,
                  ),
                },
              )}
            </FormRow>

          )}
          <FormRowCheckbox
            field={state.form.field.video}
            label={l('Video')}
            uncontrolled
          />
          <FormRowTextList
            addButtonId="add-isrc"
            addButtonLabel={lp('Add ISRC', 'interactive')}
            label={addColonText(l('ISRCs'))}
            onFocus={handleIsrcFocus}
            removeButtonLabel={lp('Remove ISRC', 'interactive')}
            repeatable={state.form.field.isrcs}
            rowRef={isrcFieldRef}
          />
        </fieldset>

        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />

        <fieldset>
          <legend>{l('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!state.recording.id}
            ref={externalLinksEditorRef}
            sourceData={state.recording}
          />
        </fieldset>

        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>

      <div className="documentation">
        {state.showIsrcBubble ? (
          <Bubble
            controlRef={isrcFieldRef}
            id="isrcs-bubble"
          >
            <p>
              {exp.l(`You are about to add an ISRC to this recording.
                  The ISRC must be entered in standard
                  <code>CCXXXYYNNNNN</code> format:`)}
            </p>
            <ul>
              <li>
                {l(`"CC" is the appropriate for the registrant
                    two-character country code.`)}
              </li>
              <li>
                {l(`"XXX" is a three character alphanumeric registrant code,
                    uniquely identifying the organisation
                    which registered the code.`)}
              </li>
              <li>
                {l(`"YY" is the last two digits
                    of the year of registration.`)}
              </li>
              <li>
                {l(`"NNNNN" is a unique 5-digit number identifying
                    the particular sound recording.`)}
              </li>
            </ul>
          </Bubble>
        ) : null}
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<RecordingEditForm>>(
  'div.recording-edit-form',
  RecordingEditForm,
): React.AbstractComponent<React.PropsOf<RecordingEditForm>>);
